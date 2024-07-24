--1. Cоздайте функцию на языке PL/pgSQL (см. слайд 10), в которой переменная с одним и тем же именем
--объявляется и используется (выводится, ей присваиваются значения) на трех уровнях вложенности,
--задокументируйте результаты.

CREATE OR REPLACE FUNCTION somefunc() RETURNS integer AS $$
<< outerblock >>
DECLARE
	quantity integer := 30;
BEGIN
	RAISE NOTICE 'Сейчас quantity = %', quantity; -- Выводится 30
	quantity := 50;
	-- Вложенный блок
	DECLARE
		quantity integer := 80;
	BEGIN
		RAISE NOTICE 'Сейчас quantity = %', quantity; -- Выводится 80
		RAISE NOTICE 'Во внешнем блоке quantity = %', outerblock.quantity; -- Выводится 50
		-- Третий уровень вложенности
		DECLARE 
			quantity integer := 60;
		BEGIN
			RAISE NOTICE 'Сейчас quantity = %', quantity;
			RAISE NOTICE 'Во внешнем блоке quantity = %', outerblock.quantity;
			RETURN quantity;
		END;
	END;
	RAISE NOTICE 'Сейчас quantity = %', quantity; -- Выводится 50
	--RETURN quantity;
END;
$$ LANGUAGE plpgsql;

SELECT somefunc();


-- 2. Создайте функции со слайдов 23-24 и вызовите их несколько раз, передавая данных разных типов.
-- Задокументируйте результаты.

CREATE FUNCTION add_three_values(v1 anyelement, 
								 v2 anyelement, 
								 v3 anyelement)
RETURNS anyelement AS $$
DECLARE
	result ALIAS FOR $0;
BEGIN
	result := v1 + v2 + v3;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT add_three_values(1, 1, 2); -- Выводит 4
SELECT add_three_values(1.5, 1.5, 2.005); -- Выводит 5.005


CREATE FUNCTION add_three_values_2(v1 anyelement, 
								 v2 anyelement, 
								 v3 anyelement,
								 OUT sum anyelement)
AS $$
BEGIN
	sum := v1 + v2 + v3;
END;
$$ LANGUAGE plpgsql;

SELECT add_three_values_2(1, 1, 2); -- Выводит 4
SELECT add_three_values_2(1.5, 1.5, 2.005); -- Выводит 5.005


/* 3. Придумайте и напишите 4 динамически формируемых команды на языке PL/pgSQL, в которые передаются
параметры и используются запросы: select, update, delete к таблицам из БД «Авиарейсы» (предварительно
создайте копии таблиц, на которых проводятся эксперименты). В одной из команд задайте имя таблицы
динамически. +
?Используя формат, функция выдавала ошибку null не может быть SQL-идентификаторм?*/

--CREATE TABLE flights_copy AS SELECT * FROM flights;

CREATE OR REPLACE FUNCTION update_table(arr_airp char,
									   no_flight char)
RETURNS VOID AS $$
BEGIN
	EXECUTE 'UPDATE flights_copy SET arrival_airport = $1 WHERE flight_no = $2' USING arr_airp, no_flight;
END;
$$ LANGUAGE plpgsql;
								
SELECT * FROM update_table('KZN', 'PG0052');
								
								
CREATE OR REPLACE FUNCTION select_from_table(flight_id_new int) 
RETURNS TABLE (flight_id int, amount_tickets bigint) AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT flight_id, count(ticket_no) FROM ticket_flights_copy WHERE flight_id = $1 GROUP BY flight_id' 
	USING flight_id_new;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM select_from_table(10895);
			  
	
CREATE OR REPLACE FUNCTION DELETE_from_table(ticket_no_new character) 
RETURNS VOID AS $$
BEGIN
	EXECUTE 'DELETE FROM ticket_flights_copy WHERE ticket_no = $1' 
	USING ticket_no_new;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM DELETE_from_table('00012345');
SELECT * FROM ticket_flights_copy WHERE ticket_no = '00012345';


CREATE OR REPLACE FUNCTION select_from_table2(aircraft_code_new char, fare_conditions_new character varying) 
RETURNS TABLE (aircraft_code char, fare_conditions character varying, amount_tickets bigint) AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT aircraft_code, fare_conditions, count(seat_no) FROM seats WHERE aircraft_code = $1 and fare_conditions = $2 GROUP BY aircraft_code, fare_conditions' 
	USING aircraft_code_new, fare_conditions_new;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM select_from_table2('319', 'Economy');


-- 4. Напишите на языке PL/pgSQL функцию, заменяющую все пары, тройки и т.д. одинаковых, подряд идущих
--символов заданной строки на один символ. Пример: исходная строка: ‘fffqqweerrtwtttttvvdddddd’;
--результат: ‘fqwertwtvd’.Используйте операторы циклов: for, while и loop – напишите 3 соответствующих
--функции. Каждая функция должны выводить результат и возвращать его. В случае, если в функцию
--передана пустая строка, должно генерироваться исключение. +

CREATE OR REPLACE FUNCTION remove_similar(string character varying) RETURNS text 
AS $$
DECLARE res_string text := '';
		previous_chr char;
BEGIN
	IF string = '' THEN 
		RAISE EXCEPTION 'Строка пустая';
	END IF;
	FOR i IN 1..LENGTH(string) LOOP
		IF i = 1 OR SUBSTRING(string, i, 1) != previous_chr THEN 
			res_string = res_string || SUBSTRING(string, i, 1);
			previous_chr = SUBSTRING(string, i, 1);
		END IF;
	END LOOP;
RETURN res_string;
END;
$$ LANGUAGE plpgsql;

SELECT remove_similar('fffqqweerrtwtttttvvdddddd');

CREATE OR REPLACE FUNCTION remove_similar2(string character varying) RETURNS text 
AS $$
DECLARE res_string text := '';
		previous_chr char;
		i int := 1;
BEGIN
	IF string = '' THEN 
		RAISE EXCEPTION 'Строка пустая';
	END IF;
	WHILE i < length(string) LOOP
		IF i = 1 OR SUBSTRING(string, i, 1) != previous_chr THEN 
			res_string = res_string || SUBSTRING(string, i, 1);
			previous_chr = SUBSTRING(string, i, 1);
		END IF;
		i = I + 1;
	END LOOP;
RETURN res_string;
END;
$$ LANGUAGE plpgsql;


SELECT remove_similar2('fffqqweerrtwtttttvvdddddd');


CREATE OR REPLACE FUNCTION remove_similar3(string character varying) RETURNS text 
AS $$
DECLARE res_string text := '';
		previous_chr char;
		i int := 1;
BEGIN
	IF string = '' THEN 
		RAISE EXCEPTION 'Строка пустая';
	END IF;
	LOOP
		IF i = 1 OR SUBSTRING(string, i, 1) != previous_chr THEN 
			res_string = res_string || SUBSTRING(string, i, 1);
			previous_chr = SUBSTRING(string, i, 1);
		END IF;
		i = I + 1;
		EXIT WHEN i = length(string);
	END LOOP;
RETURN res_string;
END;
$$ LANGUAGE plpgsql;


SELECT remove_similar3('fffqqweerrtwtttttvvdddddd');

/* 5. Создайте несколько (2-3) материализованных представлений на основе произвольных запросов к таблицам
БД «Авиаперевозки». Затем внесите изменения в таблицы, участвующие в запросах. Выполните код со
слайда 88, убедитесь в том, что обновление данных произошло. Задокументируйте результаты.*/

CREATE MATERIALIZED VIEW tf_view AS (SELECT * FROM ticket_flights_copy);
CREATE MATERIALIZED VIEW data_aircrafts AS (SELECT * FROM aircrafts_copy);

CREATE FUNCTION refresh_views() RETURNS integer AS $$
DECLARE
	views RECORD;
BEGIN
	RAISE NOTICE 'Refreshing all materialized views…';
	
	FOR views IN
		SELECT n.nspname AS mv_schema,
			   c.relname AS mv_name,
			   pg_catalog.pg_get_userbyid(c.relowner) AS owner
		FROM pg_catalog.pg_class c
	LEFT JOIN pg_catalog.pg_namespace n ON (n.oid = c.relnamespace)
		 WHERE c.relkind = 'm'
	ORDER BY 1
	LOOP
	
		-- Здесь "mviews" содержит одну запись с информацией о матпредставлении

		RAISE NOTICE 'Refreshing materialized view %.% (owner: %)…',
				quote_ident(views.mv_schema),
				quote_ident(views.mv_name),
				quote_ident(views.owner);
		EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', views.mv_schema, views.mv_name);
	END LOOP;
	
	RAISE NOTICE 'Done refreshing materialized views.';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


SELECT refresh_views(); -- Выводит 1. 

UPDATE aircrafts_copy SET range = 7000 WHERE aircraft_code = '319';
DELETE FROM aircrafts_copy WHERE aircraft_code = '123';

DELETE FROM ticket_flights_copy WHERE flight_id = 8097;
-- После изменения основных таблиц представления не изменились. Вызовем функцию
SELECT refresh_views();
--Теперь внесенные в таблицу изменения отобразились и в представлениях


/* 6. Реализуйте задания 1-6 из практического занятия «Функции и процедуры. Часть 2.» на языке PL/pgSQL. */
-- 6.1 Создайте копию таблицы ticket_flights. Создайте и выполните функцию с базовым
--типом, которая изменяет все значения amount на значение переданного в функцию
--параметра. ++

CREATE OR REPLACE FUNCTION  set_amount(new_amount numeric) RETURNS numeric AS $$
BEGIN
	UPDATE ticket_flights_copy tSET amount = new_amount;
	RETURN new_amount;
END;
$$ LANGUAGE plpgsql;

SELECT set_amount(62000.12);


--2. Создайте и выполните функцию с составным типом аргументов, в которую
--передается переменная составного типа, представляющая строку таблицы bookings, а
--возвращается уменьшенное на 30% значение total_amount. +

CREATE OR REPLACE FUNCTION dicrease_amount(bookings) RETURNS numeric AS $$
BEGIN
	RETURN $1.total_amount * 0.7 AS dicreased_am;
END;
$$ LANGUAGE plpgsql;

SELECT book_ref, dicrease_amount(bookings) as amount FROM bookings
	WHERE book_ref = '00000F';

--3. Создайте и выполните функцию с выходными параметрами, в которую передается
--номер билета и которая возвращает идентификатор пассажира, имя+фамилию
--пассажира и контактные данные пассажира в виде трех выходных параметров.

CREATE OR REPLACE FUNCTION pas(ticket_no character)
RETURNS TABLE (passenger_id character varying, passenger_name text, contact_data jsonb)
AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT passenger_id, passenger_name, contact_data FROM tickets';
END;
LANGUAGE plpgsql;

SELECT * FROM pas('0005432000988');

--4. Создайте и выполните функцию c переменным числом аргументов (VARIADIC),
--которая возвращает сумму переданных аргументов.

CREATE OR REPLACE FUNCTION sum_int(VARIADIC arr numeric[]) RETURNS numeric AS $$
BEGIN
	RETURN sum($1[i]) FROM generate_subscripts($1, 1) g(i);
END;
$$ LANGUAGE plpgsql;

SELECT sum_int(10, -1, 5, -5);

--5. Создайте функцию, порождающую таблицу из тех строк таблицы seats, в которых
--fare_conditions = ‘Comfort’.

CREATE OR REPLACE FUNCTION get_seat(fare_condition character varying)
RETURNS TABLE(aircraft_code character, 
			  seat_no character, 
			  fare_conditions character varying) AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT aircraft_code, seat_no, fare_conditions FROM seats WHERE fare_conditions = $1' USING fare_condition;
END;
$$ LANGUAGE plpgsql;

SELECT get_seat('Comfort');

--6. Создайте функцию, возвращающую множество тех строк таблицы seats, в которых
--fare_conditions = ‘Business’. Реализуйте два варианта: с setof <имя_таблицы> и с
--колонками, определяемыми выходными параметрами (setof record).

CREATE OR REPLACE FUNCTION get_seat2(fare_condition character varying)
RETURNS SETOF seats AS $$
BEGIN
	RETURN QUERY EXECUTE 'SELECT * FROM seats WHERE fare_conditions = $1' USING fare_condition;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_seat2('Business');


/* 7. Создайте курсор с параметром, связанный с запросом, который соединяет flights и airports
(эта таблица джойнится дважды) по кодам аэропорта отправления и прибытия. Используя соответствующую
курсорную переменную, пройдите в цикле по строкам результата соединения и выведите все строки, в
которых дата отправления равна заданной дате (заданная дата - параметр курсора). */

CREATE OR REPLACE FUNCTION get_flights_by_date(depr_date DATE)
RETURNS character varying AS $$
DECLARE
  flight_cursor CURSOR (depr_date DATE) FOR
      SELECT f.*
      FROM flights f
      JOIN airports ar1 ON f.departure_airport = ar1.airport_code
      JOIN airports ar2 ON f.arrival_airport = ar2.airport_code
      WHERE DATE(f.scheduled_departure) = depr_date;
	  
  flight_row flights%ROWTYPE;
BEGIN
  OPEN flight_cursor(depr_date);
  LOOP 
    FETCH flight_cursor INTO flight_row;
    EXIT WHEN NOT FOUND;
    
    -- Выводим информацию о рейсе, если дата отправления равна заданной дате
    RAISE NOTICE 'Flight_id: %, Departure_date: %', flight_row.flight_id, flight_row.scheduled_departure;
  END LOOP;
  
  CLOSE flight_cursor;
END;
$$ LANGUAGE plpgsql;

SELECT get_flights_by_date('2017-08-16');