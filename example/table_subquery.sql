USE bookings;

SELECT *
FROM airports_data
LIMIT 10
;

SHOW CREATE TABLE airports_data;

-- города с несколькими аэропортами
SELECT
  city->>'$.ru' AS city,
  GROUP_CONCAT(airport_code) AS airport_codes
FROM airports_data
GROUP BY city
HAVING COUNT(*) > 1
;

-- Как получить информацию об аэропортах из этих двух городов?
-- Первый способ — использовать результаты прошлого SQL-запроса при написании следующего:
SELECT
  a.airport_code AS code,
  a.airport_name ->> '$.ru' AS name,
  a.city ->> '$.ru' AS city
FROM airports_data a
WHERE city -> '$.ru' IN ('Москва', 'Ульяновск')
ORDER BY city
;

-- Второй способ - Объединим оба запроса в один:
SELECT
  a.airport_code AS code,
  a.airport_name->>'$.ru' AS name,
  a.city->>'$.ru' AS city
FROM (
  SELECT
    city
  FROM airports_data
  GROUP BY city
  HAVING COUNT(*) > 1
) tmp
  INNER JOIN airports_data a ON tmp.city = a.city
;

-- Третий способ - оператор IN
SELECT
  airport_code AS code,
  airport_name ->> '$.ru' AS name,
  city ->> '$.ru' AS city
FROM airports_data
WHERE city IN (
  SELECT
    city
  FROM airports_data
  GROUP BY city
  HAVING COUNT(*) > 1
)
;

/*
Коррелированный подзапрос (англ. Correlated Subquery) — это подзапрос, 
который ссылается на колонки или выражения из внешнего запроса
Пример:
SELECT
  ...
FROM table_1 t1
WHERE t1.column_1 IN (
  SELECT t2.column_2 FROM table_2 t2 WHERE t2.column = t1.column
)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Логически коррелированный подзапрос выполняется каждый раз 
для каждой строки внешнего запроса.

Пример коррелированного подзапроса
В базе данных «Авиаперевозки» есть связанные таблицы tickets и ticket_flights:
Задача: выбрать билеты, в которых все перелёты имеют класс обслуживания «бизнес» ('Business').
Решим задачу помощью коррелированного подзапроса и оператора ALL:
*/

SELECT
  t.ticket_no,
  t.passenger_id,
  t.passenger_name
FROM tickets t
WHERE 'Business' = ALL (
  SELECT
    fare_conditions
  FROM ticket_flights tf
  WHERE tf.ticket_no = t.ticket_no
);

/*
Подытожим
- Подзапрос (англ. subquery) — это SQL-запрос, используемый внутри 
другого SQL-запроса для получения одного значения, списка значений или входной таблицы
- Табличные подзапросы возвращают таблицу со строками, колонками и значениями на 
пересечении строк и колонок
- Если результирующая таблица содержит лишь одну колонку, то логически ещё можно 
интерпретировать как список значений
- Скалярные подзапросы возвращают ровно одно значение
- Табличные подзапросы можно использовать в секции FROM, л
ибо в составе операторов IN, ALL, ANY (SOME)
- Коррелированный подзапрос (англ. Correlated Subquery) — это подзапрос, 
который ссылается на колонки или выражения из внешнего запроса
*/














