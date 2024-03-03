# Выбрать идентификаторы самолётов, в которых есть посадочные места с редким классом 'Comfort' (вместо более привычных 'Economy' / 'Business')
# 	Используйте SELECT DISTINCT, чтобы убрать дубликаты из результатов запроса

use bookings;

SELECT *
FROM seats
LIMIT 1
;

EXPLAIN ANALYZE
SELECT DISTINCT a.aircraft_code
FROM seats s
INNER JOIN aircrafts_data a
	ON s.aircraft_code = a.aircraft_code
WHERE fare_conditions = 'Comfort'
;

/*
# id	select_type	table	partitions	type	possible_keys	key		key_len	ref							rows	filtered	Extra
	1	SIMPLE		a					index	PRIMARY			PRIMARY	12									9		100.00		Using index; Using temporary
	1	SIMPLE		s					ref		PRIMARY			PRIMARY	12		bookings.a.aircraft_code	148		10.00		Using where; Distinct

-> Table scan on <temporary>  (cost=13.84..16.16 rows=9) (actual time=0.693..0.693 rows=1 loops=1)
    -> Temporary table with deduplication  (cost=13.55..13.55 rows=9) (actual time=0.692..0.692 rows=1 loops=1)
        -> Nested loop inner join  (cost=12.65 rows=9) (actual time=0.567..0.677 rows=1 loops=1)
            -> Covering index scan on a using PRIMARY  (cost=1.15 rows=9) (actual time=0.024..0.026 rows=9 loops=1)
            -> Limit: 1 row(s)  (cost=0.44 rows=1) (actual time=0.072..0.072 rows=0 loops=9)
                -> Filter: (s.fare_conditions = 'Comfort')  (cost=0.44 rows=15) (actual time=0.072..0.072 rows=0 loops=9)
                    -> Index lookup on s using PRIMARY (aircraft_code=a.aircraft_code)  (cost=0.44 rows=149) (actual time=0.034..0.062 rows=104 loops=9)
*/