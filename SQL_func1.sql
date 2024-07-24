-- 1. Создайте копию таблицы ticket_flights. Создайте и выполните функцию с базовым
--типом, которая изменяет все значения amount на значение переданного в функцию
--параметра. ++

CREATE FUNCTION  set_amount(new_amount numeric) RETURNS numeric AS $$
UPDATE ticket_flights_copy t
	SET amount = new_amount;
	SELECT 1;
$$ LANGUAGE SQL;

SELECT set_amount(62000.12);


--2. Создайте и выполните функцию с составным типом аргументов, в которую
--передается переменная составного типа, представляющая строку таблицы bookings, а
--возвращается уменьшенное на 30% значение total_amount. +

CREATE FUNCTION dicrease_amount(bookings) RETURNS numeric AS $$
SELECT $1.total_amount * 0.7 AS dicreased_am;
$$ LANGUAGE SQL;

SELECT book_ref, dicrease_amount(bookings) as amount FROM bookings
	WHERE book_ref = '00000F';

--3. Создайте и выполните функцию с выходными параметрами, в которую передается
--номер билета и которая возвращает идентификатор пассажира, имя+фамилию
--пассажира и контактные данные пассажира в виде трех выходных параметров.

CREATE FUNCTION pas(IN ticket_no character, 
						OUT passenger_id character varying, 
						OUT passenger_name text,
					   	OUT contact_data jsonb)
AS 'SELECT passenger_id, passenger_name, contact_data FROM tickets'
LANGUAGE SQL;

SELECT * FROM pas('0005432000988');

--4. Создайте и выполните функцию c переменным числом аргументов (VARIADIC),
--которая возвращает сумму переданных аргументов.

CREATE FUNCTION sum_int(VARIADIC arr numeric[]) RETURNS numeric AS $$
SELECT sum($1[i]) FROM generate_subscripts($1, 1) g(i);
$$ LANGUAGE SQL;

SELECT sum_int(10, -1, 5, -5);

--5. Создайте функцию, порождающую таблицу из тех строк таблицы seats, в которых
--fare_conditions = ‘Comfort’.

CREATE FUNCTION get_seat(fare_condition character varying)
RETURNS TABLE(aircraft_code character, 
			  seat_no character, 
			  fare_conditions character varying) AS $$
SELECT aircraft_code, seat_no, fare_conditions FROM seats
WHERE fare_conditions = fare_condition;
$$ LANGUAGE SQL;

SELECT get_seat('Comfort');

--6. Создайте функцию, возвращающую множество тех строк таблицы seats, в которых
--fare_conditions = ‘Business’. Реализуйте два варианта: с setof <имя_таблицы> и с
--колонками, определяемыми выходными параметрами (setof record).

CREATE FUNCTION get_seat2(fare_condition character varying)
RETURNS SETOF seats AS $$
	SELECT * FROM seats
		WHERE fare_conditions = $1;
$$ LANGUAGE SQL;

SELECT * FROM get_seat2('Business');


CREATE FUNCTION get_seat3(IN fare_condition character varying, 
						  OUT aircraft_code character,
						 OUT seat_no character,
						 OUT fare_conditions character varying)
RETURNS SETOF record AS $$
	SELECT aircraft_code, seat_no, fare_conditions FROM seats
		WHERE fare_conditions = $1;
$$ LANGUAGE SQL;

SELECT * FROM get_seat3('Business');
