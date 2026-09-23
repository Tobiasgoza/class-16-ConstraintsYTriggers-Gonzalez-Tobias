-- =====================================================================
-- CLASE 16: Constraints y Triggers
-- Organización: Villada-BD2
-- =====================================================================

-- ---------------------------------------------------------------------
-- PREPARACIÓN: Creación de la tabla employees (Ejercicios 1, 2, 3 y 5)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employeeNumber INT PRIMARY KEY,
    lastName VARCHAR(50) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    officeCode VARCHAR(10) NOT NULL,
    reportsTo INT,
    jobTitle VARCHAR(50) NOT NULL
);

-- Poblamos con datos de ejemplo
INSERT INTO employees (employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle) VALUES
(1002, 'Gonzalez', 'Tobias', 'x5800', 'tobiasgonzalezzar@gmail.com', '1', NULL, 'Dibujante'),
(1056, 'Grifin', 'Peter', 'x4611', 'PeterGrifin@gmail.com.com', '1', 1002, 'Comer'),
(1076, 'Simpson', 'Homero', 'x9273', 'HomeroChino@gmail.com', '1', 1002, 'Central Nuclear');


-- ---------------------------------------------------------------------
-- EJERCICIO 1: Insertar empleado con email NULL.
INSERT INTO employees (employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle) 
VALUES (1, 'Del Guesso', 'Pedro', 'x1111', NULL, '1', 1002, 'NO');

-- Da error porque la columna email tiene la restricción NOT NULL.


-- EJERCICIO 2: Updates en employeeNumber
-- Primer update (puede fallar si genera números negativos o duplicados de PK si no se maneja bien)
UPDATE employees SET employeeNumber = employeeNumber - 20;

-- Segundo update
UPDATE employees SET employeeNumber = employeeNumber + 20;



-- EJERCICIO 3: Agregar columna age con CHECK (16 a 70 años)
ALTER TABLE employees ADD COLUMN age INT;
ALTER TABLE employees ADD CONSTRAINT chk_age CHECK (age BETWEEN 16 AND 70);


-- EJERCICIO 4: Integridad referencial en Sakila (Explicativa)
-- La tabla 'film_actor' actúa como una tabla intermedia (o puente) para resolver la relación 
-- de muchos a muchos (N:M) que existe originalmente entre las entidades 'film' y 'actor'. 
-- A nivel de integridad referencial, esta tabla contiene dos claves foráneas (Foreign Keys): 
-- 'film_id' que referencia a la tabla 'film' y 'actor_id' que referencia a la tabla 'actor'. 
-- Esto garantiza la consistencia de los datos, asegurando que no se pueda registrar la participación 
-- de un actor en una película si dichos registros no existen previamente en sus respectivas tablas maestras.


-- EJERCICIO 5: Columnas lastUpdate y lastUpdateUser + Triggers de Auditoría
ALTER TABLE employees ADD COLUMN lastUpdate DATETIME;
ALTER TABLE employees ADD COLUMN lastUpdateUser VARCHAR(50);

-- Delimitador para crear los triggers en MySQL
DELIMITER //

-- Trigger BEFORE INSERT
CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = CURRENT_TIMESTAMP;
    SET NEW.lastUpdateUser = USER();
END//

-- Trigger BEFORE UPDATE
CREATE TRIGGER before_employee_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = CURRENT_TIMESTAMP;
    SET NEW.lastUpdateUser = USER();
END//

DELIMITER ;


-- EJERCICIO 6: Triggers de film_text en Sakila (Explicativa)
-- Para ver los triggers existentes en la base de datos Sakila, ejecutamos:
SHOW TRIGGERS LIKE 'film_text';

/* 
EXPLICACIÓN DE LOS TRIGGERS ASOCIADOS A 'film_text':

En la base de datos Sakila, la tabla 'film_text' mantiene una réplica 
optimizada para búsquedas de texto (Full-Text Search) de los campos 
'film_id', 'title' y 'description' de la tabla principal 'film'.
Para mantener ambas tablas sincronizadas automáticamente, se utilizan 
tres triggers:
*/

-- 1. Trigger de INSERCIÓN (ins_film)
-- Se dispara DESPUÉS de insertar una nueva película en la tabla 'film'.
-- Su función es insertar automáticamente el nuevo registro en 'film_text' 
-- copiando el ID, el título y la descripción correspondientes.
-- Código conceptual interno:
-- INSERT INTO film_text (film_id, title, description)
-- VALUES (NEW.film_id, NEW.title, NEW.description);

-- 2. Trigger de ACTUALIZACIÓN (upd_film)
-- Se dispara DESPUÉS de modificar una película en la tabla 'film'.
-- Su función es actualizar el título y la descripción en la tabla 'film_text' 
-- para que coincidan con los cambios realizados en la tabla principal.
-- Código conceptual interno:
-- UPDATE film_text 
-- SET title = NEW.title, description = NEW.description 
-- WHERE film_id = NEW.film_id;

-- 3. Trigger de ELIMINACIÓN (del_film)
-- Se dispara DESPUÉS de borrar una película de la tabla 'film'.
-- Su función es eliminar el registro correspondiente de la tabla 'film_text' 
-- para evitar datos huérfanos o inconsistencias de almacenamiento.
-- Código conceptual interno:
-- DELETE FROM film_text WHERE film_id = OLD.film_id;
