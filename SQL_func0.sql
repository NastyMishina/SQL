-- 2. Напишите функцию, которая по номеру билета выдает строку, содержащую
--passenger_name и contact_data в формате: “Vladimir Frolov, contact_data: phone:
--...”. Т.е. нужно фамилию и имя из passenger_name из верхнего регистра
--преобразовать в формат, где первая буква – в верхнем регистре, остальные – в
--нижнем, а затем сцепить (конкатенировать) результат со словом « contact_data:» и
--контактными данными.

CREATE FUNCTION find_passenger(t_no character)
RETURNS character varying
LANGUAGE sql
RETURN (SELECT 
			INITCAP(tickets.passenger_name) || ', ' || 'contact_data: ' || contact_data
			FROM tickets
				WHERE ticket_no = t_no);
				
SELECT bookings.find_pass(
	'0005432000998'
)


--3. Напишите функцию, в которую передается код самолета, и которая возвращает
--строку, содержащую через запятые код данного самолета, его название, дату
--отправления и дату прибытия, номер перелета - для самого длительного перелета.

CREATE OR REPLACE FUNCTION find_aircraft(air_code character)
RETURNS character varying
LANGUAGE sql
RETURN (SELECT 
			a.aircraft_code || ', ' || model || ', ' || scheduled_departure || ', ' || 
		scheduled_arrival || ', ' || flight_no 
			FROM aircrafts a
			JOIN flights f ON a.aircraft_code = f.aircraft_code
				ORDER BY scheduled_arrival - scheduled_departure DESC LIMIT 1);
				

SELECT find_arcrafts('SU9')

--4. Напишите функцию, которая для заданной модели самолета выдает количество 
--мест эконом-класса, бизнес-класса, и комфорт-класса. 

CREATE OR REPLACE FUNCTION count_seats(air_c character)
RETURNS character varying
LANGUAGE sql
RETURN (SELECT string_agg(aircraft_code || ',' || fare_conditions || ',' || seat_count, ';') FROM 
		(SELECT aircraft_code, fare_conditions, COUNT(seat_no) AS seat_count FROM seats
			WHERE aircraft_code = air_c
			GROUP BY aircraft_code, fare_conditions))
			
SELECT count_seats('SU9');


--5. Напишите функцию, возвращающую количество билетов, проданных на заданный рейс.

CREATE OR REPLACE FUNCTION count_flights(fl_id integer)
RETURNS character varying
LANGUAGE sql
RETURN (SELECT 
			'Amount of flights' || ': ' || count(ticket_no)
			FROM ticket_flights 
			WHERE flight_id = fl_id);
			
SELECT count_flights(28935);