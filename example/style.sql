-- Запрос данных
SELECT *
FROM flights
WHERE arrival_airport = 'DME'
;

-- Вставка новых строк
INSERT INTO blog_tag (title)
VALUES ('С мясом'),
  ('С рыбой'),
  ('С овощами'),
  ('Из теста'),
  ('Диета')
;

-- Обновление данных существующих строк
UPDATE client
SET first_name = 'Порфирий',
  last_name = 'Афанасьев'
WHERE id = 81;

-- Удаление существующих строк
DELETE
FROM lead_event
WHERE created_at < '2013-01-01'
ORDER BY created_at
LIMIT 1000;

-- Создание таблицы (DDL)
CREATE TABLE client_email (
  client_id INT UNSIGNED NOT NULL,
  email VARCHAR(100) NOT NULL,
  PRIMARY KEY (client_id, email),
  CONSTRAINT fk_client_email_client_id
    FOREIGN KEY (client_id)
      REFERENCES client(id)
      ON DELETE CASCADE
);