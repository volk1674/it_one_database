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


-- region исторические таблицы
CREATE UNLOGGED TABLE st_contractors
(
    id             INTEGER          NOT NULL,
    item           INTEGER          NOT NULL,
    island         INTEGER          NOT NULL,
    max_quantity   DOUBLE PRECISION NOT NULL,
    max_price      DOUBLE PRECISION NOT NULL,
    min_price      DOUBLE PRECISION NOT NULL,
    quantity       DOUBLE PRECISION NOT NULL,
    price_per_unit DOUBLE PRECISION NOT NULL,
    type           world.contractor_type
);


CREATE OR REPLACE PROCEDURE save_stats(r_global world.global)
    LANGUAGE plpgsql AS
$$
BEGIN
    IF r_global.game_time = 0 THEN
        INSERT INTO st_contractors(id, item, island, max_quantity, max_price, min_price, quantity, price_per_unit, type)
        SELECT c.id,
               c.item,
               c.island,
               c.quantity,
               c.price_per_unit,
               c.price_per_unit,
               c.quantity,
               c.price_per_unit,
               c.type
        FROM world.contractors c;

        INSERT INTO actions.wait(until) VALUES (r_global.game_time + 50);
    ELSE
        IF EXISTS(SELECT 1 FROM events.wait_finished) THEN

            UPDATE st_contractors
            SET max_quantity   = GREATEST(max_quantity, cs.quantity),
                max_price      = GREATEST(max_price, cs.price_per_unit),
                min_price      = LEAST(min_price, cs.price_per_unit),
                quantity       = cs.quantity,
                price_per_unit = cs.price_per_unit
            FROM (SELECT c.id, c.quantity, c.price_per_unit FROM world.contractors c) cs
            WHERE cs.id = st_contractors.id;

            INSERT INTO actions.wait(until) VALUES (r_global.game_time + 50);
        END IF;
    END IF;
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
    item                 INTEGER          NOT NULL,
    -- минимальная цена продажи
    min_sale_price       DOUBLE PRECISION NOT NULL,
    -- максимальная цена покупки
    max_purchase_price   DOUBLE PRECISION NOT NULL,
    -- максимальная цена покупки если склады заполнены
    max_purchase_price_2 DOUBLE PRECISION NOT NULL
);


-- Обновить аналитику
CREATE OR REPLACE PROCEDURE update_analytics(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message  TEXT;
    v_pf_customer    DOUBLE PRECISION = 0.7;
    v_pf_vendor      DOUBLE PRECISION = 0.85;
    v_max_sale_price DOUBLE PRECISION = 1000000000;
BEGIN
    TRUNCATE item_analytics;

    IF r_global.game_time > 20000 THEN
        v_pf_vendor = 0.80;
        v_pf_customer = 0.80;
    END IF;

    IF r_global.game_time > 50000 THEN
        v_pf_vendor = 0.70;
        v_pf_customer = 0.70;
    END IF;

    IF r_global.game_time > 90000 THEN
        v_pf_vendor = 0.9;
        v_pf_customer = 0.2;
    END IF;

    IF r_global.game_time > 97000 THEN
        v_max_sale_price = 0;
    END IF;

    INSERT INTO item_analytics(item, min_sale_price, max_purchase_price, max_purchase_price_2)
    WITH cp AS (SELECT c.item, PERCENTILE_CONT(v_pf_customer) WITHIN GROUP (ORDER BY price_per_unit) s_price
                FROM customers c
                GROUP BY c.item),
         vp AS (SELECT v.item,
                       PERCENTILE_CONT(v_pf_vendor) WITHIN GROUP (ORDER BY price_per_unit DESC) p_price,
                       PERCENTILE_CONT(v_pf_vendor) WITHIN GROUP (ORDER BY min_price DESC)      p_price_2
                FROM st_contractors v
                WHERE v.type = 'vendor'
                GROUP BY v.item)
    SELECT cp.item,
           LEAST(cp.s_price, v_max_sale_price),
           LEAST(vp.p_price, cp.s_price, v_max_sale_price),
           LEAST(vp.p_price_2, cp.s_price, v_max_sale_price)
    FROM cp,
         vp
    WHERE cp.item = vp.item;

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

CREATE FUNCTION get_distance(x1 DOUBLE PRECISION, y1 DOUBLE PRECISION, x2 DOUBLE PRECISION,
                             y2 DOUBLE PRECISION) RETURNS DOUBLE PRECISION
    IMMUTABLE
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN LEAST(ABS(x2 - x1), 1000 - ABS(x2 - x1)) + LEAST(ABS(y2 - y1), 1000 - ABS(y2 - y1));
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
          AND pr.min_sale_price <= c.price_per_unit
        ORDER BY c.price_per_unit DESC
        LOOP
            IF rec.quantity <= rec.storage_quantity THEN
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


-- Формирование запросов на продажу.
CREATE OR REPLACE PROCEDURE make_customers_contracts_2(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message TEXT;
    rec             RECORD;
BEGIN
    FOR rec IN SELECT st.*,
                      EXISTS(SELECT 1
                             FROM my_ship_delivery d
                             WHERE st.item = d.item
                               AND st.island = d.c_island) has_delivery,
                      COALESCE(s.quantity, 0) AS           s_quantity
               FROM st_contractors st
                        JOIN item_analytics a ON a.item = st.item
                        LEFT JOIN world.storage s ON s.player = player_id AND s.island = st.island AND s.item = st.item
               WHERE st.type = 'customer'
                 AND NOT EXISTS(SELECT 1
                                FROM world.contracts cc
                                WHERE cc.player = player_id
                                  AND cc.contractor = st.id)
                 AND st.price_per_unit >= a.min_sale_price
                 AND (EXISTS(SELECT 1 FROM my_ship_delivery d WHERE st.item = d.item AND st.island = d.c_island) OR
                      COALESCE(s.quantity, 0) > 0)
        LOOP
            IF rec.price_per_unit / rec.max_price > 0.99 AND r_global.game_time < 90000 AND
               (rec.max_quantity - rec.quantity) < 1 THEN

                INSERT INTO actions.offers(contractor, quantity) VALUES (rec.id, rec.quantity);

            ELSEIF r_global.game_time > 90000 OR rec.s_quantity > 1000 THEN

                IF rec.s_quantity >= rec.quantity THEN
                    INSERT INTO actions.offers(contractor, quantity) VALUES (rec.id, rec.quantity);
                ELSE
                    INSERT INTO actions.offers(contractor, quantity) VALUES (rec.id, rec.s_quantity);
                END IF;

            END IF;
        END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, make_customers_contracts_2 error! %', player_id, r_global.game_time, v_error_message;
END
$$;



CREATE OR REPLACE PROCEDURE make_purchases_0(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message TEXT;
BEGIN

    INSERT INTO actions.offers(contractor, quantity)
    WITH t1 AS (SELECT v.id                                                    AS v_id,
                       c.id                                                    AS c_id,
                       v.island                                                AS v_island,
                       v.item                                                  AS item,
                       v.quantity                                              AS quantity,
                       (c.price_per_unit - v.price_per_unit) * v.quantity /
                       (v.quantity * 2 + get_distance(vi.x, vi.y, ci.x, ci.y)) AS vc_factor
                FROM vendors v
                         JOIN customers c ON c.item = v.item
                         JOIN world.islands vi ON vi.id = v.island
                         JOIN world.islands ci ON ci.id = c.island),
         t2 AS (SELECT t1.*, ROW_NUMBER() OVER (PARTITION BY v_id ORDER BY vc_factor DESC ) rank
                FROM t1)
    SELECT t2.v_id, t2.quantity
    FROM t2
    WHERE rank = 1
    ORDER BY vc_factor DESC
    LIMIT 10;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, make_purchases_0 error! %', player_id, r_global.game_time, v_error_message;
END
$$;


CREATE OR REPLACE PROCEDURE make_purchases_1(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message TEXT;
BEGIN

    INSERT INTO actions.offers(contractor, quantity)
    WITH t1 AS (SELECT v.id                                                    AS v_id,
                       c.id                                                    AS c_id,
                       v.island                                                AS v_island,
                       v.item                                                  AS item,
                       v.quantity                                              AS quantity,
                       (c.price_per_unit - v.price_per_unit) * v.quantity /
                       (v.quantity * 2 + get_distance(vi.x, vi.y, ci.x, ci.y)) AS vc_factor
                FROM vendors v
                         JOIN customers c ON c.item = v.item
                         JOIN world.islands vi ON vi.id = v.island
                         JOIN world.islands ci ON ci.id = c.island),
         t2 AS (SELECT t1.*, ROW_NUMBER() OVER (PARTITION BY v_id ORDER BY vc_factor DESC ) rank
                FROM t1),
         t3 AS (SELECT t2.v_id, t2.quantity, t2.item, t2.v_island
                FROM t2
                WHERE rank = 1
                ORDER BY vc_factor DESC
                LIMIT 10)
    SELECT t3.v_id, t3.quantity
    FROM t3
             LEFT JOIN world.storage s ON s.player = player_id AND s.item = t3.item AND s.island = t3.v_island
    WHERE COALESCE(s.quantity, 0) < 2000;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, make_purchases_0 error! %', player_id, r_global.game_time, v_error_message;
END
$$;


CREATE OR REPLACE PROCEDURE make_purchases(player_id INTEGER, r_global world.global)
    LANGUAGE plpgsql AS
$$
DECLARE
    v_error_message           TEXT;
    v_vendor_storage_quantity DOUBLE PRECISION;
BEGIN
    IF r_global.game_time > 90000 THEN
        -- прекращаем покупки в самом конце. надо допродать уже купленное.
        RETURN;
    END IF;

    SELECT COALESCE(SUM(vs.quantity), 0)
    INTO v_vendor_storage_quantity
    FROM world.storage vs
    WHERE player = player_id
      AND EXISTS(SELECT 1 FROM vendors v WHERE v.island = vs.island AND v.item = vs.item);


    INSERT INTO actions.offers(contractor, quantity)
    WITH tds AS (SELECT d.item, d.v_island, SUM(d.quantity) sum
                 FROM my_ship_delivery d
                 GROUP BY d.v_island, d.item),
         sa AS (SELECT PERCENTILE_DISC(0.6) WITHIN GROUP ( ORDER BY speed )   avg_speed,
                       PERCENTILE_DISC(0.6) WITHIN GROUP ( ORDER BY capacity) avg_capacity
                FROM world.ships),
         p AS (SELECT v.id                                 v_id,
                      v.quantity                           v_quantity,
                      c.item,
                      c.id                                 c_id,
                      c.price_per_unit                     c_price,
                      v.price_per_unit                     v_price,
                      v.island                             v_island,
                      c.island                             c_island,
                      v.max_quantity                       v_max_quantity,
                      v.min_price                          v_min_price,

                      get_distance(vi.x, vi.y, ci.x, ci.y) distance
               FROM customers c
                        JOIN st_contractors v ON c.item = v.item AND v.type = 'vendor'
                        JOIN world.islands ci ON ci.id = c.island
                        JOIN world.islands vi ON vi.id = v.island),
         a AS (SELECT p.*,
                      (p.c_price - p.v_price) * sa.avg_capacity /
                      (20 + sa.avg_capacity * 2 + p.distance / sa.avg_speed) factor
               FROM p
                        CROSS JOIN sa),
         b AS (SELECT ROW_NUMBER() OVER (PARTITION BY a.v_id ORDER BY a.factor DESC) AS rank,
                      a.*
               FROM a),
         r AS (SELECT b.v_id,
                      b.v_quantity,
                      COALESCE(s.quantity, 0) AS s_quantity,
                      b.v_island,
                      b.item,
                      b.v_price,
                      b.c_price,
                      b.v_max_quantity,
                      b.v_min_price
               FROM b
                        LEFT JOIN world.storage s ON s.player = player_id AND s.item = b.item AND s.island = b.v_island
               WHERE rank = 1
               ORDER BY factor DESC
               LIMIT 8)
    SELECT r.v_id, r.v_quantity
    FROM r
             LEFT JOIN tds ON tds.v_island = r.v_island AND tds.item = r.item
             JOIN item_analytics pr ON pr.item = r.item AND r.v_price <= pr.max_purchase_price
    WHERE (v_vendor_storage_quantity < 20000 AND r.s_quantity < 700 + COALESCE(tds.sum, 0))
       OR (pr.max_purchase_price_2 > r.v_price * 0.99 AND
           COALESCE(r.s_quantity, 0) < 2500 + COALESCE(tds.sum, 0)) * 2;
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

    DELETE FROM my_ship_delivery WHERE state IN (1, 4);

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
    v_s_q           DOUBLE PRECISION;
    v_d_q           DOUBLE PRECISION;
    v_add_q         DOUBLE PRECISION;
BEGIN

    --region новые команды на погрузку
    FOR rec IN (SELECT d.ship, d.item, d.quantity, d.id, ship.capacity, ps.island
                FROM my_ship_delivery d
                         JOIN world.ships ship ON d.ship = ship.id
                         JOIN world.parked_ships ps ON ps.island = d.v_island AND ps.ship = d.ship
                WHERE state = 0)
        LOOP
            v_add_q = 0;

            -- может быть на складе появился нужный товар пока корабль добирался до острова погрузки
            IF rec.capacity - rec.quantity > 1 THEN

                SELECT COALESCE(SUM(s.quantity), 0)
                INTO v_s_q
                FROM world.storage s
                WHERE s.island = rec.island
                  AND s.item = rec.item
                  AND s.player = player_id;

                SELECT COALESCE(SUM(d.quantity), 0)
                INTO v_d_q
                FROM my_ship_delivery d
                WHERE d.v_island = rec.island
                  AND d.item = rec.item
                  AND d.state IN (0, 1);

                v_add_q = LEAST(rec.capacity - rec.quantity, v_s_q - v_d_q);
                v_add_q = TRUNC(v_add_q);
            END IF;

            INSERT INTO actions.transfers(ship, item, quantity, direction)
            VALUES (rec.ship, rec.item, rec.quantity + v_add_q, 'load');

            UPDATE my_ship_delivery SET state = 1, quantity = quantity + v_add_q WHERE id = rec.id;
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

            IF NOT EXISTS(SELECT 1 FROM actions.transfers WHERE ship = r_ship.id) THEN
                INSERT INTO actions.ship_moves(ship, destination) VALUES (r_ship.id, v_delivery_c_island);
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
    v_error_message TEXT;
    r_options       RECORD;
    r_road          RECORD;
    r_ship          RECORD;
    v_quantity      DOUBLE PRECISION;
    v_max_quantity  DOUBLE PRECISION = 3000;
BEGIN
    SELECT * INTO r_options FROM game_options;
    -- с островов где есть купленные товары надо построить оптимальные маршруты передвижения товаров где есть лучшие покупатели на эти товары.
    -- везем все товары к лучшему покупателю (совокупность цена + расстояние).
    -- если на острове покупателя накопились товары - временно исключаем покупателя из закупок.
    -- корабли не должны перемещаться незаполненными.

    IF r_global.game_time > 80000 THEN
        v_max_quantity = 500;
    END IF;


    --region для кораблей которым еще не назначена доставка пытаемся подобрать новую доставку без ограничения откуда и куда плывем
    FOR r_ship IN SELECT ship.*, ps.island, i.x, i.y
                  FROM world.ships ship
                           -- доставки планируются только для припаркованных кораблей
                           JOIN world.parked_ships ps ON ps.ship = ship.id
                           JOIN world.islands i ON i.id = ps.island
                  WHERE ship.player = player_id
                    AND NOT EXISTS(SELECT 1 FROM my_ship_delivery d WHERE d.ship = ship.id)
                  ORDER BY ship.speed * ship.capacity DESC
        LOOP
            <<roads_loop>>
            FOR r_road IN WITH
                              -- уже запланированное к погрузке
                              tds AS (SELECT d.item, d.v_island, SUM(d.quantity) sum
                                      FROM my_ship_delivery d
                                      WHERE d.state = 0
                                      GROUP BY d.v_island, d.item),
                              tds_c AS (SELECT d.item, d.c_island, SUM(d.quantity) sum
                                        FROM my_ship_delivery d
                                        GROUP BY d.c_island, d.item),
                              -- расстояние от склада продавца до склада покупателя
                              p AS (SELECT vs.item,
                                           vs.island                            AS vs_island,
                                           vs.quantity - COALESCE(tds.sum, 0)   AS vs_quantity,
                                           si.x                                 AS vs_x,
                                           si.y                                 AS vs_y,
                                           get_distance(si.x, si.y, ci.x, ci.y) AS vs2cs_distance,
                                           c.quantity                           AS c_quantity,
                                           c.price_per_unit                     AS c_price,
                                           c.id                                 AS c_id,
                                           COALESCE(cs.quantity, 0)             AS cs_quantity,
                                           ci.id                                AS cs_island
                                    FROM world.storage vs
                                             JOIN customers c ON vs.item = c.item
                                             JOIN world.islands si ON si.id = vs.island
                                             JOIN world.islands ci ON ci.id = c.island
                                             LEFT JOIN world.storage cs
                                                       ON cs.item = c.item AND cs.island = c.island AND cs.player = vs.player
                                             LEFT JOIN tds ON tds.item = vs.item AND tds.v_island = vs.island
                                    WHERE vs.player = player_id
                                      AND vs.quantity - COALESCE(tds.sum, 0) > r_ship.capacity * 0.2
                                      -- только склады где есть продавцы
                                      AND EXISTS(SELECT 1 FROM vendors v WHERE v.island = vs.island AND v.item = vs.item)),
                              a AS (SELECT p.*,
                                           (p.c_price - 3) * LEAST(p.vs_quantity, r_ship.capacity) /
                                           (30 + get_distance(r_ship.x, r_ship.y, p.vs_x, p.vs_y) +
                                            LEAST(p.vs_quantity, r_ship.capacity) * 2 +
                                            p.vs2cs_distance / r_ship.speed) factor
                                    FROM p),
                              b AS (SELECT ROW_NUMBER()
                                           OVER (PARTITION BY a.vs_island, a.cs_island, a.item ORDER BY a.factor DESC) AS rank,
                                           a.*
                                    FROM a)
                          SELECT b.vs_island, b.cs_island, b.item, b.vs_quantity
                          FROM b
                                   LEFT JOIN tds_c ON tds_c.item = b.item AND tds_c.c_island = b.cs_island
                          WHERE b.cs_quantity + COALESCE(tds_c.sum, 0) < rank * v_max_quantity
                          ORDER BY factor DESC
                          LIMIT 1
                LOOP
                    v_quantity = LEAST(r_road.vs_quantity, r_ship.capacity) - 0.0001;

                    -- создаем доставку
                    INSERT INTO my_ship_delivery(ship, quantity, v_island, c_island, item)
                    VALUES (r_ship.id, v_quantity, r_road.vs_island, r_road.cs_island, r_road.item);

                    IF r_ship.island != r_road.vs_island THEN
                        -- корабль находится на другом острове. переправляем корабль к острову погрузки.
                        INSERT INTO actions.ship_moves(ship, destination) VALUES (r_ship.id, r_road.vs_island);
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
    CALL save_stats(r_global);

    IF r_global.game_time > 0 THEN
        CALL update_analytics(player_id, r_global);

        CALL make_purchases_1(player_id, r_global);

        CALL process_transfers_events(player_id, r_global);
        CALL process_deliveries(player_id, r_global);
        CALL process_transfers_commands(player_id, r_global);
        CALL process_moves(player_id, r_global);
        CALL make_customers_contracts_2(player_id, r_global);
    ELSE
        CALL make_purchases_0(player_id, r_global);
    END IF;

    -- CALL save_action_history(r_global);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT;

        RAISE NOTICE '[%] time %, think error! %', player_id, r_global.game_time, v_error_message;
END
$$;

