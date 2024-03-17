/*
Выбрать номер рейса, дату-время отправления и дату-время прибытия 
последнего по времени отправления рейса, прибывшего из Краснодара в Калининград
- Следует выбирать только рейсы в состоянии 'Arrived'
- Даты отправления и прибытия следует выбирать фактические, а не запланированные
*/

EXPLAIN ANALYZE
SELECT
	ANY_VALUE(f.flight_no),
    f.actual_departure,
    ANY_VALUE(f.actual_arrival)
FROM flights f
INNER JOIN airports_data a
	ON (f.departure_airport = a.airport_code OR f.arrival_airport = a.airport_code)
WHERE f.status = 'Arrived' 
    AND f.departure_airport = (
		SELECT airport_code 
		FROM airports_data
		WHERE JSON_EXTRACT(city, '$.ru') = 'Краснодар'
		LIMIT 1)
	AND f.arrival_airport = (
		SELECT airport_code 
		FROM airports_data
		WHERE JSON_EXTRACT(city, '$.ru') = 'Калининград'
		LIMIT 1)
GROUP BY f.actual_departure 
ORDER BY f.actual_departure DESC
LIMIT 1
;

/*
EXPLAIN: 
-> Limit: 1 row(s)  (actual time=1.2..1.2 rows=1 loops=1)
    -> Sort: f.actual_departure DESC, limit input to 1 row(s) per chunk  (actual time=1.2..1.2 rows=1 loops=1)
        -> Table scan on <temporary>  (cost=6.86..6.86 rows=0.4) (actual time=1.17..1.17 rows=26 loops=1)
            -> Temporary table with deduplication  (cost=4.36..4.36 rows=0.4) (actual time=1.16..1.16 rows=26 loops=1)
                -> Filter: ((a.airport_code = (select #2)) or (a.airport_code = (select #3)))  (cost=4.32 rows=0.4) (actual time=1.02..1.06 rows=52 loops=1)
                    -> Inner hash join (no condition)  (cost=4.32 rows=0.4) (actual time=1.02..1.04 rows=52 loops=1)
                        -> Covering index range scan on a using PRIMARY over (airport_code = 'KGD') OR (airport_code = 'KRR')  (cost=1.71 rows=2) (actual time=0.0094..0.0141 rows=2 loops=1)
                        -> Hash
                            -> Filter: ((f.arrival_airport = (select #3)) and (f.departure_airport = (select #2)) and (f.`status` = 'Arrived'))  (cost=4.14 rows=0.2) (actual time=0.767..0.984 rows=26 loops=1)
                                -> Intersect rows sorted by row ID  (cost=4.14 rows=2.23) (actual time=0.762..0.96 rows=35 loops=1)
                                    -> Index range scan on f using flights_arrival_airport_fkey over (arrival_airport = 'KGD')  (cost=1.58 rows=312) (actual time=0.1..0.397 rows=312 loops=1)
                                    -> Index range scan on f using flights_departure_airport_fkey over (departure_airport = 'KRR')  (cost=1.86 rows=468) (actual time=0.0323..0.34 rows=468 loops=1)
                                -> Select #3 (subquery in condition; run only once)
                                    -> Limit: 1 row(s)  (cost=11.2 rows=1) (actual time=0.0674..0.0675 rows=1 loops=1)
                                        -> Filter: (json_extract(airports_data.city,'$.ru') = 'Калининград')  (cost=11.2 rows=104) (actual time=0.0666..0.0666 rows=1 loops=1)
                                            -> Table scan on airports_data  (cost=11.2 rows=104) (actual time=0.0129..0.0462 rows=31 loops=1)
                                -> Select #2 (subquery in condition; run only once)
                                    -> Limit: 1 row(s)  (cost=11.2 rows=1) (actual time=0.179..0.179 rows=1 loops=1)
                                        -> Filter: (json_extract(airports_data.city,'$.ru') = 'Краснодар')  (cost=11.2 rows=104) (actual time=0.178..0.178 rows=1 loops=1)
                                            -> Table scan on airports_data  (cost=11.2 rows=104) (actual time=0.0634..0.115 rows=37 loops=1)
                    -> Select #2 (subquery in condition; run only once)
                        -> Limit: 1 row(s)  (cost=11.2 rows=1) (actual time=0.179..0.179 rows=1 loops=1)
                            -> Filter: (json_extract(airports_data.city,'$.ru') = 'Краснодар')  (cost=11.2 rows=104) (actual time=0.178..0.178 rows=1 loops=1)
                                -> Table scan on airports_data  (cost=11.2 rows=104) (actual time=0.0634..0.115 rows=37 loops=1)
                    -> Select #3 (subquery in condition; run only once)
                        -> Limit: 1 row(s)  (cost=11.2 rows=1) (actual time=0.0674..0.0675 rows=1 loops=1)
                            -> Filter: (json_extract(airports_data.city,'$.ru') = 'Калининград')  (cost=11.2 rows=104) (actual time=0.0666..0.0666 rows=1 loops=1)
                                -> Table scan on airports_data  (cost=11.2 rows=104) (actual time=0.0129..0.0462 rows=31 loops=1)
*/