# Удалить всю информацию о билетах пассажира Gennadiy Nikitin

USE bookings;

SELECT *
FROM tickets
WHERE passenger_name = 'Gennadiy Nikitin'
-- INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tickets.csv'
;

SELECT tf.*
FROM ticket_flights tf
	INNER JOIN tickets t ON t.ticket_no = tf.ticket_no
WHERE passenger_name = 'Gennadiy Nikitin'
-- INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ticket_flights.csv'
;

SELECT bp.*
FROM boarding_passes bp
	INNER JOIN tickets t ON t.ticket_no = bp.ticket_no
WHERE passenger_name = 'Gennadiy Nikitin'
-- INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/boarding_passes.csv'
;

/*
SELECT b.*
FROM bookings b
	INNER JOIN tickets t ON b.book_ref = t.book_ref
WHERE passenger_name = 'Gennadiy Nikitin'
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookings.csv'
;
*/

SELECT *
FROM bookings
WHERE book_ref IN (
	SELECT book_count.book_ref
	FROM (
		SELECT b.book_ref, count(*) AS count
		FROM bookings b
		INNER JOIN tickets t ON b.book_ref = t.book_ref
		WHERE b.book_ref IN (
			SELECT book_ref
			FROM tickets
			WHERE passenger_name = 'Gennadiy Nikitin'
		)
		GROUP BY b.book_ref
	) AS book_count
	WHERE book_count.count = 1
)
-- INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookings.csv'
;

/*
'78E2D2','73CA24','DB28C1','D13553','166BBE','6865D5','1828E5','246314','3BF6F4','9825A1',
'60EB3F','3F3E5E','35198C','41C522','DA4042','966B80','DCD59F','4860E5','1CE386','F9D06C',
'B93FB3','A02FF3','EE57B0','A46890'
*/

/*
Delete plane:
1. bookings
2. boarding_passes
3. ticket_flights
4. tickets


Recovery plane:
1. bookings
2. boarding_passes
3. tickets
4. ticket_flights


EXAMPLE:

DELETE
  tf
FROM tickets t
  INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
  INNER JOIN flights f ON tf.flight_id = f.flight_id
WHERE t.passenger_name = 'MARINA NIKOLAEVA'
  AND t.book_ref = '5F4955'
  AND f.arrival_airport = 'MMK'
; 
*/

-- DELETE t, tf, bp, b
SELECT *
FROM tickets t
	INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
    INNER JOIN boarding_passes bp ON t.ticket_no = bp.ticket_no
	/*LEFT JOIN bookings b ON b.book_ref IN (
		SELECT book_count.book_ref
        FROM (
			SELECT b.book_ref, count(*) AS count
			FROM bookings b
			INNER JOIN tickets t ON b.book_ref = t.book_ref
			WHERE b.book_ref IN (
				SELECT book_ref
				FROM tickets
				WHERE passenger_name = 'Gennadiy Nikitin'
			)
			GROUP BY b.book_ref
        ) AS book_count
        WHERE book_count.count = 1
    )*/
WHERE passenger_name = 'Gennadiy Nikitin'
;


/*///////////////////DELETE/////////////////////////*/

DELETE 
	bookings
FROM bookings
WHERE book_ref IN (
	SELECT book_count.book_ref
	FROM (
		SELECT b.book_ref, count(*) AS count
		FROM bookings b
		INNER JOIN tickets t ON b.book_ref = t.book_ref
		WHERE b.book_ref IN (
			SELECT book_ref
			FROM tickets
			WHERE passenger_name = 'Gennadiy Nikitin'
		)
		GROUP BY b.book_ref
	) AS book_count
	WHERE book_count.count = 1
)
;

DELETE 
	bp
FROM boarding_passes bp
	INNER JOIN tickets t ON t.ticket_no = bp.ticket_no
WHERE passenger_name = 'Gennadiy Nikitin'
;

DELETE 
	tf
FROM ticket_flights tf
	INNER JOIN tickets t ON t.ticket_no = tf.ticket_no
WHERE passenger_name = 'Gennadiy Nikitin'
;

DELETE
	tickets
FROM tickets
WHERE passenger_name = 'Gennadiy Nikitin'
;



/*///////////////////RECOVERY/////////////////////////*/
/*        WITH MYSQL WORKBANCH TOOL                   */














