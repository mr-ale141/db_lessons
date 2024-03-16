USE bookings;

SELECT
	t.ticket_no,
    MAX(amount)
FROM tickets t
	INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
GROUP BY t.ticket_no
HAVING amount < 10000
;

EXPLAIN ANALYZE
SELECT COUNT(*) AS count_seats
FROM seats
WHERE aircraft_code = 'SU9'
;

SELECT COUNT(fare_conditions)
FROM seats
WHERE aircraft_code = 'SU9'
;

SELECT DISTINCT fare_conditions
FROM seats
WHERE aircraft_code = 'SU9'
;

SELECT COUNT(DISTINCT fare_conditions)
FROM seats
WHERE aircraft_code = 'SU9'
;

EXPLAIN ANALYZE
SELECT
  COUNT(*) AS bookings_count,
  SUM(total_amount) AS sum_total,
  MIN(total_amount) AS min_total,
  AVG(total_amount) AS avg_total,
  MAX(total_amount) AS max_total
FROM bookings
;

SELECT
  aircraft_code AS aircraft,
  COUNT(*)
FROM seats
GROUP BY aircraft_code
;

SELECT
  aircraft_code AS aircraft,
  COUNT(*) AS seat_count
FROM seats
GROUP BY aircraft_code
ORDER BY seat_count DESC
;

SELECT @@sql_mode;

/*
Пример с ANY_VALUE
SELECT
  c.client_id,
  c.first_name,
  c.last_name,
  ANY_VALUE(ce.email)
FROM client c
  INNER JOIN client_email ce ON ce.client_id = c.client_id
GROUP BY c.client_id
*/

/*
GROUP_CONCAT — агрегирующая функция, которая объединяет все значения в группе, 
отличные от NULL, в одно значение строкового типа с заданным разделителем
(по умолчанию разделитель — запятая).

SELECT
  c.first_name,
  c.last_name,
  GROUP_CONCAT(ce.email) AS emails
FROM client c
  LEFT JOIN client_email ce ON c.id = ce.client_id
WHERE c.id = 1
*/

/*
Функция GROUP_CONCAT() также поддерживает:
- Упорядочивание значений с помощью ORDER BY
- Изменение разделителя с помощью SEPARATOR

SELECT
  c.first_name,
  c.last_name,
  GROUP_CONCAT(
    ce.email
    ORDER BY ce.email DESC
    SEPARATOR ' -- '
  ) AS emails
FROM client c
  LEFT JOIN client_email ce ON c.id = ce.client_id
GROUP BY c.id
;
*/

/*
Такое решение обычно имеет неэффективный план, 
т.к. СУБД приходится группировать результат декартова 
произведения client_email и client_phone. 
Подзапросы с GROUP_CONCAT() справились бы лучше.
SELECT
  c.first_name,
  c.last_name,
  GROUP_CONCAT(DISTINCT ce.email) AS emails,
  GROUP_CONCAT(DISTINCT cp.phone) AS phones
FROM client c
  LEFT JOIN client_email ce ON c.id = ce.client_id
  LEFT JOIN client_phone cp ON c.id = cp.client_id
WHERE c.id = 1
;
*/

/*
Функция JSON_ARRAYAGG(value) — агрегирующая функция, 
которая объединяет все значения в группе, включая NULL, 
в правильно экранированный JSON-массив
SELECT
  c.first_name,
  c.last_name,
  JSON_ARRAYAGG(cp.phone) AS phones
FROM client c
  LEFT JOIN client_phone cp ON c.id = cp.client_id
GROUP BY c.id
;
*/





























