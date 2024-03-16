/*
SELECT
  c.id,
  pf.name,
  cpf.value
FROM client c
  INNER JOIN client_profile_field cpf ON c.id = cpf.client_id
  INNER JOIN profile_field pf ON cpf.field_id = pf.id
WHERE c.id = 1
;
+--+----------+---------------------+
|id|name      |value                |
+--+----------+---------------------+
|1 |first_name|Пётр                 |
|1 |last_name |Мелехов              |
|1 |email     |p.melehov@example.com|
|1 |phone     |+78362422930         |
+--+----------+---------------------+

Функция JSON_OBJECTAGG(key, value) — агрегирующая функция, 
которая объединяет все значения в группе, отличные от NULL, 
в правильно экранированный JSON-массив
SELECT
  c.id,
  JSON_OBJECTAGG(pf.name, cpf.value) AS profile
FROM client c
  INNER JOIN client_profile_field cpf ON c.id = cpf.client_id
  INNER JOIN profile_field pf ON cpf.field_id = pf.id
WHERE c.id = 1
;
+--+---------------------------------------------------------------------------------------------------------+
|id|profile                                                                                                  |
+--+---------------------------------------------------------------------------------------------------------+
|1 |{"email": "p.melehov@example.com", "phone": "+78362422930", "last_name": "Мелехов", "first_name": "Пётр"}|
+--+---------------------------------------------------------------------------------------------------------+
*/