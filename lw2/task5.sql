# Выбрать имена и контактные данные всех пассажиров, указанных в самом дорогостоящем бронировании (среди всех, что есть в базе данных)

use bookings;

select book_ref, total_amount
FROM bookings
ORDER BY total_amount DESC
LIMIT 10
;

EXPLAIN ANALYZE
SELECT passenger_name, contact_data
FROM bookings b
INNER JOIN tickets t
	ON b.book_ref = t.book_ref
ORDER BY total_amount DESC
LIMIT 1
;

/*
# id	select_type	table	partitions	type	possible_keys			key						key_len	ref					rows	filtered	Extra
	1	SIMPLE		b					ALL		PRIMARY																		592676	100.00		Using filesort
	1	SIMPLE		t					ref		tickets_book_ref_fkey	tickets_book_ref_fkey	24		bookings.b.book_ref	1		100.00	

-> Limit: 1 row(s)  (cost=962158.18 rows=1) (actual time=423.154..423.154 rows=1 loops=1)
    -> Nested loop inner join  (cost=962158.18 rows=820640) (actual time=423.153..423.153 rows=1 loops=1)
        -> Sort: b.total_amount DESC  (cost=59628.35 rows=592676) (actual time=423.103..423.103 rows=1 loops=1)
            -> Table scan on b  (cost=59628.35 rows=592676) (actual time=0.042..189.242 rows=593433 loops=1)
        -> Index lookup on t using tickets_book_ref_fkey (book_ref=b.book_ref)  (cost=1.38 rows=1) (actual time=0.049..0.049 rows=1 loops=1)
*/