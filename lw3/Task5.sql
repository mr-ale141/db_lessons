/*
Выбрать номер рейса и дату-время отправления для 10 рейсов, принёсших наибольшую выручку
- Следует выбирать только рейсы в состоянии 'Arrived'
- Даты отправления и прибытия следует выбирать фактические, а не запланированные
*/

EXPLAIN ANALYZE
SELECT
	f.flight_no,
    f.actual_departure
FROM flights f
	INNER JOIN ticket_flights tf ON tf.flight_id = f.flight_id
WHERE f.status = 'Arrived'
GROUP BY f.flight_no, f.actual_departure
ORDER BY ANY_VALUE(tf.amount) DESC
LIMIT 10
;

/*
EXPLAIN: 
-> Limit: 10 row(s)  (actual time=19932..19932 rows=10 loops=1)
    -> Sort: any_value(tf.amount) DESC, limit input to 10 row(s) per chunk  (actual time=19932..19932 rows=10 loops=1)
        -> Table scan on <temporary>  (cost=326169..330509 rows=346988) (actual time=19928..19929 rows=34386 loops=1)
            -> Temporary table with deduplication  (cost=326169..326169 rows=346988) (actual time=19928..19928 rows=34386 loops=1)
                -> Nested loop inner join  (cost=291470 rows=346988) (actual time=8.14..19359 rows=1.89e+6 loops=1)
                    -> Filter: (f.`status` = 'Arrived')  (cost=6643 rows=6555) (actual time=0.0613..25.1 rows=49235 loops=1)
                        -> Table scan on f  (cost=6643 rows=65545) (actual time=0.0588..17 rows=65664 loops=1)
                    -> Index lookup on tf using ticket_flights_flight_id_fkey (flight_id=f.flight_id)  (cost=38.2 rows=52.9) (actual time=0.252..0.392 rows=38.4 loops=49235)
*/
