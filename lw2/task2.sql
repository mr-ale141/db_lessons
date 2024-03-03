# Выбрать всю информацию о рейсах (flights), для которых аэропорт Краснодар является пунктом отправления либо прибытия

USE bookings;

SHOW COLUMNS FROM airports_data;

SHOW INDEXES FROM flights;

SELECT airport_code 
FROM airports_data
WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
;

EXPLAIN
SELECT flights.*
FROM flights, (
	SELECT airport_code 
	FROM airports_data
	WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
    LIMIT 1
) AS city
WHERE departure_airport = city.airport_code
	OR arrival_airport = city.airport_code
;

EXPLAIN
WITH city AS (
	SELECT airport_code 
	FROM airports_data
	WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
    LIMIT 1
)
SELECT *
FROM flights, city
WHERE departure_airport = city.airport_code
	OR arrival_airport = city.airport_code
;
/*
id	select_type	table			partitions	type		possible_keys												key															key_len	ref	rows	filtered	Extra
1	PRIMARY		<derived2>					system																																			1		100.00	
1	PRIMARY		flights						index_merge	flights_arrival_airport_fkey,flights_departure_airport_fkey	flights_departure_airport_fkey,flights_arrival_airport_fkey	12,12		932		100.00		Using union(flights_departure_airport_fkey,flights_arrival_airport_fkey); Using where
2	DERIVED		airports_data				ALL																																				104		100.00		Using where


-> Filter: ((flights.departure_airport = 'KRR') or (flights.arrival_airport = 'KRR'))  (cost=406.19 rows=932) (actual time=0.149..2.754 rows=935 loops=1)
    -> Deduplicate rows sorted by row ID  (cost=406.19 rows=932) (actual time=0.146..2.510 rows=935 loops=1)
        -> Index range scan on flights using flights_departure_airport_fkey over (departure_airport = 'KRR')  (cost=48.59 rows=468) (actual time=0.062..0.350 rows=468 loops=1)
        -> Index range scan on flights using flights_arrival_airport_fkey over (arrival_airport = 'KRR')  (cost=47.19 rows=467) (actual time=0.023..0.327 rows=467 loops=1)


*/


EXPLAIN 
SELECT *
FROM flights f
INNER JOIN airports_data c
	ON (f.arrival_airport = c.airport_code OR f.departure_airport = c.airport_code)
WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
;
/*
id	select_type	table	partitions	type	possible_keys												key	key_len	ref	rows	filtered	Extra
1	SIMPLE		c					ALL		PRIMARY																		104		100.00		Using where
1	SIMPLE		f					ALL		flights_arrival_airport_fkey,flights_departure_airport_fkey					65589	1.94		Range checked for each record (index map: 0x18)
        
-> Nested loop inner join  (cost=682388.54 rows=132477) (actual time=0.219..2.803 rows=935 loops=1)
    -> Filter: (json_extract(c.city,'$.ru') = 'Краснодар')  (cost=11.15 rows=104) (actual time=0.091..0.200 rows=1 loops=1)
        -> Table scan on c  (cost=11.15 rows=104) (actual time=0.023..0.135 rows=104 loops=1)
    -> Filter: ((f.arrival_airport = c.airport_code) or (f.departure_airport = c.airport_code))  (cost=3.65 rows=1274) (actual time=0.127..2.550 rows=935 loops=1)
        -> Index range scan on f (re-planned for each iteration)  (cost=3.65 rows=65589) (actual time=0.125..2.308 rows=935 loops=1)
*/
