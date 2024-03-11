# Выбрать имена и контактные данные всех пассажиров, указанных в самом дорогостоящем бронировании (среди всех, что есть в базе данных)
# может быть несколько билетов на одно бронирование

USE bookings;

EXPLAIN ANALYZE
SELECT book_ref
FROM bookings
ORDER BY total_amount DESC
LIMIT 1
;

SELECT *
FROM bookings
WHERE book_ref = '3B54BB'
;

EXPLAIN ANALYZE
SELECT passenger_name, contact_data
FROM bookings b
INNER JOIN tickets t
	ON b.book_ref = t.book_ref
ORDER BY total_amount DESC
LIMIT 1
;

EXPLAIN ANALYZE
SELECT t.passenger_name, t.contact_data
FROM tickets t
	INNER JOIN bookings b ON t.book_ref = b.book_ref
WHERE b.book_ref = (
	SELECT book_ref
	FROM bookings
	ORDER BY total_amount DESC
	LIMIT 1
);

-- сортировка кучей
/*
id, select_type, 	table, 	partitions, type, 	possible_keys, 			key, 					key_len, 	ref, 	rows, 	filtered, 	Extra
1, 	PRIMARY, 		b, , 				const, 	PRIMARY, 				PRIMARY, 				24, 		const, 	1, 		100.00, 	Using index
1, 	PRIMARY, 		t, , 				ref, t	ickets_book_ref_fkey, 	tickets_book_ref_fkey, 	24, 		const, 	3, 		100.00, 	Using where
2, 	SUBQUERY, 		bookings, , 		ALL, 	,	 , , , 															592676, 100.00, 	Using filesort


-> Filter: (t.book_ref = (select #2))  (cost=1.05 rows=3) (actual time=0.0572..0.0925 rows=3 loops=1)
     -> Index lookup on t using tickets_book_ref_fkey (book_ref=(select #2))  (cost=1.05 rows=3) (actual time=0.0549..0.0873 rows=3 loops=1)
     -> Select #2 (subquery in condition; run only once)
         -> Limit: 1 row(s)  (cost=59628 rows=1) (actual time=610..610 rows=1 loops=1)
             -> Sort: bookings.total_amount DESC, limit input to 1 row(s) per chunk  (cost=59628 rows=592676) (actual time=610..610 rows=1 loops=1)
                 -> Table scan on bookings  (cost=59628 rows=592676) (actual time=0.105..372 rows=593433 loops=1)
*/