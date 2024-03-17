/*
Для билетов с кодом бронирования '58DF57' выбрать имена пассажиров, 
номер рейса, дату-время отправления и дату-время прибытия
*/

USE bookings;

EXPLAIN ANALYZE
SELECT
	GROUP_CONCAT(t.passenger_name),
    f.flight_id,
    ANY_VALUE(f.actual_departure),
    ANY_VALUE(f.actual_arrival)
FROM bookings b
	INNER JOIN tickets t ON b.book_ref = t.book_ref
    INNER JOIN ticket_flights tf ON tf.ticket_no = t.ticket_no
    INNER JOIN flights f ON f.flight_id = tf.flight_id
WHERE b.book_ref = '58DF57'
GROUP BY f.flight_id
;

/*
EXPLAIN: -> 
Group aggregate: group_concat(tickets.passenger_name separator ',')  (actual time=0.0765..0.0765 rows=1 loops=1)
    -> Sort: f.flight_id  (actual time=0.0721..0.0726 rows=3 loops=1)
        -> Stream results  (cost=16.4 rows=8.4) (actual time=0.0409..0.0611 rows=3 loops=1)
            -> Nested loop inner join  (cost=16.4 rows=8.4) (actual time=0.0333..0.0513 rows=3 loops=1)
                -> Nested loop inner join  (cost=7.21 rows=8.4) (actual time=0.0269..0.0443 rows=3 loops=1)
                    -> Index lookup on t using tickets_book_ref_fkey (book_ref='58DF57'), with index condition: (t.book_ref = '58DF57')  (cost=3.3 rows=3) (actual time=0.0189..0.0268 rows=3 loops=1)
                    -> Covering index lookup on tf using PRIMARY (ticket_no=t.ticket_no)  (cost=1.12 rows=2.8) (actual time=0.00447..0.0056 rows=1 loops=3)
                -> Single-row index lookup on f using PRIMARY (flight_id=tf.flight_id)  (cost=1.01 rows=1) (actual time=0.00203..0.00203 rows=1 loops=3)
*/