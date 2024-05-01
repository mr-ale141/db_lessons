CREATE SCHEMA IF NOT EXISTS `bad_roads` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bad_roads`.`department`
(
    `id` INT UNSIGNED AUTO_INCREMENT,
    `city` VARCHAR(45) NOT NULL,
    `address` VARCHAR(100) NOT NULL,
    `zip_code` INT NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `email` VARCHAR(100) NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `bad_roads`.`employee`
(
    `id` INT UNSIGNED AUTO_INCREMENT,
    `department_id` INT UNSIGNED NOT NULL,
    `firstname` VARCHAR(45) NOT NULL,
    `middlename` VARCHAR(45) NOT NULL,
    `lastname` VARCHAR(45) NULL,
    `sex` ENUM('M', 'F') NOT NULL,
    `birth_date` DATE NOT NULL,
    `experience` DECIMAL(3,1) NULL,
    `address` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NULL,
    `email` VARCHAR(100) NULL,
    `password` VARCHAR(45) NULL,
    `employment` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `position` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY fk_department_id_key (`department_id`)
        REFERENCES `bad_roads`.`department` (`id`)
        ON UPDATE CASCADE ON DELETE CASCADE
);