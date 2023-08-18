-- region исторические таблицы
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

-- events
CREATE TABLE h_wait_finished
(
    r_ts   TIMESTAMP        NOT NULL,
    g_ts   DOUBLE PRECISION NOT NULL,
    --
    "time" DOUBLE PRECISION NOT NULL, --  Время, когда произошло событие
    "wait" INTEGER          NOT NULL  --  Идентификатор действия
);

CREATE TABLE h_ship_move_finished
(
    r_ts   TIMESTAMP        NOT NULL,
    g_ts   DOUBLE PRECISION NOT NULL,
    --
    "time" DOUBLE PRECISION NOT NULL, --  Время, когда произошло событие
    "ship" INTEGER          NOT NULL  --  Припарковавшийся корабль
);

CREATE TABLE h_transfer_completed
(
    r_ts   TIMESTAMP        NOT NULL,
    g_ts   DOUBLE PRECISION NOT NULL,
    --
    "time" DOUBLE PRECISION NOT NULL, --  Время, когда произошло событие
    "ship" INTEGER          NOT NULL  --  Корабль
);

CREATE TABLE h_contract_started
(
    r_ts       TIMESTAMP        NOT NULL,
    g_ts       DOUBLE PRECISION NOT NULL,
    --
    "time"     DOUBLE PRECISION NOT NULL, --  Время, когда произошло событие
    "offer"    INTEGER          NOT NULL, --  Предложение
    "contract" INTEGER                    --  Контракт, который был начат. Может отсутствовать, если контракт также мгновенно завершился - при покупке.
);

CREATE TABLE h_offer_rejected
(
    r_ts    TIMESTAMP        NOT NULL,
    g_ts    DOUBLE PRECISION NOT NULL,
    --
    "time"  DOUBLE PRECISION NOT NULL, --  Время, когда произошло событие
    "offer" INTEGER          NOT NULL  --  Предложение
);

CREATE TABLE h_contract_completed
(
    r_ts       TIMESTAMP        NOT NULL,
    g_ts       DOUBLE PRECISION NOT NULL,
    --
    "time"     DOUBLE PRECISION NOT NULL, --  Время, когда произошло событие
    "contract" INTEGER          NOT NULL  --  Контракт, который был завершен
);


CREATE TABLE h_my_ship_delivery_before
(
    r_ts     TIMESTAMP        NOT NULL,
    g_ts     DOUBLE PRECISION NOT NULL,
    --
    id       INTEGER          NOT NULL,
    ship     INTEGER          NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    v_island INTEGER          NOT NULL,
    c_island INTEGER          NOT NULL,
    item     INTEGER          NOT NULL,
    -- 0 - создана, 1 - дана команда на погрузку, 2 - в процессе погрузки,  3 - погружена, 4 - дана команда на разгрузку, 5 - в процессе разгрузки
    -- после разгрузки надо удалять из таблицы
    state    INTEGER          NOT NULL DEFAULT 0
);

CREATE TABLE h_my_ship_delivery_after
(
    r_ts     TIMESTAMP        NOT NULL,
    g_ts     DOUBLE PRECISION NOT NULL,
    --
    id       INTEGER          NOT NULL,
    ship     INTEGER          NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    v_island INTEGER          NOT NULL,
    c_island INTEGER          NOT NULL,
    item     INTEGER          NOT NULL,
    -- 0 - создана, 1 - дана команда на погрузку, 2 - в процессе погрузки,  3 - погружена, 4 - дана команда на разгрузку, 5 - в процессе разгрузки
    -- после разгрузки надо удалять из таблицы
    state    INTEGER          NOT NULL DEFAULT 0
);


-- actions


CREATE TABLE h_wait
(
    r_ts    TIMESTAMP          NOT NULL,
    g_ts    DOUBLE PRECISION   NOT NULL,
    --
    "id"    SERIAL PRIMARY KEY NOT NULL, --  Идентификатор действия
    "until" DOUBLE PRECISION   NOT NULL  --  Момент времени в который ожидание должно закончиться
);
CREATE TABLE h_transfers
(
    r_ts        TIMESTAMP                      NOT NULL,
    g_ts        DOUBLE PRECISION               NOT NULL,
    --
    "ship"      INTEGER                        NOT NULL, --  Корабль, на/с которого переносить товар
    "item"      INTEGER                        NOT NULL, --  Тип товара, который нужно переносить
    "quantity"  DOUBLE PRECISION               NOT NULL, --  Количество товара, которое нужно перенести
    "direction" "actions"."transfer_direction" NOT NULL  --  Направление - погрузка/разгрузка
);

CREATE TABLE h_offers
(
    r_ts         TIMESTAMP        NOT NULL,
    g_ts         DOUBLE PRECISION NOT NULL,
    --
    "id"         INTEGER          NOT NULL, --  Идентификатор предложения
    "contractor" INTEGER          NOT NULL, --  Контрагент
    "quantity"   DOUBLE PRECISION NOT NULL  --  Количество покупаемого/продаваемого товара
);

CREATE TABLE h_ship_moves
(
    r_ts          TIMESTAMP        NOT NULL,
    g_ts          DOUBLE PRECISION NOT NULL,
    --
    "ship"        INTEGER          NOT NULL, --  Корабль
    "destination" INTEGER          NOT NULL  --  Целевой остров
);

CREATE OR REPLACE PROCEDURE save_action_history(r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_game_time DOUBLE PRECISION = r_global.game_time;
    v_ts        TIMESTAMP        = LOCALTIMESTAMP;
BEGIN
    INSERT INTO h_wait SELECT v_ts, v_game_time, t.* FROM actions.wait t;
    INSERT INTO h_transfers SELECT v_ts, v_game_time, t.* FROM actions.transfers t;
    INSERT INTO h_offers SELECT v_ts, v_game_time, t.* FROM actions.offers t;
    INSERT INTO h_ship_moves SELECT v_ts, v_game_time, t.* FROM actions.ship_moves t;

    INSERT INTO h_my_ship_delivery_after SELECT v_ts, v_game_time, t.* FROM my_ship_delivery t;
END
$$;


CREATE OR REPLACE PROCEDURE save_history(r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_game_time DOUBLE PRECISION = r_global.game_time;
    v_ts        TIMESTAMP        = LOCALTIMESTAMP;
BEGIN
    INSERT INTO h_players SELECT v_ts, v_game_time, t.* FROM world.players t;

    INSERT INTO h_contractors SELECT v_ts, v_game_time, t.* FROM world.contractors t;
    INSERT INTO h_contracts SELECT v_ts, v_game_time, t.* FROM world.contracts t;
    INSERT INTO h_storage SELECT v_ts, v_game_time, t.* FROM world.storage t;
    INSERT INTO h_islands SELECT v_ts, v_game_time, t.* FROM world.islands t;
    INSERT INTO h_parked_ships SELECT v_ts, v_game_time, t.* FROM world.parked_ships t;
    INSERT INTO h_moving_ships SELECT v_ts, v_game_time, t.* FROM world.moving_ships t;
    INSERT INTO h_transferring_ships SELECT v_ts, v_game_time, t.* FROM world.transferring_ships t;
    INSERT INTO h_cargo SELECT v_ts, v_game_time, t.* FROM world.cargo t;
    INSERT INTO h_ships SELECT v_ts, v_game_time, t.* FROM world.ships t;
    INSERT INTO h_my_ship_delivery_before SELECT v_ts, v_game_time, t.* FROM my_ship_delivery t;

    -- events
    INSERT INTO h_wait_finished SELECT v_ts, v_game_time, t.* FROM events.wait_finished t;
    INSERT INTO h_ship_move_finished SELECT v_ts, v_game_time, t.* FROM events.ship_move_finished t;
    INSERT INTO h_transfer_completed SELECT v_ts, v_game_time, t.* FROM events.transfer_completed t;
    INSERT INTO h_contract_started SELECT v_ts, v_game_time, t.* FROM events.contract_started t;
    INSERT INTO h_offer_rejected SELECT v_ts, v_game_time, t.* FROM events.offer_rejected t;
    INSERT INTO h_contract_completed SELECT v_ts, v_game_time, t.* FROM events.contract_completed t;
END
$$;



-- endregion


-- Таблица из одной строки с идентификатором игрока, для удобства использования с view.
CREATE TABLE my_player
(
    id INTEGER NOT NULL
);

-- region вспомогательные view

CREATE OR REPLACE VIEW customers AS
SELECT t.id, t.island, t.item, t.price_per_unit, t.quantity
FROM world.contractors t
WHERE t.type = 'customer';

CREATE OR REPLACE VIEW vendors AS
SELECT t.id, t.island, t.item, t.price_per_unit, t.quantity
FROM world.contractors t
WHERE t.type = 'vendor';

--region аналитика

-- по товару
CREATE TABLE item_analytics
(
    -- товар
    item               INTEGER NOT NULL,
    -- минимальная цена продажи
    min_sale_price     DOUBLE PRECISION,
    -- максимальная цена покупки
    max_purchase_price DOUBLE PRECISION
);

-- по товару и острову
CREATE TABLE item_island_analytics
(
    -- товар
    item               INTEGER NOT NULL,
    -- остров
    island             INTEGER NOT NULL,
    -- средняя цена продажи на острове
    avg_price_per_unit DOUBLE PRECISION,
    -- тип острова (продавец или покупатель)
    type               world.contractor_type
);

-- Обновить аналитику
CREATE OR REPLACE PROCEDURE update_analytics(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message  TEXT;
    v_price_fraction DOUBLE PRECISION = 0.85;
BEGIN
    -- Через v_price_fraction будем регулировать закупки. Если объем предложения больше
    -- объема спроса v_price_fraction будем уменьшать, иначе - увеличивать.
    TRUNCATE item_analytics;

    IF r_global.game_time > 25000 THEN
        v_price_fraction = 0.80;
    END IF;

    IF r_global.game_time > 50000 THEN
        v_price_fraction = 0.70;
    END IF;

    INSERT INTO item_analytics
    WITH cp AS (SELECT c.item, PERCENTILE_CONT(v_price_fraction) WITHIN GROUP (ORDER BY price_per_unit) s_price
                FROM customers c
                GROUP BY c.item),
         vp AS (SELECT v.item, PERCENTILE_CONT(v_price_fraction) WITHIN GROUP (ORDER BY price_per_unit DESC) p_price
                FROM vendors v
                GROUP BY v.item)
    SELECT cp.item, cp.s_price, LEAST(vp.p_price, cp.s_price)
    FROM cp,
         vp
    WHERE cp.item = vp.item;


    TRUNCATE TABLE item_island_analytics;

    INSERT INTO item_island_analytics(item, island, avg_price_per_unit, type)
    SELECT c.item, c.island, AVG(c.price_per_unit), 'customer'
    FROM customers c
             JOIN item_analytics a ON a.item = c.item AND c.price_per_unit >= a.min_sale_price
    GROUP BY c.item, c.island;

    INSERT INTO item_island_analytics(item, island, avg_price_per_unit, type)
    SELECT v.item, v.island, AVG(v.price_per_unit), 'vendor'
    FROM vendors v
             JOIN item_analytics a ON a.item = v.item AND v.price_per_unit <= a.max_purchase_price
    GROUP BY v.item, v.island;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, update_analytics error! %', player_id, r_global.game_time, v_error_message;
END
$$;


-- endregion


--  Опции игры.
CREATE TABLE game_options
(
    max_time               DOUBLE PRECISION NOT NULL,
    price_change_speed     DOUBLE PRECISION NOT NULL,
    transfer_time_per_unit DOUBLE PRECISION NOT NULL
);

INSERT INTO game_options(max_time, price_change_speed, transfer_time_per_unit)
VALUES (100000, 0.01, 1);

-- Расстояние между двумя островами.
CREATE OR REPLACE FUNCTION get_distance(p_first INTEGER, p_second INTEGER) RETURNS DOUBLE PRECISION
    STABLE
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



-- Формирование запросов на продажу.
CREATE OR REPLACE PROCEDURE make_customers_contracts(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message     TEXT;
    rec                 RECORD;
    v_delivery_quantity DOUBLE PRECISION;
BEGIN
    <<customers_loop>>
    FOR rec IN
        SELECT c.id, c.island, c.quantity, c.price_per_unit, c.item, COALESCE(s.quantity, 0) AS storage_quantity
        FROM customers c
                 LEFT JOIN world.storage s ON s.island = c.island AND s.item = c.item AND s.player = player_id
                 JOIN item_analytics pr ON pr.item = c.item
        WHERE NOT EXISTS(SELECT 1
                         FROM world.contracts cc
                         WHERE cc.player = player_id
                           AND cc.contractor = c.id)
          AND pr.min_sale_price < c.price_per_unit
        ORDER BY c.price_per_unit DESC
        LOOP
            IF rec.quantity < rec.storage_quantity THEN
                INSERT INTO actions.offers(contractor, quantity) VALUES (rec.id, rec.quantity);
            ELSE
                SELECT COALESCE(SUM(quantity), 0)
                INTO v_delivery_quantity
                FROM my_ship_delivery d
                WHERE d.item = rec.item
                  AND d.c_island = rec.island;

                IF rec.storage_quantity + v_delivery_quantity > 0 THEN
                    INSERT INTO actions.offers(contractor, quantity)
                    VALUES (rec.id, LEAST(rec.quantity, v_delivery_quantity + rec.storage_quantity));
                END IF;
            END IF;
        END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, make_customers_contracts error! %', player_id, r_global.game_time, v_error_message;
END
$$;



-- Формирование запросов на покупки.
CREATE OR REPLACE PROCEDURE make_purchases(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message TEXT;
    rec             RECORD;
BEGIN
    IF 100000 - r_global.game_time < 4000 THEN
        -- прекращаем покупки в самом конце. надо допродать уже купленное.
        RETURN;
    END IF;

    FOR rec IN WITH delivery AS (SELECT v_island, SUM(quantity) AS total FROM my_ship_delivery GROUP BY v_island)
               SELECT v.*
               FROM vendors v
                        JOIN item_analytics pr ON pr.item = v.item AND v.price_per_unit < pr.max_purchase_price
                        LEFT JOIN world.storage s ON s.item = v.item AND s.island = v.island AND s.player = player_id
                        LEFT JOIN delivery ON delivery.v_island = v.island
               WHERE COALESCE(s.quantity, 0) < 1000 + COALESCE(delivery.total, 0)
               ORDER BY v.item, v.price_per_unit
        LOOP
        -- покупаем пока все подряд, что можно продать дороже.
        -- возможно надо сделать ограничение: если нет корабля для обслуживания вывоза с этого острова покупку не делать.
            INSERT INTO actions.offers(contractor, quantity) VALUES (rec.id, TRUNC(rec.quantity::NUMERIC, 5));
        END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, make_purchases error! %', player_id, r_global.game_time, v_error_message;
END
$$;



CREATE TABLE my_ship_delivery
(
    id       SERIAL           NOT NULL,
    ship     INTEGER          NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    v_island INTEGER          NOT NULL,
    c_island INTEGER          NOT NULL,
    item     INTEGER          NOT NULL,
    -- 0 - создана, 1 - дана команда на погрузку, 2 - в процессе погрузки,  3 - погружена, 4 - дана команда на разгрузку, 5 - в процессе разгрузки
    -- после разгрузки надо удалять из таблицы
    state    INTEGER          NOT NULL DEFAULT 0
);


-- обработка событий погрузки, разгрузки и формирование команд на разгрузку погрузку.
CREATE OR REPLACE PROCEDURE process_transfers_events(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message TEXT;
    r_ship          RECORD;
    rec             RECORD;
BEGIN

    --region обработка событий
    FOR r_ship IN SELECT ps.ship, ps.island, s.capacity, s.speed
                  FROM events.transfer_completed e
                           JOIN world.parked_ships ps ON ps.ship = e.ship
                           JOIN world.ships s ON s.id = e.ship
        LOOP
            DELETE FROM my_ship_delivery WHERE state IN (4, 5) AND ship = r_ship.ship;
            UPDATE my_ship_delivery SET state = 3 WHERE ship = r_ship.ship AND state IN (1, 2);
        END LOOP;
    -- endregion

    --region синхронизация статуса для погрузок находящихся еще в процессе
    UPDATE my_ship_delivery
    SET state = state + 1
    WHERE ship IN (SELECT ts.ship
                   FROM world.transferring_ships ts
                            JOIN world.ships ship ON ship.id = ts.ship
                   WHERE ship.player = player_id
                     AND (state = 1 OR state = 4));
    --endregion


    -- здесь не должно быть записей в состоянии 1 и 4, т.к. еще новые команды не формировались.
    FOR rec IN SELECT * FROM my_ship_delivery WHERE state IN (1, 4)
        LOOP
            RAISE NOTICE '[%] time %, process_transfers state error! %', player_id, r_global.game_time, rec;
        END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, process_transfers error! %', player_id, r_global.game_time, v_error_message;
END
$$;


-- обработка событий погрузки, разгрузки и формирование команд на разгрузку погрузку.
CREATE OR REPLACE PROCEDURE process_transfers_commands(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message TEXT;
    rec             RECORD;
BEGIN

    --region новые команды на погрузку
    FOR rec IN (SELECT *
                FROM my_ship_delivery
                WHERE id IN (SELECT MIN(id)
                             FROM my_ship_delivery d
                                      JOIN world.parked_ships ps ON ps.island = d.v_island AND ps.ship = d.ship
                             WHERE d.state = 0
                             GROUP BY d.ship))
        LOOP
            INSERT INTO actions.transfers(ship, item, quantity, direction)
            VALUES (rec.ship, rec.item, rec.quantity, 'load');

            UPDATE my_ship_delivery SET state = 1 WHERE id = rec.id;
        END LOOP;
    --endregion

    --region новые команды на разгрузку
    FOR rec IN (SELECT DISTINCT d.ship, d.item, c.quantity
                FROM my_ship_delivery d
                         -- корабль припаркован рядом с островом назначения
                         JOIN world.parked_ships p ON d.ship = p.ship AND d.c_island = p.island
                         JOIN world.cargo c ON c.ship = d.ship AND c.item = d.item
                WHERE d.state = 3)
        LOOP
            INSERT INTO actions.transfers(ship, item, quantity, direction)
            VALUES (rec.ship, rec.item, rec.quantity, 'unload');

            UPDATE my_ship_delivery SET state = 4 WHERE ship = rec.ship AND item = rec.item;
        END LOOP;
    --endregion

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, process_transfers error! %', player_id, r_global.game_time, v_error_message;
END
$$;


-- обработка событий движения и отправка загруженных кораблей
CREATE OR REPLACE PROCEDURE process_moves(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message     TEXT;
    r_ship              RECORD;
    v_cargo_quantity    DOUBLE PRECISION;
    v_delivery_quantity DOUBLE PRECISION;
    v_delivery_c_island INTEGER;
BEGIN
    -- загруженные корабли должны отправиться к покупателям
    -- если корабль загружен больше чем на 90% - отправляем корабль
    -- если не загружен полностью, а загрузка завершена не в этот ход отправляем корабль в любом случае.

    FOR r_ship IN SELECT ship.*, ps.island
                  FROM world.ships ship
                           -- корабль припаркован
                           JOIN world.parked_ships ps ON ps.ship = ship.id
                  WHERE ship.player = player_id
                    -- есть погрузки привязанные к кораблю находящиеся уже на корабле и корабле
                    AND EXISTS(SELECT 1
                               FROM my_ship_delivery d
                               WHERE d.ship = ship.id
                                 AND d.state = 3
                                 AND d.v_island = ps.island)
                    -- нет запланированных погрузок или находящихся в процессе
                    AND NOT EXISTS(SELECT 1 FROM my_ship_delivery d WHERE d.ship = ship.id AND d.state IN (0, 1, 2))
        LOOP
            SELECT SUM(c.quantity) INTO v_cargo_quantity FROM world.cargo c WHERE c.ship = r_ship.id;

            SELECT SUM(d.quantity), MIN(d.c_island)
            FROM my_ship_delivery d
            WHERE d.ship = r_ship.id
            INTO v_delivery_quantity, v_delivery_c_island;

            IF ABS(v_cargo_quantity - v_delivery_quantity) > 1 THEN
                RAISE NOTICE '[%] time %, process_moves error! % % %', player_id, r_global.game_time, 'cargo_quantity != delivery_quantity !!!', v_cargo_quantity, v_delivery_quantity;
            END IF;

            IF v_cargo_quantity / r_ship.capacity > 0.9 THEN
                INSERT INTO actions.ship_moves(ship, destination) VALUES (r_ship.id, v_delivery_c_island);
            ELSE
                IF NOT EXISTS(SELECT 1 FROM actions.transfers WHERE ship = r_ship.id) THEN
                    INSERT INTO actions.ship_moves(ship, destination) VALUES (r_ship.id, v_delivery_c_island);
                END IF;
            END IF;
        END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, process_moves error! %', player_id, r_global.game_time, v_error_message;
END
$$;


-- Планирование доставок
CREATE OR REPLACE PROCEDURE process_deliveries(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message  TEXT;
    r_options        RECORD;
    r_road           RECORD;
    r_ship           RECORD;
    v_v_island       INTEGER;
    v_c_island       INTEGER;
    v_quantity       DOUBLE PRECISION;
    v_total_quantity DOUBLE PRECISION;
BEGIN
    SELECT * INTO r_options FROM game_options;
    -- с островов где есть купленные товары надо построить оптимальные маршруты передвижения товаров где есть лучшие покупатели на эти товары.
    -- везем все товары к лучшему покупателю (совокупность цена + расстояние).
    -- если на острове покупателя накопились товары - временно исключаем покупателя из закупок.
    -- корабли не должны перемещаться незаполненными.

    --region для кораблей которым уже назначена доставка, но суммарный вес доставки еще не полностью заполнил корабль пытаемся докинуть товаров.
    IF FALSE THEN
        FOR r_ship IN (WITH d AS (SELECT d.ship, d.v_island, d.c_island, SUM(d.quantity) total_quantity
                                  FROM my_ship_delivery d
                                  WHERE d.state IN (0, 1, 2, 3)
                                  GROUP BY d.ship, d.v_island, d.c_island)
                       SELECT ship.*, d.v_island, d.c_island, d.total_quantity
                       FROM world.ships ship
                                JOIN d ON d.ship = ship.id AND d.total_quantity / ship.capacity < 0.9
                           -- доставки планируются только для припаркованных кораблей
                                LEFT JOIN world.parked_ships ps ON ps.ship = ship.id
                           -- корабль может загружаться
                                LEFT JOIN world.transferring_ships ts ON ts.ship = ship.id
                       WHERE ship.player = player_id
                         AND COALESCE(ps.island, ts.island) = d.v_island)
            LOOP
                v_total_quantity = r_ship.total_quantity;
                <<roads_loop_0>>
                FOR r_road IN WITH
                                  -- то что уже запланировано для погрузки и этого как бы уже нет на складе
                                  total_ship_delivery AS (SELECT v_island, item, SUM(quantity) total_quantity
                                                          FROM my_ship_delivery d
                                                          WHERE d.state IN (0, 1)
                                                          GROUP BY d.item, v_island),
                                  -- откуда и что можем везти
                                  v AS (SELECT s.island,
                                               s.item,
                                               s.quantity - COALESCE(tsd.total_quantity, 0) AS quantity,
                                               v.price_per_unit
                                        FROM world.storage s
                                                 JOIN vendors v ON s.island = v.island AND v.item = s.item
                                                 LEFT JOIN total_ship_delivery tsd ON tsd.v_island = v.island AND tsd.item = v.item
                                        WHERE s.player = player_id
                                          -- учитываем то что уже запланировано
                                          AND s.quantity - COALESCE(tsd.total_quantity, 0) > r_ship.capacity * 0.1
                                          AND s.island = r_ship.v_island),
                                  -- куда можем везти
                                  c AS (SELECT c.island, c.item, c.price_per_unit
                                        FROM customers c
                                        WHERE c.island = r_ship.c_island
                                          -- исключаем покупателей у которых и так много товаров в очереди
                                          AND NOT EXISTS(SELECT 1
                                                         FROM world.storage s
                                                         WHERE s.item = c.item
                                                           AND s.island = c.island
                                                           AND s.player = player_id
                                                           AND s.quantity > 3000 -- здесь надо еще смотреть на текущее игровое время и сложившуюся скорость потребления товаров на острове.
                                            ))
                              SELECT v.item,
                                     v.island                                               v_island,
                                     v.quantity,
                                     c.island                                               c_island,
                                     LEAST(v.quantity, r_ship.capacity) * (c.price_per_unit - v.price_per_unit) /
                                     (r_ship.capacity * 2
                                         + get_distance(r_ship.v_island, v.island) / r_ship.speed
                                         + get_distance(v.island, c.island) / r_ship.speed) factor
                              FROM v
                                       JOIN c ON v.item = c.item AND v.price_per_unit < c.price_per_unit
                              ORDER BY factor DESC
                    LOOP
                        v_quantity = TRUNC(LEAST(r_road.quantity, r_ship.capacity - v_total_quantity)::NUMERIC, 5);

                        INSERT INTO my_ship_delivery(ship, quantity, v_island, c_island, item)
                        VALUES (r_ship.id, v_quantity, r_road.v_island, r_road.c_island, r_road.item);

                        v_total_quantity = v_total_quantity + v_quantity;

                        IF ABS(v_total_quantity - r_ship.capacity) < 1 THEN
                            EXIT roads_loop_0;
                        END IF;
                    END LOOP;
            END LOOP;
    END IF;
    -- endregion

    --region для кораблей которым еще не назначена доставка пытаемся подобрать новую доставку без ограничения откуда и куда плывем
    FOR r_ship IN SELECT ship.*, ps.island
                  FROM world.ships ship
                           -- доставки планируются только для припаркованных кораблей
                           JOIN world.parked_ships ps ON ps.ship = ship.id
                  WHERE ship.player = player_id
                    AND NOT EXISTS(SELECT 1 FROM my_ship_delivery d WHERE d.ship = ship.id)
                  ORDER BY ship.capacity * ship.speed DESC
        LOOP
            v_total_quantity = 0;

            <<roads_loop>>
            FOR r_road IN WITH
                              -- то что уже запланировано для погрузки и этого как бы уже нет на складе
                              total_ship_delivery AS (SELECT v_island, item, SUM(quantity) total_quantity
                                                      FROM my_ship_delivery d
                                                           -- или еще не дана команда на погрузку, или команда только что дана, и груз еще находится в хранилище острова.
                                                      WHERE d.state IN (0, 1)
                                                      GROUP BY d.item, v_island),
                              -- откуда и что можем везти
                              v AS (SELECT s.island,
                                           s.item,
                                           s.quantity - COALESCE(tsd.total_quantity, 0) AS quantity,
                                           v.avg_price_per_unit
                                    FROM world.storage s
                                             JOIN item_island_analytics v
                                                  ON s.island = v.island AND v.item = s.item AND v.type = 'vendor'
                                             LEFT JOIN total_ship_delivery tsd ON tsd.v_island = v.island AND tsd.item = v.item
                                    WHERE s.player = player_id
                                      AND (s.quantity - COALESCE(tsd.total_quantity, 0)) > r_ship.capacity * 0.3),
                              -- куда можем везти
                              c AS (SELECT c.island, c.item, c.avg_price_per_unit
                                    FROM item_island_analytics c
                                    WHERE c.type = 'customer'
                                      -- исключаем покупателей у которых и так много товаров в очереди
                                      AND NOT EXISTS(SELECT 1
                                                     FROM world.storage s
                                                     WHERE s.item = c.item
                                                       AND s.island = c.island
                                                       AND s.player = player_id
                                                       AND s.quantity > 2000 -- здесь надо еще смотреть на текущее игровое время и сложившуюся скорость потребления товаров на острове.
                                        ))
                          SELECT v.item,
                                 v.island                                               v_island,
                                 v.quantity,
                                 c.island                                               c_island,
                                 LEAST(v.quantity, r_ship.capacity) * (c.avg_price_per_unit - v.avg_price_per_unit) /
                                 (r_ship.capacity * 2
                                     + get_distance(r_ship.island, v.island) / r_ship.speed
                                     + get_distance(v.island, c.island) / r_ship.speed) factor
                          FROM v
                                   JOIN c ON v.item = c.item AND v.avg_price_per_unit < c.avg_price_per_unit
                          ORDER BY factor DESC
                LOOP
                    IF v_total_quantity = 0 THEN
                        -- первая итерация для корабля
                        v_quantity = TRUNC(LEAST(r_road.quantity, r_ship.capacity)::NUMERIC, 5);
                        v_total_quantity = v_quantity;

                        v_v_island = r_road.v_island;
                        v_c_island = r_road.c_island;

                        -- создаем доставку
                        INSERT INTO my_ship_delivery(ship, quantity, v_island, c_island, item)
                        VALUES (r_ship.id, v_quantity, r_road.v_island, r_road.c_island, r_road.item);

                        IF r_ship.island != v_v_island THEN
                            -- корабль находится на другом острове. переправляем корабль к острову погрузки.
                            INSERT INTO actions.ship_moves(ship, destination) VALUES (r_ship.id, v_v_island);
                        END IF;

                    ELSEIF r_road.v_island = v_v_island AND r_road.c_island = v_c_island THEN
                        v_quantity = TRUNC(LEAST(r_road.quantity, r_ship.capacity - v_total_quantity)::NUMERIC, 5);

                        INSERT INTO my_ship_delivery(ship, quantity, v_island, c_island, item)
                        VALUES (r_ship.id, v_quantity, r_road.v_island, r_road.c_island, r_road.item);

                        v_total_quantity = v_total_quantity + v_quantity;
                    END IF;

                    IF ABS(v_total_quantity - r_ship.capacity) < 1 THEN
                        EXIT roads_loop;
                    END IF;
                END LOOP;
        END LOOP;
    --endregion


EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, process_deliveries error! %', player_id, r_global.game_time, v_error_message;
END
$$;


CREATE OR REPLACE PROCEDURE think(player_id INTEGER)
    LANGUAGE plpgsql AS
$$
DECLARE
    r_global        world.global%ROWTYPE;
    v_error_message TEXT;
BEGIN
    SELECT * INTO r_global FROM world.global;

    -- CALL save_history(r_global);

    IF EXISTS(SELECT(1) FROM events.wait_finished) THEN
        INSERT INTO actions.wait(until) VALUES (r_global.game_time + 50);
    END IF;

    CALL update_analytics(player_id, r_global);
    CALL make_purchases(player_id, r_global);

    IF r_global.game_time > 0 THEN
        CALL process_transfers_events(player_id, r_global);
        CALL process_deliveries(player_id, r_global);
        CALL process_transfers_commands(player_id, r_global);
        CALL process_moves(player_id, r_global);
        CALL make_customers_contracts(player_id, r_global);
    END IF;

    -- CALL save_action_history(r_global);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, think error! %', player_id, r_global.game_time, v_error_message;
END
$$;

