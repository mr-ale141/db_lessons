/*
Выбрать все «счастливые» коды бронирования со списками имён пассажиров в каждом из них
- На одно бронирование со «счастливым» кодом должен быть ровно один результат запроса
- Под «счастливым» кодом понимается код, в котором первые три символа 
	совпадают с тремя последними (например, '0DA0DA')
*/

EXPLAIN ANALYZE
SELECT
	b.book_ref,
    GROUP_CONCAT(t.passenger_name)
FROM bookings b
	INNER JOIN tickets t ON t.book_ref = b.book_ref
WHERE LEFT(b.book_ref, 3) = RIGHT(b.book_ref, 3)
GROUP BY b.book_ref
;

/*
EXPLAIN: 
-> Group aggregate: group_concat(tickets.passenger_name separator ',')  (actual time=2398..2398 rows=151 loops=1)
    -> Sort: b.book_ref  (actual time=2398..2398 rows=196 loops=1)
        -> Stream results  (cost=389173 rows=847099) (actual time=6.8..2397 rows=196 loops=1)
            -> Nested loop inner join  (cost=389173 rows=847099) (actual time=6.79..2397 rows=196 loops=1)
                -> Table scan on t  (cost=92688 rows=847099) (actual time=0.343..1039 rows=829071 loops=1)
                -> Filter: (left(b.book_ref,3) = right(b.book_ref,3))  (cost=0.25 rows=1) (actual time=0.0016..0.0016 rows=236e-6 loops=829071)
                    -> Single-row covering index lookup on b using PRIMARY (book_ref=t.book_ref)  (cost=0.25 rows=1) (actual time=0.00145..0.00147 rows=1 loops=829071)
*/