USE bookings;

/*
Требуется написать SQL-запрос, который выбирает все билеты на имя 'MARINA NIKOLAEVA', 
где первый перелёт совершается из московского аэропорта Домодедово (код аэропорта 'DME').
*/

SELECT *
FROM tickets t
  INNER JOIN ticket_flights tf
    ON tf.ticket_no = t.ticket_no
      AND tf.flight_id = (
        SELECT
          tf2.flight_id
        FROM ticket_flights tf2
          INNER JOIN flights f2 ON tf2.flight_id = f2.flight_id
        WHERE tf2.ticket_no = t.ticket_no
        ORDER BY f2.scheduled_departure
        LIMIT 1
      )
  INNER JOIN flights f ON tf.flight_id = f.flight_id
WHERE t.passenger_name = 'MARINA NIKOLAEVA'
  AND f.departure_airport = 'DME'
;


-- Подзапрос в списке выбора
-- SELECT a, b, c + d AS c_d, (SELECT ...) AS e
/*
Разумеется, такой подзапрос должен быть скалярным, т.е. возвращающим ровно одно значение
- В некоторых случаях единственность результата подзапроса обеспечивается 
автоматически схемой и данными БД
- В других случаях ограничить подзапрос одним значением можно с помощью ORDER BY и LIMIT, 
или с помощью агрегирующей функции

Ранее мы рассматривали пример базы данных, где есть данные о клиентах компании, 
их email-адресах и номерах телефонов:
Прежде мы решали эту задачу с помощью JOIN с агрегацией:
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
Но это не самое удачное решение — а что если клиент имеет 100 email-адресов и 50 номеров телефона?
- Такое количество email-адресов и номеров телефона вполне возможно для тестовых данных, созданных 
долгим ручным тестированием продукта
- Декартово произведение приведёт к появлениию 100×50=5000 промежуточных результатов, которые 
затем будут агрегированы

Оптимальное решение использует коррелированные подзапросы в списке выбора:
SELECT
  c.first_name,
  c.last_name,
  GROUP_CONCAT(
    (SELECT email FROM client_email WHERE client_id = c.client_id)
  ) AS emails,
  GROUP_CONCAT(
    (SELECT phone FROM client_phone WHERE client_id = c.client_id)
  ) AS phones
FROM client c
WHERE c.id = 1
;
В этом варианте СУБД обработает 100+50=150 строк в подзапросах вместо 100×50=5000 строк 
в агрегации результатов соединения.
*/

-- Подзапрос в WHERE и ORDER BY
/*
Выбрать до 10 билетов с наибольшим количеством перелётов на имя Марины Николаевой
Решение — ORDER BY с подзапросом и затем LIMIT 10:
*/
SELECT *
FROM tickets t
WHERE t.passenger_name = 'MARINA NIKOLAEVA'
ORDER BY (
  SELECT
    COUNT(*)
  FROM ticket_flights tf
  WHERE tf.ticket_no = t.ticket_no
) DESC
LIMIT 10;

/*
Подытожим
- Скалярные подзапросы возвращают ровно одно значение
- Подзапросы можно использовать в условии соединения, например, чтобы при наличии связи 
«один-ко-многим» между A и B соединять A только с одной избранной строкой B
- Подзапросы могут помочь в списке выбора как альтернатива неподходящим соединениям
	- Неподходящие соединения могут резко увеличить число результов, потому что соединение — 
это выборка из декартова произведения
- Подзапросы можно использовать как выражение в секции WHERE
- Подзапросы можно использовать как ключ сортировки в секции ORDER BY
*/




























