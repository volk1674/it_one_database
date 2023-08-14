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
        --
        v_island_id                   INTEGER;
        r_item                        RECORD;
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
                INSERT INTO world.islands(x, y) VALUES (RANDOM() * 1000, RANDOM() * 1000) RETURNING id INTO v_island_id;
                FOR r_item IN SELECT * FROM world.items
                    LOOP
                        IF RANDOM() > 0.5 THEN
                            IF RANDOM() > 0.5 THEN
                                v_random_contractors_quantity = TRUNC(500 + RANDOM() * 500);
                                v_random_contractors_price = TRUNC(100 + RANDOM() * 200);

                                INSERT INTO world.contractors(type, island, item, quantity, price_per_unit)
                                VALUES ('vendor', v_island_id, r_item.id, v_random_contractors_quantity,
                                        v_random_contractors_price);
                            ELSE
                                v_random_contractors_quantity = TRUNC(500 + RANDOM() * 500);
                                v_random_contractors_price = TRUNC(150 + RANDOM() * 150);

                                INSERT INTO world.contractors(type, island, item, quantity, price_per_unit)
                                VALUES ('customer', v_island_id, r_item.id, v_random_contractors_quantity,
                                        v_random_contractors_price);
                            END IF;
                        END IF;
                    END LOOP;
            END LOOP;
    END
$$;