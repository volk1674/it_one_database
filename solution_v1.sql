CREATE TABLE h_contractors
(
    r_ts           TIMESTAMP             NOT NULL,
    g_ts           DOUBLE PRECISION      NOT NULL,
    --
    id             INTEGER               NOT NULL,
    type           world.contractor_type NOT NULL,
    island         INTEGER               NOT NULL,
    item           INTEGER               NOT NULL,
    quantity       DOUBLE PRECISION      NOT NULL,
    price_per_unit DOUBLE PRECISION      NOT NULL
);

CREATE TABLE h_contracts
(
    r_ts          TIMESTAMP        NOT NULL,
    g_ts          DOUBLE PRECISION NOT NULL,
    --
    "id"          INTEGER          NOT NULL, --  Уникальный идентификатор
    "player"      INTEGER          NOT NULL, --  Игрок, с которым заключен контракт
    "contractor"  INTEGER          NOT NULL, --  Контрагент
    "quantity"    DOUBLE PRECISION NOT NULL, --  Договоренное количество товара
    "payment_sum" DOUBLE PRECISION NOT NULL  --  Договоренная оплата по контракту
);

CREATE TABLE h_storage
(
    r_ts       TIMESTAMP        NOT NULL,
    g_ts       DOUBLE PRECISION NOT NULL,
    --
    "player"   INTEGER          NOT NULL, --  Игрок
    "island"   INTEGER          NOT NULL, --  Остров
    "item"     INTEGER          NOT NULL, --  Тип товара
    "quantity" DOUBLE PRECISION NOT NULL  --  Количество данного типа товара на складе
);

CREATE TABLE h_islands
(
    r_ts TIMESTAMP        NOT NULL,
    g_ts DOUBLE PRECISION NOT NULL,
    --
    "id" INTEGER          NOT NULL, --  Уникальный идентификатор
    "x"  DOUBLE PRECISION NOT NULL, --  Координата по горизонтали
    "y"  DOUBLE PRECISION NOT NULL  --  Координата по вертикали
);

--  Припаркованные корабли
CREATE TABLE h_parked_ships
(
    r_ts     TIMESTAMP        NOT NULL,
    g_ts     DOUBLE PRECISION NOT NULL,
    --
    "ship"   INTEGER          NOT NULL, --  Корабль
    "island" INTEGER          NOT NULL  --  Остров, на котором припаркован корабль
);
--  Движущиеся корабли
CREATE TABLE h_moving_ships
(
    r_ts          TIMESTAMP        NOT NULL,
    g_ts          DOUBLE PRECISION NOT NULL,
    --
    "ship"        INTEGER          NOT NULL, --  Корабль
    "start"       INTEGER          NOT NULL, --  Остров отправления
    "destination" INTEGER          NOT NULL, --  Целевой остров
    "arrives_at"  DOUBLE PRECISION NOT NULL  --  Момент прибытия
);
--  Корабли, занятые погрузкой/разгрузкой
CREATE TABLE h_transferring_ships
(
    r_ts          TIMESTAMP        NOT NULL,
    g_ts          DOUBLE PRECISION NOT NULL,
    --
    "ship"        INTEGER          NOT NULL, --  Корабль
    "island"      INTEGER          NOT NULL, --  Остров
    "finish_time" DOUBLE PRECISION NOT NULL  --  Время окончания погрузки/разгрузки
);


--  Содержание трюмов кораблей
CREATE TABLE h_cargo
(
    r_ts       TIMESTAMP        NOT NULL,
    g_ts       DOUBLE PRECISION NOT NULL,
    --
    "ship"     INTEGER          NOT NULL, --  Корабль
    "item"     INTEGER          NOT NULL, --  Тип товара
    "quantity" DOUBLE PRECISION NOT NULL  --  Количество данного товара в трюме данного корабля
);

--  Корабли
CREATE TABLE h_ships
(
    r_ts       TIMESTAMP        NOT NULL,
    g_ts       DOUBLE PRECISION NOT NULL,
    --
    "id"       INTEGER          NOT NULL, --  Уникальный идентификатор
    "player"   INTEGER          NOT NULL, --  Игрок, которому принадлежит корабль
    "speed"    DOUBLE PRECISION NOT NULL, --  Скорость перемещения
    "capacity" DOUBLE PRECISION NOT NULL  --  Вместимость трюма
);

CREATE TABLE h_players
(
    r_ts    TIMESTAMP        NOT NULL,
    g_ts    DOUBLE PRECISION NOT NULL,
    --
    "id"    INTEGER          NOT NULL, --  Уникальный идентификатор
    "money" DOUBLE PRECISION NOT NULL  --  Текущее количество денег
);


CREATE OR REPLACE PROCEDURE save_history()
    LANGUAGE plpgsql AS
$$
DECLARE
    v_game_time DOUBLE PRECISION;
    v_ts        TIMESTAMP = LOCALTIMESTAMP;
BEGIN
    SELECT game_time INTO v_game_time FROM world.global;

    INSERT INTO h_contractors SELECT v_ts, v_game_time, t.* FROM world.contractors t;
    INSERT INTO h_contracts SELECT v_ts, v_game_time, t.* FROM world.contracts t;
    INSERT INTO h_storage SELECT v_ts, v_game_time, t.* FROM world.storage t;
    INSERT INTO h_islands SELECT v_ts, v_game_time, t.* FROM world.islands t;
    INSERT INTO h_parked_ships SELECT v_ts, v_game_time, t.* FROM world.parked_ships t;
    INSERT INTO h_moving_ships SELECT v_ts, v_game_time, t.* FROM world.moving_ships t;
    INSERT INTO h_transferring_ships SELECT v_ts, v_game_time, t.* FROM world.transferring_ships t;
    INSERT INTO h_cargo SELECT v_ts, v_game_time, t.* FROM world.cargo t;
    INSERT INTO h_ships SELECT v_ts, v_game_time, t.* FROM world.ships t;
    INSERT INTO h_players SELECT v_ts, v_game_time, t.* FROM world.players t;
END
$$;


/*
  Таблица из одной строки с текущим игроком. Заполняется при вызове процедуры think.
 */
DROP TABLE IF EXISTS my_player;
CREATE TABLE my_player
(
    id INTEGER NOT NULL
);

/*
  Опции игры.
 */
DROP TABLE IF EXISTS game_options;
CREATE TABLE game_options
(
    max_time               DOUBLE PRECISION NOT NULL,
    price_change_speed     DOUBLE PRECISION NOT NULL,
    transfer_time_per_unit DOUBLE PRECISION NOT NULL
);

INSERT INTO game_options(max_time, price_change_speed, transfer_time_per_unit)
VALUES (100000, 0.01, 1);

/**
  Расстояние между двумя островами.
 */
CREATE OR REPLACE FUNCTION get_distance(p_first INTEGER, p_second INTEGER) RETURNS DOUBLE PRECISION
    LANGUAGE plpgsql AS
$$
DECLARE
    v_result DOUBLE PRECISION;
BEGIN
    IF p_first = p_second THEN
        v_result = 0;
    ELSE
        SELECT LEAST(ABS(f.x - s.x), g.map_size - ABS(f.x - s.x)) + LEAST(ABS(f.y - s.y), g.map_size - ABS(f.y - s.y))
        INTO v_result
        FROM world.global g
                 JOIN world.islands f ON f.id = p_first
                 JOIN world.islands s ON s.id = p_second;
    END IF;

    RETURN v_result;
END
$$;

/*
 Сразу создадим VIEW со всеми расстояниями между городами.
 */
CREATE MATERIALIZED VIEW distances AS
SELECT v1.id v_island, v2.id c_island, get_distance(v1.id, v2.id) dist
FROM world.islands v1,
     world.islands v2
WHERE v1.id != v2.id;

/*
 расстояния между островами с лучшей разницей цены покупки/продажи
 */
CREATE VIEW distances_with_best_delta_price AS
SELECT d.v_island, d.c_island, d.dist, COALESCE(MAX(c.price_per_unit - v.price_per_unit), 0) delta_price
FROM distances d
         LEFT JOIN world.contractors c ON c.island = d.c_island AND c.type = 'customer'
         LEFT JOIN world.contractors v ON v.island = d.v_island AND v.type = 'vendor' AND v.item = c.item AND
                                          v.price_per_unit < c.price_per_unit
GROUP BY d.v_island, d.c_island, d.dist;


/*
  Возможные, но еще не заключенные контракты на поставку.
 */
DROP TABLE IF EXISTS my_customer_offers;
CREATE TABLE my_customer_offers
(
    -- уникальный идентификатор
    offer_id           INTEGER          NOT NULL,
    -- количество товара по контракту
    quantity           DOUBLE PRECISION NOT NULL,
    -- товар
    item               INTEGER          NOT NULL,
    -- покупатель
    customer           INTEGER          NOT NULL,
    -- цена за единицу
    price_per_unit     DOUBLE PRECISION NOT NULL,
    -- остров на который надо доставить товары по контракту
    island             INTEGER          NOT NULL,
    -- уникальный идентификатор контракта
    contract_id        INTEGER,
    -- приобретенное количество товара
    purchased_quantity DOUBLE PRECISION NOT NULL DEFAULT 0
);

/*
 Возможно еще не заключенные контракты на покупку
 */
DROP TABLE IF EXISTS my_vendor_offers;
CREATE TABLE my_vendor_offers
(
    offer_id       INTEGER          NOT NULL,
    -- количество товара
    quantity       DOUBLE PRECISION NOT NULL,
    -- товар
    item           INTEGER          NOT NULL,
    -- покупатель
    vendor         INTEGER          NOT NULL,
    -- цена за единицу
    price_per_unit DOUBLE PRECISION NOT NULL,
    -- остров на котором находится товар (если товар на корабле, значение будет пустым)
    island         INTEGER          NOT NULL,
    -- предложение на поставку для которого закупается товар
    customer_offer INTEGER,
    -- корабль который будет делать доставку
    ship           INTEGER
);


/*
  Дополнительная информация по кораблям.
 */
DROP TABLE IF EXISTS my_ships;
CREATE TABLE my_ships
(
    -- уникальный идентификатор корабля
    ship                   INTEGER          NOT NULL,
    speed                  DOUBLE PRECISION NOT NULL,
    capacity               DOUBLE PRECISION NOT NULL,

    -- примерная занятость корабля
    busy_until             DOUBLE PRECISION NOT NULL,
    -- остров на котором будет корабль когда выполнит последний контракт,
    -- а если контрактов у корабля нет - текущий остров.
    last_island            INTEGER          NOT NULL,

    -- текущий приказ доставки
    current_delivery_order INTEGER
);

DROP TABLE IF EXISTS my_ship_delivery_orders;
CREATE TABLE my_ship_delivery_orders
(
    id                 SERIAL  NOT NULL,
    ship               INTEGER NOT NULL,
    offer_id           INTEGER NOT NULL,
    next_delivery_step INTEGER NOT NULL DEFAULT 0
);


/*
  Создание предложения на покупку.
 */
CREATE OR REPLACE PROCEDURE make_vendor_offer(p_player_id INTEGER, p_vendor INTEGER, p_quantity DOUBLE PRECISION,
                                              p_customer_offer INTEGER)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_offer_id INTEGER;
BEGIN
    INSERT INTO actions.offers(contractor, quantity)
    VALUES (p_vendor, p_quantity)
    RETURNING id INTO v_offer_id;

    INSERT INTO my_vendor_offers(offer_id, quantity, item, vendor, price_per_unit, island, customer_offer)
    SELECT v_offer_id,
           p_quantity,
           c.item,
           c.id,
           c.price_per_unit,
           c.island,
           p_customer_offer
    FROM world.contractors c
    WHERE c.id = p_vendor;
END
$$;

/*
  Создание предложения на продажу.
 */
CREATE OR REPLACE FUNCTION make_customer_offer(p_player_id INTEGER, p_customer INTEGER, p_quantity DOUBLE PRECISION) RETURNS INTEGER
    LANGUAGE plpgsql AS
$$
DECLARE
    v_offer_id INTEGER;
BEGIN
    INSERT INTO actions.offers(contractor, quantity) VALUES (p_customer, p_quantity) RETURNING id INTO v_offer_id;

/*    RAISE NOTICE '[%] make_customer_offer customer = % , quantity = %, c_offer = %', p_player_id, p_customer, p_quantity, v_offer_id;*/

    INSERT INTO my_customer_offers(offer_id, quantity, item, customer, price_per_unit, island)
    SELECT v_offer_id,
           p_quantity,
           c.item,
           c.id,
           c.price_per_unit,
           c.island
    FROM world.contractors c
    WHERE c.id = p_customer;

    RETURN v_offer_id;
END
$$;

/*
  Первое формирование контрактов.
 */
CREATE OR REPLACE PROCEDURE make_contracts_0(p_player_id INTEGER)
    LANGUAGE plpgsql AS
$$
DECLARE
    r_ship              RECORD;
    r_pair              RECORD;
    v_dist              DOUBLE PRECISION;
    v_profit            DOUBLE PRECISION;
    v_best_profit       DOUBLE PRECISION;
    r_best_pair         RECORD;
    v_quantity          DOUBLE PRECISION;
    v_customer_offer_id INTEGER;
BEGIN

    FOR r_ship IN SELECT * FROM my_ships
        LOOP
            v_best_profit = NULL;

            FOR r_pair IN SELECT vendor.id               vendor_id,
                                 vendor.quantity         vendor_quantity,
                                 vendor.price_per_unit   vendor_price,
                                 vendor.island           vendor_island,
                                 customer.id             customer_id,
                                 customer.quantity       customer_quantity,
                                 customer.price_per_unit customer_price,
                                 customer.island         customer_island
                          FROM world.contractors vendor,
                               world.contractors customer
                          WHERE vendor.type = 'vendor'
                            AND customer.type = 'customer'
                            AND vendor.item = customer.item
                            AND vendor.price_per_unit < customer.price_per_unit
                            AND NOT EXISTS(SELECT 1
                                           FROM actions.offers
                                           WHERE contractor = customer.id
                                              OR contractor = vendor.id)
                LOOP
                    v_dist = get_distance(r_ship.last_island, r_pair.vendor_island) +
                             get_distance(r_pair.vendor_island, r_pair.customer_island);
                    v_profit = (r_pair.customer_price - r_pair.vendor_price) * r_ship.capacity * r_ship.speed /
                               (v_dist + .1);

                    IF v_profit > v_best_profit OR v_best_profit IS NULL THEN
                        v_best_profit = v_profit;
                        r_best_pair = r_pair;
                    END IF;
                END LOOP;

            IF v_best_profit IS NOT NULL THEN
                v_quantity = LEAST(r_best_pair.vendor_quantity, r_ship.capacity, r_best_pair.customer_quantity);
                v_quantity = TRUNC(v_quantity::NUMERIC, 8);

                v_customer_offer_id = make_customer_offer(p_player_id, r_best_pair.customer_id, v_quantity);
                CALL make_vendor_offer(p_player_id, r_best_pair.vendor_id, v_quantity, v_customer_offer_id);
            END IF;
        END LOOP;
END
$$;


/*
  Последующие формирования контрактов.
 */
CREATE OR REPLACE PROCEDURE make_contracts(p_player_id INTEGER, p_curr_game_time DOUBLE PRECISION)
    LANGUAGE plpgsql AS
$$
DECLARE
    r_ship              RECORD;
    r_pair              RECORD;
    v_dist              DOUBLE PRECISION;
    v_profit            DOUBLE PRECISION;
    v_best_profit       DOUBLE PRECISION;
    r_best_pair         RECORD;
    v_quantity          DOUBLE PRECISION;
    v_customer_offer_id INTEGER;
    v_flag              BOOLEAN;
BEGIN
    -- формируем следующие контракты только в случае если все контракты доставки привязаны к кораблям.
    SELECT TRUE
    INTO v_flag
    FROM my_vendor_offers
    WHERE ship IS NULL;

    IF v_flag THEN
        RETURN;
    END IF;

    FOR r_ship IN
        SELECT *
        FROM my_ships
        LOOP
            v_best_profit = NULL;

            FOR r_pair IN SELECT vendor.id               vendor_id,
                                 vendor.quantity         vendor_quantity,
                                 vendor.price_per_unit   vendor_price,
                                 vendor.island           vendor_island,
                                 customer.id             customer_id,
                                 customer.quantity       customer_quantity,
                                 customer.price_per_unit customer_price,
                                 customer.island         customer_island
                          FROM world.contractors vendor,
                               world.contractors customer
                          WHERE vendor.type = 'vendor'
                            AND customer.type = 'customer'
                            AND vendor.item = customer.item
                            AND vendor.price_per_unit < customer.price_per_unit
                            AND NOT EXISTS(SELECT 1 FROM world.contracts WHERE contractor = customer.id and player = p_player_id)
                            AND NOT EXISTS(SELECT 1
                                           FROM actions.offers
                                           WHERE contractor = customer.id
                                              OR contractor = vendor.id)
                LOOP
                    v_dist = get_distance(r_ship.last_island, r_pair.vendor_island) +
                             get_distance(r_pair.vendor_island, r_pair.customer_island);

                    v_quantity = LEAST(r_pair.vendor_quantity, r_ship.capacity, r_pair.customer_quantity);
                    v_quantity = TRUNC(v_quantity::NUMERIC, 8);

                    IF (v_dist / r_ship.speed) + v_quantity * 2 + 600 + GREATEST(r_ship.busy_until, p_curr_game_time) <
                       100000 THEN
                        v_profit = (r_pair.customer_price - r_pair.vendor_price) * r_ship.capacity * r_ship.speed /
                                   v_dist;

                        IF v_profit > v_best_profit OR v_best_profit IS NULL THEN
                            v_best_profit = v_profit;
                            r_best_pair = r_pair;
                        END IF;
                    END IF;
                END LOOP;

            IF v_best_profit IS NOT NULL THEN
                v_quantity = LEAST(r_best_pair.vendor_quantity, r_ship.capacity, r_best_pair.customer_quantity);
                v_quantity = TRUNC(v_quantity::NUMERIC, 8);

                v_customer_offer_id = make_customer_offer(p_player_id, r_best_pair.customer_id, v_quantity);
                CALL make_vendor_offer(p_player_id, r_best_pair.vendor_id, v_quantity, v_customer_offer_id);
            END IF;
        END LOOP;
END
$$;



CREATE OR REPLACE PROCEDURE move_ship(player_id INTEGER, ship_id INTEGER, island_id INTEGER)
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO actions.ship_moves (ship, destination)
    VALUES (ship_id, island_id);
END
$$;


/*
  Обработка событий.
 */
CREATE OR REPLACE PROCEDURE process_events(player_id INTEGER)
    LANGUAGE plpgsql AS
$$
DECLARE
    rec                  RECORD;
    v_offer_id           INTEGER;
    v_purchased_quantity DOUBLE PRECISION;
    r_customer           RECORD;
    r_best_customer      RECORD;
    v_profit             DOUBLE PRECISION;
    v_best_profit        DOUBLE PRECISION;
    r_vendor             RECORD;
    r_best_vendor        RECORD;
BEGIN
    FOR rec IN
        SELECT *
        FROM events.offer_rejected
        LOOP
            -- удаляем оферы не превратившиеся в контракты.
            DELETE FROM my_vendor_offers WHERE offer_id = rec.offer;
            DELETE FROM my_customer_offers WHERE offer_id = rec.offer;
            UPDATE my_vendor_offers SET customer_offer = NULL WHERE customer_offer = rec.offer;
        END LOOP;

    FOR rec IN
        SELECT *
        FROM events.contract_completed
        LOOP
            DELETE FROM my_customer_offers WHERE contract_id = rec.contract RETURNING offer_id INTO v_offer_id;
            DELETE FROM my_vendor_offers WHERE customer_offer = v_offer_id;
        END LOOP;

    FOR rec IN
        SELECT *
        FROM events.contract_started
        LOOP
            IF rec.contract IS NOT NULL THEN
                UPDATE my_customer_offers SET contract_id = rec.contract WHERE offer_id = rec.offer;
            END IF;
        END LOOP;

    -- обновляем purchased_quantity
    FOR rec IN SELECT * FROM my_customer_offers WHERE quantity > my_customer_offers.purchased_quantity
        LOOP
            SELECT COALESCE(SUM(quantity), 0)
            INTO v_purchased_quantity
            FROM my_vendor_offers
            WHERE customer_offer = rec.offer_id;

            IF v_purchased_quantity > rec.purchased_quantity THEN
                UPDATE my_customer_offers SET purchased_quantity = v_purchased_quantity WHERE offer_id = rec.offer_id;
            END IF;

            IF v_purchased_quantity < rec.quantity THEN
                -- пытаемся купить недостаток товаров
                v_best_profit = NULL;

                FOR r_vendor IN SELECT *
                                FROM world.contractors v
                                WHERE v.item = rec.item
                                  AND v.type = 'vendor'
                                  AND v.price_per_unit < rec.price_per_unit
                                  AND NOT EXISTS(SELECT 1 FROM actions.offers WHERE contractor = v.id)
                    LOOP
                        v_profit = (rec.price_per_unit - r_vendor.price_per_unit) *
                                   LEAST(rec.quantity - v_purchased_quantity, r_vendor.quantity) /
                                   get_distance(rec.island, r_vendor.island);

                        IF v_profit > v_best_profit OR v_best_profit IS NULL THEN
                            v_best_profit = v_profit;
                            r_best_vendor = r_vendor;
                        END IF;
                    END LOOP;

                IF v_best_profit IS NOT NULL THEN
                    CALL make_vendor_offer(player_id, r_best_vendor.id,
                                           LEAST(rec.quantity - v_purchased_quantity, r_vendor.quantity), rec.offer_id);
                END IF;
            END IF;
        END LOOP;

    -- пытаемся заключить контракты для избытка товаров
    FOR rec IN SELECT * FROM my_vendor_offers WHERE customer_offer IS NULL
        LOOP
            v_best_profit = NULL;

            FOR r_customer IN SELECT *
                              FROM world.contractors customer
                              WHERE customer.item = rec.item
                                AND customer.type = 'customer'
                                AND customer.price_per_unit > rec.price_per_unit
                                AND NOT EXISTS(SELECT 1 FROM world.contracts WHERE contractor = customer.id and player = player_id)
                LOOP
                    v_profit = (r_customer.price_per_unit - rec.price_per_unit) *
                               LEAST(rec.quantity, r_customer.quantity) /
                               (get_distance(rec.island, r_customer.island) + .1);

                    IF v_profit > v_best_profit OR v_best_profit IS NULL THEN
                        v_best_profit = v_profit;
                        r_best_customer = r_customer;
                    END IF;
                END LOOP;

            IF v_best_profit IS NOT NULL THEN
                v_offer_id = make_customer_offer(player_id, r_best_customer.id,
                                                 LEAST(rec.quantity, r_best_customer.quantity));

                UPDATE my_vendor_offers SET customer_offer = v_offer_id WHERE offer_id = rec.offer_id;
            END IF;
        END LOOP;


    -- для кораблей которые приплыли просто выводим логи
    FOR rec IN SELECT ps.*
               FROM events.ship_move_finished e
                        LEFT JOIN world.parked_ships ps ON ps.ship = e.ship
        LOOP

            /*            RAISE NOTICE '[%] ship_move_finished: ship = %, island = %', player_id, rec.ship, rec.island;*/
        END LOOP;

    -- для кораблей у которых выполнена разгрузка загрузка переводим на следующий шаг
    FOR rec IN SELECT o.*
               FROM events.transfer_completed e,
                    my_ships s,
                    my_ship_delivery_orders o
               WHERE e.ship = s.ship
                 AND o.id = s.current_delivery_order
        LOOP
            UPDATE my_ship_delivery_orders SET next_delivery_step = next_delivery_step + 1 WHERE id = rec.id;
        END LOOP;

END
$$;


/*
  Планирование доставок.
 */
CREATE OR REPLACE PROCEDURE process_deliveries(player_id INTEGER, p_curr_game_time DOUBLE PRECISION)
    LANGUAGE plpgsql AS
$$
DECLARE
    r_options            RECORD;
    rec                  RECORD;
    r_ship               RECORD;
    r_best_ship          RECORD;
    v_delivery_time      DOUBLE PRECISION;
    v_best_delivery_time DOUBLE PRECISION;
    v_order_counts       INTEGER;
BEGIN
    SELECT * INTO r_options FROM game_options;

    FOR rec IN SELECT v.*, c.island customer_island
               FROM my_vendor_offers v,
                    my_customer_offers c
               WHERE c.offer_id = v.customer_offer
                 AND v.ship IS NULL
                 AND c.contract_id IS NOT NULL
        LOOP
            v_best_delivery_time = r_options.max_time;
            -- ищем ближайший корабль который может вместить груз, главное что бы корабль освободился и смог доставить груз до истечения времени

            FOR r_ship IN SELECT * FROM my_ships WHERE rec.quantity <= my_ships.capacity
                LOOP
                    SELECT COUNT(*) INTO v_order_counts FROM my_ship_delivery_orders WHERE ship = r_ship.ship;
                    IF v_order_counts > 5 THEN
                        CONTINUE;
                    ELSEIF v_order_counts = 0 THEN
                        UPDATE my_ships
                        SET busy_until = 0
                        WHERE ship = r_ship.ship;
                    END IF;

                    v_delivery_time = (get_distance(r_ship.last_island, rec.island) +
                                       get_distance(rec.island, rec.customer_island)) / r_ship.speed +
                                      2 * rec.quantity;

                    IF v_delivery_time + GREATEST(p_curr_game_time, r_ship.busy_until) + 600 < r_options.max_time AND
                       v_delivery_time < v_best_delivery_time THEN
                        v_best_delivery_time = v_delivery_time;
                        r_best_ship = r_ship;
                    END IF;

                END LOOP;

            IF v_best_delivery_time < r_options.max_time THEN
                UPDATE my_ships
                SET last_island = rec.customer_island,
                    busy_until  = GREATEST(busy_until, p_curr_game_time) + v_best_delivery_time + 600
                WHERE ship = r_best_ship.ship;

                INSERT INTO my_ship_delivery_orders(ship, offer_id) VALUES (r_best_ship.ship, rec.offer_id);
                UPDATE my_vendor_offers SET ship = r_best_ship.ship WHERE offer_id = rec.offer_id;
            END IF;

        END LOOP;
END
$$;


/*
  Планирование доставок.
 */
CREATE OR REPLACE PROCEDURE process_ships_orders(player_id INTEGER)
    LANGUAGE plpgsql AS
$$
DECLARE
    r_ship       RECORD;
    r_ship_order RECORD;
    v_order_id   INTEGER;
BEGIN
    FOR r_ship IN SELECT s.*
                  FROM my_ships s
                           LEFT JOIN my_ship_delivery_orders o ON o.id = s.current_delivery_order
                  WHERE o.next_delivery_step IS NULL
                     OR o.next_delivery_step = 4
        LOOP
            IF r_ship.current_delivery_order IS NOT NULL THEN
                DELETE FROM my_ship_delivery_orders WHERE id = r_ship.current_delivery_order;
            END IF;

            SELECT id INTO v_order_id FROM my_ship_delivery_orders WHERE ship = r_ship.ship ORDER BY id LIMIT 1;
            UPDATE my_ships SET current_delivery_order = v_order_id WHERE ship = r_ship.ship;
        END LOOP;

    FOR r_ship_order IN SELECT o.next_delivery_step,
                               o.ship,
                               v.quantity,
                               ps.island ship_island,
                               v.island  vendor_island,
                               c.island  customer_island,
                               v.item,
                               o.id
                        FROM my_ships s,
                             world.parked_ships ps,
                             my_ship_delivery_orders o,
                             my_vendor_offers v,
                             my_customer_offers c
                        WHERE s.current_delivery_order = o.id
                          AND o.offer_id = v.offer_id
                          AND v.customer_offer = c.offer_id
                          AND s.ship = ps.ship
                          AND NOT EXISTS(SELECT * FROM actions.transfers WHERE o.ship = s.ship)
                          AND NOT EXISTS(SELECT * FROM actions.ship_moves WHERE o.ship = s.ship)
        LOOP
            IF r_ship_order.next_delivery_step = 0 THEN
                IF r_ship_order.ship_island != r_ship_order.vendor_island THEN
                    -- плыть в сторону острова погрузки
                    CALL move_ship(player_id, r_ship_order.ship, r_ship_order.vendor_island);
                ELSE
                    -- уже приплыли или сразу были на острове погрузки
                    r_ship_order.next_delivery_step = 1;
                    UPDATE my_ship_delivery_orders SET next_delivery_step = 1 WHERE id = r_ship_order.id;
                END IF;
            END IF;

            IF r_ship_order.next_delivery_step = 1 THEN
                -- погрузка на корабль

/*                RAISE NOTICE '[%] LOAD SHIP %, ITEM %, Q %', player_id, r_ship_order.ship, r_ship_order.item, r_ship_order.quantity;*/

                INSERT INTO actions.transfers(ship, item, quantity, direction)
                VALUES (r_ship_order.ship, r_ship_order.item, r_ship_order.quantity, 'load');
            END IF;

            IF r_ship_order.next_delivery_step = 2 THEN
                IF r_ship_order.ship_island != r_ship_order.customer_island THEN
                    -- плыть в сторону острова погрузки
                    CALL move_ship(player_id, r_ship_order.ship, r_ship_order.customer_island);
                ELSE
                    -- уже приплыли или сразу были на острове разгрузки
                    r_ship_order.next_delivery_step = 3;
                    UPDATE my_ship_delivery_orders SET next_delivery_step = 3 WHERE id = r_ship_order.id;
                END IF;
            END IF;

            IF r_ship_order.next_delivery_step = 3 THEN
                -- разгрузка

/*                RAISE NOTICE '[%] UNLOAD SHIP %, ITEM %, Q %', player_id, r_ship_order.ship, r_ship_order.item, r_ship_order.quantity;*/

                INSERT INTO actions.transfers(ship, item, quantity, direction)
                VALUES (r_ship_order.ship, r_ship_order.item, r_ship_order.quantity, 'unload');
            END IF;

            IF r_ship_order.next_delivery_step = 4 THEN
                -- разгрузка завершена
                DELETE FROM my_ship_delivery_orders WHERE id = r_ship_order.id;
                UPDATE my_ships SET current_delivery_order = NULL WHERE my_ships.ship = r_ship_order.ship;
            END IF;
        END LOOP;
END
$$;


CREATE OR REPLACE PROCEDURE think(player_id INTEGER)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_curr_game_time DOUBLE PRECISION;
    v_my_money       DOUBLE PRECISION;
    v_error_message  TEXT;
BEGIN
    -- CALL save_history();

    SELECT game_time
    INTO v_curr_game_time
    FROM world.global;

    SELECT money
    INTO v_my_money
    FROM world.players
    WHERE id = player_id;

    INSERT INTO actions.wait(until) VALUES (v_curr_game_time + 5000);

    IF v_curr_game_time = 0 THEN
        -- REFRESH MATERIALIZED VIEW distances;

        INSERT INTO my_player(id)
        VALUES (player_id);

        INSERT INTO my_ships(ship, speed, capacity, busy_until, last_island)
        SELECT s.id, s.speed, s.capacity, v_curr_game_time, ps.island
        FROM world.ships s
                 JOIN world.parked_ships ps ON ps.ship = s.id
        WHERE s.player = player_id;

        CALL make_contracts_0(player_id);
    ELSE
        CALL process_events(player_id);
        CALL make_contracts(player_id, v_curr_game_time);
        CALL process_deliveries(player_id, v_curr_game_time);
        CALL process_ships_orders(player_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, ERROR! %', player_id, v_curr_game_time, v_error_message;
END
$$;