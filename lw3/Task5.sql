/*
Выбрать номер рейса и дату-время отправления для 10 рейсов, принёсших наибольшую выручку
- Следует выбирать только рейсы в состоянии 'Arrived'
- Даты отправления и прибытия следует выбирать фактические, а не запланированные
*/

USE bookings;

-- tf.amount вырочка за перелет со всех пассажиров
EXPLAIN ANALYZE
SELECT
	f.flight_no,
    f.actual_departure
FROM flights f
	INNER JOIN ticket_flights tf ON tf.flight_id = f.flight_id
WHERE f.status = 'Arrived'
GROUP BY f.flight_id
ORDER BY SUM(distinct tf.amount) DESC
LIMIT 10
;

/*
EXPLAIN:
-> Limit: 10 row(s)  (actual time=37809..37809 rows=10 loops=1)
    -> Sort: sum(distinct tf.amount) DESC, limit input to 10 row(s) per chunk  (actual time=37809..37809 rows=10 loops=1)
        -> Stream results  (cost=275471 rows=65545) (actual time=5.57..37795 rows=34386 loops=1)
            -> Group aggregate: sum(distinct tf.amount)  (cost=275471 rows=65545) (actual time=5.56..37744 rows=34386 loops=1)
                -> Nested loop inner join  (cost=240772 rows=346988) (actual time=4.62..37592 rows=1.89e+6 loops=1)
                    -> Filter: (f.`status` = 'Arrived')  (cost=6865 rows=6555) (actual time=2.84..284 rows=49235 loops=1)
                        -> Index scan on f using PRIMARY  (cost=6865 rows=65545) (actual time=2.83..270 rows=65664 loops=1)
                    -> Index lookup on tf using ticket_flights_flight_id_fkey (flight_id=f.flight_id)  (cost=30.4 rows=52.9) (actual time=0.472..0.756 rows=38.4 loops=49235)
*/





















