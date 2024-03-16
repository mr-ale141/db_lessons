/*
В SQL есть две возможности:
- Добавлять выборку строк по предикату с помощью WHERE
- Группировать и агрегировать значения с помощью GROUP BY и агрегирующих функций
При этом выборка по предикату, указанному в секции WHERE, происходит прежде группировки и агрегации.
А что если потребуется фильтровать строки результатов агрегации?
На этот случай в SQL есть секция HAVING:
- HAVING содержит условие, в котором можно использовать логические и иные операторы
- HAVING эквивалентен WHERE, но в случае HAVING операция выборки выполняется после группировки и агрегации

FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
*/
USE bookings;

/*
Ищем бронирования с несколькими билетами
*/
SELECT
  b.book_ref,
  COUNT(*)
FROM bookings b
	INNER JOIN tickets t ON b.book_ref = t.book_ref
GROUP BY b.book_ref
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 8
;

/*
Далее мы можем составить новый запрос, который соберёт информацию о пассажирах и рейсах в этих билетах:
*/
SELECT
  t.passenger_name,
  GROUP_CONCAT(
    CONCAT(f.departure_airport, '->', f.arrival_airport)
    SEPARATOR ', '
  ) AS ticket_route
FROM tickets t
  INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
  INNER JOIN flights f ON tf.flight_id = f.flight_id
WHERE book_ref = 'E4BF84'
GROUP BY t.ticket_no
;

/*
Чтобы расшифровать коды аэропортов AER и SVO, используем такой запрос:
*/
SELECT
  airport_code AS code,
  airport_name->>'$.ru' AS name
FROM airports_data
WHERE airport_code IN ('SVO', 'AER')
;

/*
Недостаток HAVING в том, что он выполняется на поздних стадиях запроса
- HAVING выполняется после GROUP BY и перед ORDER BY
- как следствие, условие в HAVING не поддаётся оптимизации

По стандарту SQL в HAVING можно использовать:
- Колонки, указанные в GROUP BY
- Вызовы агрегирующих функций либо их синонимы, указанные в списке выбора (SELECT ...)
Диалект MySQL расширяет это поведение и позволяет использовать в HAVING любые результаты из списка выбора (SELECT ...).
*/




















