/*
Представления — это виртуальные таблицы, содержимое которых 
выбирается SQL-запросом из других таблиц

Представление можно рассматривать как SQL-запрос, который получил имя 
и был сохранён в базу данных для повторного использования.

CREATE VIEW view_name AS
SELECT ...
FROM ...
*/

/*
Рассмотрим задачу:
Обеспечить возможность упрощённого получения данных для информационного 
табло с расписанием вылетов из заданного аэропорта

Мы обеспечим такую возможность с помощью представления flights_schedule_view:
*/
CREATE OR REPLACE VIEW flights_schedule_view AS
SELECT
  f.flight_no,
  f.departure_airport,
  f.scheduled_departure,
  f.arrival_airport,
  arr_a.airport_name ->> '$.ru'
    AS arrival_airport_name,
  status
FROM flights f
  INNER JOIN airports_data arr_a
    ON f.arrival_airport = arr_a.airport_code
WHERE f.status IN (
                   'On Time',
                   'Delayed'
	)
;
/*
В этом запросе:
- Команда CREATE VIEW задана в форме CREATE OR REPLACE VIEW, что приводит 
к замене представления с таким именем, если оно уже существовало
 Представление задано SELECT-запросом, читающим данные из соединения таблиц flights и airports_data
- Выбираются только рейсы в статусах 'On Time' и 'Delayed':
	- Статус 'On Time' означает, что рейс доступен для регистрации и не задержан
	- Статус 'Delayed' означает, что рейс доступен для регистрации и при этом задержан
	- Рейсы становятся доступными для регистрации за сутки до вылета
    
Использование представления
Напишем простой запрос для получения информации о вылетах из аэропорта Казани (код аэропорта KZN):
*/
SELECT
  TIME(scheduled_departure) AS time,
  flight_no,
  arrival_airport_name AS direction,
  status
FROM flights_schedule_view
WHERE departure_airport = 'KZN'
ORDER BY scheduled_departure
;

/*
Подытожим
- В SQL доступно три механизма, основанных на вложенных запросах
	- Подзапросы — SQL-запросы, вложенные в другие SQL-запросы
	- CTE — именованные подзапросы, объявленные в секции WITH
	- Представления — виртуальные таблицы, содержимое которых выбирается SQL-запросом из других таблиц
- Представление логически неотличимо от таблицы с аналогичными данными
- Использование представления эквивалентно использованию подзапроса
- Аналогично CTE, представления в MySQL обрабатываются одним из двух алгоритмов
	- Слияние (merge) SQL-запроса из представления с основным SQL-запросом
	- Материализация результатов SQL-запроса из представления во временную таблицу
- Некоторые СУБД, такие как PostgreSQL или Microsoft SQL Server, предлагают материализованные 
представления (англ. Materialized View)
	- Такие представления можно рассматривать как простой аналог более сложных решений, используемых 
    при создании Data Warehouse (сокр. DWH)
- Представление можно заменить физической view-таблицей, управляемой приложением
	- это мощный инструмент в руках опытных команд разработчиков, умеющих использовать базы данных правильно
	- командам без соответствующей экспертизы лучше всё-таки использовать представления
*/






























