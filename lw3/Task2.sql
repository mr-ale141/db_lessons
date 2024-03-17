/*
Для всех типов самолётов выбрать количество мест по классам обслуживания
- Ожидаемая схема набора результатов: (aircraft_code, fare_conditions, seat_count)
*/

EXPLAIN ANALYZE
SELECT
	aircraft_code,
    fare_conditions,
    COUNT(*) AS seat_count
FROM seats
GROUP BY aircraft_code, fare_conditions
;

/*
EXPLAIN: 
-> Table scan on <temporary>  (actual time=1.56..1.56 rows=17 loops=1)
    -> Aggregate using temporary table  (actual time=1.56..1.56 rows=17 loops=1)
        -> Table scan on seats  (cost=136 rows=1339) (actual time=0.0383..0.483 rows=1339 loops=1)
*/