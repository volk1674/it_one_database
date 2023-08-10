DO
$$
    DECLARE
        v_map_size                    DOUBLE PRECISION = 1000;
        v_islands                     INTEGER          = 10;
        v_min_island_id               INTEGER;
        v_min_item_id                 INTEGER;
        v_random_island_id            INTEGER;
        v_random_item_id              INTEGER;
        v_random_contractors_quantity INTEGER;
        v_random_contractors_price    INTEGER;
    BEGIN
        TRUNCATE world.global;
        TRUNCATE world.items;
        TRUNCATE world.islands;
        TRUNCATE world.contractors;

        INSERT INTO world.global(game_time, map_size) VALUES (0, v_map_size);
        INSERT INTO world.items(name) VALUES ('Ткань');
        INSERT INTO world.items(name) VALUES ('Одежда');
        INSERT INTO world.items(name) VALUES ('Алмазы');
        INSERT INTO world.items(name) VALUES ('Камень');
        INSERT INTO world.items(name) VALUES ('Древесина');

        FOR i IN 1..v_islands
            LOOP
                INSERT INTO world.islands(x, y) VALUES (RANDOM() * 1000, RANDOM() * 1000);
            END LOOP;

        SELECT MIN(id) FROM world.islands INTO v_min_island_id;
        SELECT MIN(id) FROM world.items INTO v_min_item_id;

        -- vendors
        FOR i IN 1..5
            LOOP
                v_random_island_id = v_min_island_id + TRUNC(RANDOM() * v_islands);
                v_random_item_id = v_min_item_id + TRUNC(RANDOM() * 5);
                v_random_contractors_quantity = TRUNC(500 + RANDOM() * 500);
                v_random_contractors_price = TRUNC(100 + RANDOM() * 200);

                INSERT INTO world.contractors(type, island, item, quantity, price_per_unit)
                VALUES ('vendor', v_random_island_id, v_random_item_id, v_random_contractors_quantity,
                        v_random_contractors_price);
            END LOOP;

        --  customers
        FOR i IN 1..5
            LOOP
                v_random_island_id = v_min_island_id + TRUNC(RANDOM() * v_islands);
                v_random_item_id = v_min_item_id + TRUNC(RANDOM() * 5);
                v_random_contractors_quantity = TRUNC(500 + RANDOM() * 500);
                v_random_contractors_price = TRUNC(100 + RANDOM() * 200);

                INSERT INTO world.contractors(type, island, item, quantity, price_per_unit)
                VALUES ('customer', v_random_island_id, v_random_item_id, v_random_contractors_quantity,
                        v_random_contractors_price);
            END LOOP;
    END
$$;