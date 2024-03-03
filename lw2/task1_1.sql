# Для всех рейсов Домодедово, находящихся в статусе 'Delayed', поменять статус на 'Cancelled'

USE bookings;

/*
# 41 records
SELECT *
FROM flights
WHERE status = 'Delayed'
;


SELECT *
FROM airports_data
WHERE JSON_EXTRACT(airport_name, '$.ru') = 'Домодедово'
;
*/

SELECT *
FROM flights f
INNER JOIN airports_data a
	ON (f.departure_airport = a.airport_code OR f.arrival_airport = a.airport_code)
WHERE JSON_EXTRACT(airport_name, '$.ru') = 'Домодедово'
	AND status = 'Delayed'
;
/*
# 		flight_id	flight_no	scheduled_departure	scheduled_arrival	departure_airport	arrival_airport	status	aircraft_code	actual_departure	actual_arrival	airport_code	airport_name	city	coordinates	timezone
348		PG0403	2017-08-16 08:25:00	2017-08-16 09:20:00	DME	LED	Delayed	321			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
761		PG0273	2017-08-16 06:50:00	2017-08-16 08:50:00	DME	CEK	Delayed	SU9			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
974		PG0212	2017-08-15 15:20:00	2017-08-15 16:35:00	DME	ROV	Delayed	321			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
2469	PG0005	2017-08-15 12:40:00	2017-08-15 14:45:00	DME	PKV	Delayed	CN1			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
5377	PG0593	2017-08-16 12:50:00	2017-08-16 15:20:00	DME	KVX	Delayed	CN1			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
5858	PG0382	2017-08-16 12:20:00	2017-08-16 12:50:00	DME	BZK	Delayed	SU9			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
34275	PG0137	2017-08-16 10:25:00	2017-08-16 12:25:00	NAL	DME	Delayed	CR2			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
36780	PG0165	2017-08-16 07:35:00	2017-08-16 10:45:00	NUX	DME	Delayed	SU9			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
46165	PG0290	2017-08-15 12:15:00	2017-08-15 15:00:00	VKT	DME	Delayed	CR2			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
53170	PG0658	2017-08-16 09:10:00	2017-08-16 11:25:00	MCX	DME	Delayed	CR2			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
59329	PG0386	2017-08-15 16:45:00	2017-08-15 17:15:00	BZK	DME	Delayed	SU9			DME	{"en": "Domodedovo International Airport", "ru": "Домодедово"}	{"en": "Moscow", "ru": "Москва"}	(37.90629959106445,55.40879821777344)	Europe/Moscow
*/

# chenge
UPDATE flights
SET status = 'Cancelled'
WHERE flights.flight_id IN (
	SELECT flight_id
    FROM (
		SELECT flight_id
		FROM flights f
		INNER JOIN airports_data a
			ON (f.departure_airport = a.airport_code OR f.arrival_airport = a.airport_code)
		WHERE JSON_EXTRACT(airport_name, '$.ru') = 'Домодедово'
			AND status = 'Delayed'
		) AS a
)
;

# undo changes
UPDATE flights
SET status = 'Delayed'
WHERE flight_id IN (348, 761, 974, 2469, 5377, 5858, 34275, 36780, 46165, 53170, 59329)
;

# check
SELECT *
FROM flights
WHERE flight_id IN (348, 761, 974, 2469, 5377, 5858, 34275, 36780, 46165, 53170, 59329)
;