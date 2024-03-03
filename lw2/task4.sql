# Выбрать идентификаторы и стоимости 10 самых дорогостоящих бронирований (bookings)

USE bookings;

EXPLAIN ANALYZE
select book_ref, total_amount
FROM bookings
ORDER BY total_amount DESC
LIMIT 10
;

/*
# id	select_type	table	partitions	type	possible_keys	key	key_len	ref	rows	filtered	Extra
	1	SIMPLE		bookings			ALL										592676	100.00		Using filesort

-> Limit: 10 row(s)  (cost=59628.35 rows=10) (actual time=286.249..286.250 rows=10 loops=1)
    -> Sort: bookings.total_amount DESC, limit input to 10 row(s) per chunk  (cost=59628.35 rows=592676) (actual time=286.248..286.249 rows=10 loops=1)
        -> Table scan on bookings  (cost=59628.35 rows=592676) (actual time=0.044..175.929 rows=593433 loops=1)
*/