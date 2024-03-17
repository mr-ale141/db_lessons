/*
Выбрать номер рейса, дату-время отправления и количество свободных 
мест класса Эконом для перелёта из Владивостока в Моску ближайшим рейсом
- Следует выбирать только рейсы в состоянии 'Scheduled'
*/

EXPLAIN ANALYZE
SELECT
	f.flight_no,
	f.scheduled_departure,
    COUNT(*) AS available_seats
FROM flights f
	INNER JOIN aircrafts_data ad ON ad.aircraft_code = f.aircraft_code
    INNER JOIN seats s ON s.aircraft_code = f.aircraft_code
    LEFT JOIN boarding_passes bp ON bp.flight_id = f.flight_id AND bp.seat_no = s.seat_no
WHERE f.status = 'Scheduled'
	AND s.fare_conditions = 'Economy'
    AND f.departure_airport IN (
		SELECT airport_code 
		FROM airports_data
		WHERE JSON_EXTRACT(city, '$.ru') = 'Владивосток')
	AND f.arrival_airport IN (
		SELECT airport_code 
		FROM airports_data
		WHERE JSON_EXTRACT(city, '$.ru') = 'Москва')
	AND bp.seat_no IS NULL
GROUP BY f.flight_no, f.scheduled_departure
ORDER BY f.scheduled_departure DESC
;

/*
EXPLAIN: 
-> Sort: f.scheduled_departure DESC  (actual time=14.2..14.2 rows=28 loops=1)
    -> Table scan on <temporary>  (actual time=14.2..14.2 rows=28 loops=1)
        -> Aggregate using temporary table  (actual time=14.2..14.2 rows=28 loops=1)
            -> Filter: (bp.seat_no is null)  (cost=184225 rows=79856) (actual time=0.605..12.2 rows=5376 loops=1)
                -> Nested loop antijoin  (cost=184225 rows=79856) (actual time=0.604..12 rows=5376 loops=1)
                    -> Nested loop inner join  (cost=105391 rows=79856) (actual time=0.592..3.86 rows=5376 loops=1)
                        -> Nested loop inner join  (cost=22555 rows=5367) (actual time=0.564..1.69 rows=28 loops=1)
                            -> Nested loop inner join  (cost=20676 rows=5367) (actual time=0.555..1.63 rows=85 loops=1)
                                -> Nested loop inner join  (cost=18797 rows=5367) (actual time=0.548..1.59 rows=85 loops=1)
                                    -> Filter: (json_extract(airports_data.city,'$.ru') = 'Владивосток')  (cost=11.2 rows=104) (actual time=0.167..0.174 rows=1 loops=1)
                                        -> Table scan on airports_data  (cost=11.2 rows=104) (actual time=0.025..0.111 rows=104 loops=1)
                                    -> Filter: (f.`status` = 'Scheduled')  (cost=129 rows=51.6) (actual time=0.38..1.42 rows=85 loops=1)
                                        -> Index lookup on f using flights_departure_airport_fkey (departure_airport=airports_data.airport_code)  (cost=129 rows=516) (actual time=0.377..1.4 rows=363 loops=1)
                                -> Single-row covering index lookup on ad using PRIMARY (aircraft_code=f.aircraft_code)  (cost=0.25 rows=1) (actual time=291e-6..306e-6 rows=1 loops=85)
                            -> Filter: (json_extract(airports_data.city,'$.ru') = 'Москва')  (cost=0.25 rows=1) (actual time=624e-6..640e-6 rows=0.329 loops=85)
                                -> Single-row index lookup on airports_data using PRIMARY (airport_code=f.arrival_airport)  (cost=0.25 rows=1) (actual time=188e-6..200e-6 rows=1 loops=85)
                        -> Filter: (s.fare_conditions = 'Economy')  (cost=0.556 rows=14.9) (actual time=0.0148..0.0728 rows=192 loops=28)
                            -> Index lookup on s using PRIMARY (aircraft_code=f.aircraft_code)  (cost=0.556 rows=149) (actual time=0.0146..0.0527 rows=222 loops=28)
                    -> Single-row covering index lookup on bp using boarding_passes_flight_id_seat_no_key (flight_id=f.flight_id, seat_no=s.seat_no)  (cost=0.887 rows=1) (actual time=0.00146..0.00146 rows=0 loops=5376)
*/

SELECT *
FROM boarding_passes
	WHERE flight_id IN (
		SELECT
			f.flight_id
		FROM flights f
		WHERE f.status = 'Scheduled'
			AND f.departure_airport = (
				SELECT airport_code 
				FROM airports_data
				WHERE JSON_EXTRACT(city, '$.ru') = 'Владивосток'
				LIMIT 1)
			AND f.arrival_airport IN (
				SELECT airport_code 
				FROM airports_data
				WHERE JSON_EXTRACT(city, '$.ru') = 'Москва')
	)
;
