-- сразу посчитаем все расстояния.
CREATE MATERIALIZED VIEW distances AS
SELECT v1.id v_island, v2.id c_island, get_distance(v1.id, v2.id) dist
FROM world.islands v1,
     world.islands v2
WHERE v1.id != v2.id;

--
CREATE VIEW distances_with_best_delta_price AS
SELECT d.v_island, d.c_island, d.dist, COALESCE(MAX(c.price_per_unit - v.price_per_unit), 0) delta_price
FROM distances d
         LEFT JOIN world.contractors c ON c.island = d.c_island AND c.type = 'customer'
         LEFT JOIN world.contractors v ON v.island = d.v_island AND v.type = 'vendor' AND v.item = c.item AND
                                          v.price_per_unit < c.price_per_unit
GROUP BY d.v_island, d.c_island, d.dist;



WITH RECURSIVE routes AS (SELECT 0 AS n, TRUE as not_cycle, p.c_island, p.delta_price, p.dist, ARRAY [p.v_island, p.c_island] AS path
                          FROM distances_with_best_delta_price p
                          WHERE p.delta_price > 0
                          UNION ALL
                          SELECT r.n + (p.delta_price = 0)::INT,
                                 r.not_cycle and p.c_island != path[1],
                                 p.c_island,
                                 r.delta_price + p.delta_price,
                                 r.dist + p.dist,
                                 r.path || p.c_island
                          FROM distances_with_best_delta_price p
                                   JOIN routes r
                                        ON r.c_island = p.v_island
                          WHERE r.not_cycle and (r.path[1] = p.c_island or p.c_island <> ALL (r.path)) AND r.n < 3
)
SELECT  path, dist, delta_price, delta_price / dist
FROM routes WHERE not not_cycle and path[1] = 23
ORDER BY delta_price / dist DESC LIMIT 30;