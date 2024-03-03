# Выбрать всю информацию о рейсах (flights) на самолёте Сухой Суперджет-100, для которых аэропорт Чебоксар является пунктом отправления либо прибытия

use bookings;

SELECT aircraft_code
FROM aircrafts_data
WHERE JSON_EXTRACT(model, '$.ru') = 'Сухой Суперджет-100'
;

SELECT airport_code 
FROM airports_data
WHERE JSON_EXTRACT(city, '$.ru') = 'Чебоксары'
;

EXPLAIN ANALYZE
SELECT *
FROM flights f
INNER JOIN airports_data c
	ON (f.arrival_airport = c.airport_code OR f.departure_airport = c.airport_code)
INNER JOIN aircrafts_data a
	ON (f.aircraft_code = a.aircraft_code)
WHERE JSON_EXTRACT(model, '$.ru') = 'Сухой Суперджет-100' 
	AND JSON_EXTRACT(city, '$.ru') = 'Чебоксары'
;

/*
id	select_type	table	partitions	type	possible_keys																			key		key_len	ref							rows	filtered	Extra
1	SIMPLE		c					ALL		PRIMARY																																104		100.00		Using where
1	SIMPLE		f					ALL		flights_aircraft_code_fkey,flights_arrival_airport_fkey,flights_departure_airport_fkey												65589	1.94		Range checked for each record (index map: 0x1C)
1	SIMPLE		a					eq_ref	PRIMARY																					PRIMARY	12		bookings.f.aircraft_code	1		100.00		Using where


-> Nested loop inner join  (cost=695954.67 rows=132477) (actual time=0.631..4.873 rows=484 loops=1)
    -> Nested loop inner join  (cost=682388.54 rows=132477) (actual time=0.181..3.780 rows=1210 loops=1)
        -> Filter: (json_extract(c.city,'$.ru') = 'Чебоксары')  (cost=11.15 rows=104) (actual time=0.060..0.201 rows=1 loops=1)
            -> Table scan on c  (cost=11.15 rows=104) (actual time=0.024..0.140 rows=104 loops=1)
        -> Filter: ((f.arrival_airport = c.airport_code) or (f.departure_airport = c.airport_code))  (cost=3.65 rows=1274) (actual time=0.120..3.515 rows=1210 loops=1)
            -> Index range scan on f (re-planned for each iteration)  (cost=3.65 rows=65589) (actual time=0.118..3.155 rows=1210 loops=1)
    -> Filter: (json_extract(a.model,'$.ru') = 'Сухой Суперджет-100')  (cost=0.00 rows=1) (actual time=0.001..0.001 rows=0 loops=1210)
        -> Single-row index lookup on a using PRIMARY (aircraft_code=f.aircraft_code)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=1210)
*/























SELECT flights.*
FROM flights, (
	SELECT airport_code 
	FROM airports_data
	WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
    LIMIT 1
) AS city, (
	SELECT aircraft_code
	FROM aircrafts_data
	WHERE JSON_EXTRACT(model, '$.ru') = 'Сухой Суперджет-100'
    LIMIT 1
) AS aircraft,
WHERE departure_airport = city_code.airport_code
	OR arrival_airport = city_code.airport_code
;

EXPLAIN
WITH d AS (
	SELECT *
	FROM (
		SELECT aircraft_code
		FROM aircrafts_data
		WHERE JSON_EXTRACT(model, '$.ru') = 'Сухой Суперджет-100'
        LIMIT 1
	)a, (
		SELECT airport_code 
		FROM airports_data
		WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
        LIMIT 1
	)b
)
SELECT *
FROM flights, d
WHERE (departure_airport = d.airport_code AND aircraft_code = d.aircraft_code)
	OR (arrival_airport = d.airport_code AND aircraft_code = d.aircraft_code)
;