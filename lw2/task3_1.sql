# Удалить всю информацию о билетах пассажира Gennadiy Nikitin

USE bookings;

SELECT *
FROM tickets
WHERE passenger_name = 'Gennadiy Nikitin'
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tickets.csv'
;

SELECT *
FROM ticket_flights
WHERE ticket_no IN (
	SELECT ticket_no
	FROM tickets
	WHERE passenger_name = 'Gennadiy Nikitin'
)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ticket_flights.csv'
;

SELECT *
FROM boarding_passes
WHERE ticket_no IN (
	SELECT ticket_no
	FROM tickets
	WHERE passenger_name = 'Gennadiy Nikitin'
)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/boarding_passes.csv'
;

SELECT *
FROM bookings
WHERE book_ref IN (
	SELECT book_ref
	FROM tickets
	WHERE passenger_name = 'Gennadiy Nikitin'
)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookings.csv'
;

/*
Delete plane:
1. boarding_passes
2. ticket_flights
3. bookings
4. tickets
*/


