-- 1. Напишите запрос на основе CTE, который ищет в базе перелеты, совершенные после 28.07.2017 года, и выводит по ним
--информацию о пассажирах, которые летели бизнес-классом по максимальной цене.

WITH find_flights AS (SELECT * FROM flights fl
					 JOIN ticket_flights tf ON fl.flight_id = tf.flight_id
					 WHERE fare_conditions ILIKE '%Business%' 
					 AND date(scheduled_departure) > '2017-07-28' 
					 AND amount = (SELECT MAX(amount) FROM ticket_flights))
	SELECT tickets.ticket_no, passenger_id, passenger_name, contact_data, ff.fare_conditions, ff.scheduled_departure FROM tickets
	JOIN find_flights ff ON tickets.ticket_no = ff.ticket_no; 
	
	
-- 2. Напишите запрос на основе CTE, который ищет максимальное количество пассажиров, совершивших минимальное
--количество перелетов в августе, в рейсах, совершенных из городов, название которые начинается с буквы «М».

WITH act_flights AS (SELECT * FROM flights fl 
		JOIN airports airp ON fl.departure_airport = airp.airport_code
		JOIN ticket_flights tf ON fl.flight_id = tf.flight_id
		WHERE city ILIKE 'М%' AND EXTRACT(MONTH FROM scheduled_departure) = 8),
passengers AS (SELECT count(tc.ticket_no) as flights_amount, passenger_id, passenger_name FROM act_flights af
		JOIN tickets tc ON af.ticket_no = tc.ticket_no
		GROUP BY passenger_id, passenger_name)
SELECT count(*) as passengers_amount FROM passengers ps 
	WHERE ps.flights_amount = (SELECT MIN(flights_amount) FROM passengers);

-- 3. Создайте копию таблицы flights – flights_copy. Напишите запрос, используя изменение данных в WITH, который перемещает из
--flights_copy в таблицу flights_log все рейсы из аэропортов городов Воронеж, Москва и Самара, совершенные c 29.07.2017 по
--12.08.2017. При этом таблица flights_log должна содержать только следующие столбцы: flight_id, airports.airport_code,
--airports.city, scheduled_departure, scheduled_arrival.

--CREATE TABLE flights_copy (LIKE flights);
--INSERT INTO flights_copy SELECT * FROM flights;

CREATE TABLE flights_copy AS SELECT * FROM flights;
CREATE TABLE flights_log (flight_id integer, 
						  airport_code character(3),
						  city text,
						  scheduled_departure timestamp with time zone,
						  scheduled_arrival timestamp with time zone);

WITH moved_rows AS (
	SELECT flight_id, airport_code, city, scheduled_departure, scheduled_arrival 
	FROM flights_copy fc
	JOIN airports airp ON fc.departure_airport = airp.airport_code
		WHERE date(scheduled_departure) BETWEEN '2017-07-29' and '2017-08-12'
			AND city IN ('Москва', 'Воронеж', 'Самара')
					)
			INSERT INTO flights_log
SELECT * FROM moved_rows;


-- 4. Реализуйте рекурсивный запрос для вычисления значения выражения: Сумма шести слагаемых n*(n + 1) при начальном n0 = 1.

WITH RECURSIVE fraction(n, result) AS (
    SELECT 1, 1 * (1 + 1)
    UNION ALL
    SELECT  n + 1 , n * (n + 1)
    FROM Fraction
    WHERE n < 6)
SELECT * FROM fraction;


-- 5. Создайте таблицу, в которой будут храниться комментарии чата, имеющие иерархическую структуру: каждый комментарий
--может иметь до пяти потомков. Заполните таблицу выдуманными данными, в таблице должно быть не менее двух
--комментариев с пятью потомками, не менее 3 комментариев с четырьмя потомками, не менее 5 комментариев с двумя
--потомками, комментарии с одним потомком, комментарии без потомков (следует хранить не только id комментариев, но и
--сами комментарии). Выполните с помощью рекурсивных запросов обходы дерева комментариев в глубину и ширину,
--сделайте скриншоты запросов и результатов.

CREATE TABLE commen (id_com integer primary key,
					 content_com text,
					 link_com integer REFERENCES commen);
					 

INSERT INTO commen VALUES (1, 'Хорошее качество', NULL),
						   (2, 'Полность согласен', 1),
						   (3, 'Мне товар не понравился', 1),
						   (4, 'Да, ткань приятная', 2),
						   (5, 'Спасибо Вам за отзыв', 4),
						   (6, 'Опишите Вашу проблему', 3),
							(7, 'Автор прав, качество прекрасное!', 1),
							(8, 'Прексрасный набор для рисованя', NULL),
						   (9, 'Краски прослужат долго', 8),
						   (10, 'Спасибо Вам за отзыв на наш товар', 8),
						   (11, 'Очень насыщенные цвета', 9),
						   (12, 'Хорошие витамины', NULL),
						   (13, 'За месяц использования виден результат', 12),
						   (14, 'Ужасный запах клея!', NULL);
						   
						   
WITH RECURSIVE comment_tree(id_com, link_com, path, level) AS (
    SELECT id_com, link_com, ARRAY[content_com], 1
    FROM commen 
    WHERE link_com IS NULL
    UNION ALL
    SELECT c.id_com, c.link_com, path || c.content_com,  ct.level + 1
    FROM commen c
    JOIN comment_tree ct ON c.link_com = ct.id_com)
SELECT id_com, link_com, path, level FROM comment_tree;


WITH RECURSIVE comment_tree(id_com, link_com, path) AS (
    SELECT id_com, link_com, ARRAY[content_com]
    FROM commen 
    WHERE link_com IS NULL
    UNION ALL
    SELECT c.id_com, c.link_com, path || c.content_com
    FROM commen c
    JOIN comment_tree ct ON c.link_com = ct.id_com)
SELECT id_com, link_com, path FROM comment_tree; --O


-- 6. Создайте представление на основе запроса: подсчитать количество мест в салонах для всех моделей самолетов с
--учетом класса обслуживания (бизнес-класс и эконом-класс).

CREATE VIEW amount_seats AS 
		SELECT model, fare_conditions, count(seat_no) FROM seats
		JOIN aircrafts ad ON seats.aircraft_code = ad.aircraft_code
		GROUP BY model, fare_conditions;


--7. Создайте материализованное представление, включающее информацию о перелетах и пассажирах за 2017 год

CREATE MATERIALIZED VIEW flights_2017 AS
		SELECT f.flight_id, f.flight_no,
			scheduled_departure, scheduled_arrival,
			departure_airport, arrival_airport,
			status, aircraft_code,
			actual_departure, actual_arrival,
			passenger_id, passenger_name, contact_data FROM flights f
		JOIN (SELECT * FROM ticket_flights tf JOIN tickets ON tf.ticket_no = tickets.ticket_no) nt 
			ON f.flight_id = nt.flight_id
				WHERE EXTRACT(year FROM scheduled_departure) = 2017;
		 
		 
-- 8.
DROP TABLE airports_data CASCADE;
-- В результате каскадного удаления таблицы с данными об аэропортах, удалились все связанные с ней представления.

--9. 
CREATE VIEW ticket_flights_test AS SELECT * FROM ticket_flights
WITH CHECK OPTION;

UPDATE ticket_flights_test
	SET amount = 7000.00
	WHERE flight_id = 8097 AND fare_conditions = 'Economy';
	
INSERT INTO ticket_flights_test
	VALUES (12345, 9087, 'Business', 278000.00);--невозможно выполнить запрос, тк есть нарушения использования внешнего ключа.
	--Рейса с данным нором и билета не существует

DELETE FROM ticket_flights_test
	WHERE fare_conditions ILIKE '2; -- не удаляет строки из-за внешнего ключа
	
	
	
-- ДОП
--*
CREATE TABLE products (id int, name text, price numeric);
INSERT INTO products VALUES (1, 'Milk', 2),
							(2, 'Bread', 1.2),
							(3, 'Soup', 3),
							(4, 'Apple', 2.3),
							(5, 'Butter', 1.7);
WITH t AS (
 UPDATE products SET price = price * 1.05
 RETURNING *
)
SELECT * FROM products; -- Цены на товары не изменились

WITH t AS (
 UPDATE products SET price = price * 1.05
 RETURNING *
)
SELECT * FROM t; -- Цены на товары в запросе изменились
	
	
--**
CREATE TABLE family (
 person text PRIMARY KEY,
 parent text REFERENCES family
);
INSERT INTO family VALUES ('Alan', NULL),
('Bert', 'Alan'), ('Bob', 'Alan'), ('Carl', 'Bert'), ('Carmen', 'Bert'), ('Bill', 'Carmen'), ('Amanda', 'Carmen'), 
('Cecil', 'Bob'), ('Dave', 'Cecil'), ('Stacy', 'Dave'), ('Mark', 'Dave'), ('Alice', 'Dave'), ('Den', 'Cecil');

WITH RECURSIVE genealogy (bloodline, person, level) AS
(
SELECT person, person, 0 FROM family WHERE parent IS NULL
UNION ALL
SELECT g.bloodline || ' -> ' || f.person, f.person, g.level + 1
FROM family f, genealogy g WHERE f.parent = g.person
)
SELECT bloodline, level FROM genealogy;