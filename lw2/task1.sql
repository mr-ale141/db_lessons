# Выбрать всю информацию о рейсах (flights), в которых номер рейса (flight_no) заканчивается на '488'

USE bookings;

SHOW COLUMNS FROM flights;

SHOW INDEXES FROM flights;

EXPLAIN ANALYZE SELECT *
FROM flights
WHERE flight_no LIKE '%488'
;
/*
id	select_type	table	partitions	type	possible_keys	key	key_len	ref	rows	filtered	Extra
1		SIMPLE		flights				ALL										65589	11.11		Using where

-> Filter: (flights.flight_no like '%488')  (cost=6647.15 rows=7287) (actual time=17.867..57.834 rows=121 loops=1)
    -> Table scan on flights  (cost=6647.15 rows=65589) (actual time=0.077..47.815 rows=65664 loops=1)
*/

EXPLAIN ANALYZE SELECT *
FROM flights
WHERE flight_no = (
	SELECT DISTINCT flight_no
	FROM flights
	WHERE flight_no LIKE '%488'
);
/*
id	select_type	table		partitions	type		possible_keys								key											key_len	ref		rows	filtered	Extra
1	     PRIMARY	flights					ref			flights_flight_no_scheduled_departure_key	flights_flight_no_scheduled_departure_key	24		const	121		100.00		Using where
2	     SUBQUERY	flights					range		flights_flight_no_scheduled_departure_key	flights_flight_no_scheduled_departure_key	24				746		100.00		Using where; Using index for group-by

-> Filter: (flights.flight_no = (select #2))  (cost=42.35 rows=121) (actual time=0.199..0.292 rows=121 loops=1)
    -> Index lookup on flights using flights_flight_no_scheduled_departure_key (flight_no=(select #2))  (cost=42.35 rows=121) (actual time=0.197..0.262 rows=121 loops=1)
    -> Select #2 (subquery in condition; run only once)
        -> Filter: (flights.flight_no like '%488')  (cost=327.10 rows=746) (actual time=2.833..4.214 rows=1 loops=1)
            -> Covering index skip scan for deduplication on flights using flights_flight_no_scheduled_departure_key  (cost=327.10 rows=746) (actual time=0.032..4.046 rows=710 loops=1)
*/
