/*
Рекурсивные CTE (англ. Recursive Common Table Expressions) — 
это CTE, в состав которых входят запросы, использующие этот же CTE рекурсивно

Такие CTE позволяют относительно легко решать задачи, трудно решаемые иными способами:
- Работа с иерархическими структурами, такими как дерево
	- Иерархические структуры хорошо поддаются обработке с помощью рекурсии
- Генерация последовательностей значений

Иерархические структуры данных пока оставим в стороне: мы подробно обсудим их в будущих темах.
*/

/*
Математическая индукция

WITH RECURSIVE
Синтаксические правила:
- Если секция WITH содержит хотя бы один рекурсивный CTE, то следует писать WITH RECURSIVE
- Рекурсивный CTE должен содержать два запроса, соединённых с помощью UNION DISTINCT либо UNION ALL
- Первый запрос возвращает таблицу с начальными значениями
- Второй запрос совершает шаг индукции: генерирует новую таблицу на основе результатов с предыдущего шага 

Рекурсивные CTE на уровне СУБД выполняются итеративно, а не рекурсивно. Слово «рекурсивный» 
указывает на возможность CTE указывать на самого себя, а не на способ выполнения.

Синтаксис:
WITH RECURSIVE cte AS (
  -- начальные значения (базис индукции)
  SELECT ... 
  -- ALL либо DISTINCT
  UNION ALL
  -- шаг рекурсии (шаг индукции)
  SELECT ... FROM cte WHERE ...
)
SELECT ...
FROM cte
...

Два рекурсивных CTE не могут ссылаться друг на друга, потому что CTE 
не может ссылаться на ранее объявленный CTE.
*/

/*
Пример
Сгенерируем последовательность календарных дат с 2024-02-01 по 2024-03-31 включительно:
*/
WITH RECURSIVE dates (date) AS (
  SELECT
    '2024-02-01'

  UNION ALL

  SELECT
    DATE_ADD(date, INTERVAL 1 DAY)
  FROM dates
  WHERE date < '2024-03-31'
)
SELECT *
FROM dates
;
/*
В данном запросе мы использовали:
- WITH RECURSIVE — запрос содержит рекурсивные CTE
- dates (date) — здесь dates задаёт название CTE, а (date) — названия его колонок
- выражение DATE_ADD(date, INTERVAL 1 DAY) для получения следующей даты
- условие для прекращения рекурсии WHERE date < '2024-03-31'

Рекурсия в рекурсивном CTE прекращается, когда очередной шаг рекурсии выдаёт ноль результатов.
*/

/*
Пример посложнее
Задача:
- Вывести ежедневное расписание вылетов из аэропорта города Усинск 
(код аэропорта USK), включая дни, когда вылетов нет.

Для решения данной задачи воспользуемся рекурсивными CTE, в том числе генерацией списка дат, показанной ранее.
У нас будет три CTE:
- usk_flights — не рекурсивный
- min_max_date — не рекурсивный, зависит от usk_flights
- dates — рекурсивный, зависит от min_max_date

Основной запрос будет использовать соединение dates и usk_flights.

CTE usk_flights
CTE usk_flights содержит заранее выбранные данные о рейсах из аэропорта Усинск (USK):
	Выбираем для рейсов из Усинска:
		1. номер рейса
		2. дату вылета
		3. название аэропорта прибытия
SELECT
  f.flight_id,
  DATE(scheduled_departure) AS date,
  arr_ad.airport_name ->> '$.ru' AS arrival_airport_name
FROM flights f
  LEFT JOIN airports_data arr_ad
    ON f.arrival_airport = arr_ad.airport_code
WHERE f.departure_airport = 'USK'

CTE min_max_date
Из таблицы usk_flights выберем из неё максимальную и минимальную даты 
и назовём результат таблицей min_max_date:
SELECT
  MIN(f.date),
  MAX(f.date)
FROM usk_flights f;

Рекурсивный CTE dates
Для генерации списка дат будем использовать результат предыдущего запроса и пример, 
показанный ранее, а результат назовём dates:
	Генерация отрезка дат [min_date, max_date]
SELECT
  min_date
FROM min_max_date

UNION ALL

SELECT
  DATE_ADD(date, INTERVAL 1 DAY)
FROM dates
WHERE date < (
  SELECT
    max_date
  FROM min_max_date
  LIMIT 1
)

Финальный запрос
Для вывода ежедневного расписания:
- Укажем в секции WITH RECURSIVE три предыдущих CTE
- Выполним соединение двух CTE: dates и usk_flights
- Добавим GROUP BY d.date и агрегирующую функцию GROUP_CONCAT
Получаем такой SQL-запрос:
WITH RECURSIVE
  -- Выбрать рейсы аэропорта Усинск (код USK)
  usk_flights AS (
    SELECT
      f.flight_id,
      DATE(scheduled_departure) AS date,
      arr_ad.airport_name ->> '$.ru' AS arrival_airport_name
    FROM flights f
      LEFT JOIN airports_data arr_ad
        ON f.arrival_airport = arr_ad.airport_code
    WHERE f.departure_airport = 'USK'
  ),
  -- Выбрать края диапазона дат
  min_max_date (min_date, max_date) AS (
    SELECT
      MIN(f.date),
      MAX(f.date)
    FROM usk_flights f
  ),
  -- Сгенерировать диапазон дат
  dates (date) AS (
    SELECT
      min_date
    FROM min_max_date

    UNION ALL

    SELECT
      DATE_ADD(date, INTERVAL 1 DAY)
    FROM dates
    WHERE date < (
      SELECT
        max_date
      FROM min_max_date
      LIMIT 1
    )
  )
SELECT
  d.date,
  GROUP_CONCAT(f.arrival_airport_name) AS arrival_airports
FROM dates d
  LEFT JOIN usk_flights f ON d.date = f.date
GROUP BY d.date
;
*/

/*
Подытожим
- Рекурсивные CTE (англ. Recursive Common Table Expressions) — это CTE, 
в состав которых входят запросы, использующие этот же CTE рекурсивно
- Такие CTE позволяют относительно легко решать две задачи:
	- Работа с иерархическими структурами, такими как дерево
	- Генерация последовательностей значений
- Если в запросе есть рекурсивный CTE, то следует писать WITH RECURSIVE вместо WITH
- Рекурсивный CTE должен содержать два запроса, соединённых с помощью UNION DISTINCT либо UNION ALL
	- Первый запрос возвращает таблицу с начальными значениями
	- Второй запрос совершает шаг индукции: генерирует новую таблицу на основе результатов с предыдущего шага 
- Для понимания рекурсивных CTE рассматривайте их как аналог математической индукции
*/





















