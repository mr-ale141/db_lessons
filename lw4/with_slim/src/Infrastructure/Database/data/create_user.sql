CREATE USER IF NOT EXISTS 'php'@'%' IDENTIFIED BY 'Qwerty!12345';

CREATE DATABASE 'bad_roads';
GRANT ALL ON 'bad_roads'.* TO 'php'@'%';
