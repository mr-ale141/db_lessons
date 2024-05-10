CREATE DATABASE tree_of_life;

CREATE USER 'tree-of-life-app'@'%' IDENTIFIED BY 'Qwerty!12345';

GRANT ALL ON tree_of_life.* TO 'tree-of-life-app'@'%';
