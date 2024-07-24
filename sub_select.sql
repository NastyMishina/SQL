--1. Напишите запрос на основе использования подзапросов, который выявляет направления, на которые не было продано ни
--одного билета.

SELECT DISTINCT flight_id, flight_no FROM flights
	WHERE flight_id NOT IN (SELECT DISTINCT flight_id FROM ticket_flights);


--2. Напишите запрос на основе использования подзапросов, который подсчитывает количество операций бронирования, в
--которых общая сумма превышает треть максимальной величины по всей выборке (подсказка: см. слайд 5).

SELECT count( * ) FROM bookings
	WHERE total_amount > (SELECT max(total_amount) FROM bookings)/3;
	

-- 3. Напишите запрос на основе использования подзапросов, который выводит для каждой модели самолета количество мест
--класса business, количество мест класса comfort и количество мест класса economy.

SELECT * FROM (SELECT aircraft_code, fare_conditions, COUNT(seat_no) FROM seats GROUP BY aircraft_code, fare_conditions) 
	ORDER BY aircraft_code;
	
	
--4. Напишите запрос на основе использования подзапросов, который позволяет получить перечень аэропортов в тех городах
--(город, код аэропорта, название аэропорта), в которых больше двух аэропортов.

SELECT city, airport_name, airport_code
FROM airports
WHERE city IN (SELECT city
         FROM airports
         GROUP BY city
         HAVING COUNT(*) > 2);
	
	 
--5.Придумайте и напишите по одному запросу для каждого выражения подзапроса (EXISTS, IN и т.д. – см. слайд 10) к базе
--данных об авиаперевозках. Запросы у разных студентов не должны повторяться.
	 
SELECT aircraft_code, model FROM aircrafts_data as a
	 WHERE EXISTS (SELECT * FROM flights 
				   	WHERE status ILIKE 'On Time' AND a.aircraft_code = aircraft_code);
	 -- Выбор тех моделей самолетов, которые прибыли вовремя

SELECT ticket_no, passenger_id, passenger_name, contact_data FROM tickets
	 WHERE ticket_no IN (SELECT ticket_no FROM ticket_flights 
						 	WHERE flight_id = 28913 AND fare_conditions ilike 'Business');
	 -- Выбор всех пассажиров, которые летели 28913 рейсом в бизнес классе 
	
	 
SELECT ticket_no, passenger_id, passenger_name, contact_data FROM tickets
	 WHERE ticket_no NOT IN (SELECT ticket_no FROM ticket_flights 
							 	WHERE flight_id = 28913 AND fare_conditions ilike 'Business');
	 -- Выбор всех пассажиров, которые летели 28913 рейсом не в бизнес классе
	
	 
SELECT * FROM aircrafts_data
	 WHERE aircraft_code ilike ANY(SELECT aircraft_code FROM flights 
								  	WHERE arrival_airport ilike 'VKO');
	 -- Выбор модели самолетов, которые прибывали в аэропорт внуково
	 
	 
SELECT * FROM aircrafts_data
	 WHERE aircraft_code ilike ALL(SELECT aircraft_code FROM flights 
								  	WHERE arrival_airport ilike 'KRR');	
	 -- Возвращает модели самолетов, если все из них прибывали в аэропорт краснодара
	 
	 
-- 6. Используя теоретико-множественную операцию, выведите все рейсы, которые были совершены 26 августа, за исключением
--тех рейсов, в которых аэропортом прибытия является Внуково. В результате должны быть названия аэропортов отправления и
--прибытия airport_name, а также flight_id, flight_no, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival,
--status из таблицы flights.

SELECT flight_id, flight_no, 
		scheduled_departure, scheduled_arrival, 
		actual_departure, actual_arrival, 
		status, 
		(SELECT airport_name FROM airports_data WHERE flights.departure_airport IN 
		 		(SELECT airports_data.airport_code)) as airport_dep_name, 
		(SELECT airport_name FROM airports_data WHERE flights.arrival_airport IN 
		 		(SELECT airports_data.airport_code)) as airport_arr_name 
  	 FROM flights WHERE date(scheduled_departure) = '2017-08-26'
EXCEPT
SELECT flight_id, flight_no, 
		scheduled_departure, scheduled_arrival, 
		actual_departure, actual_arrival, 
		status,
		(SELECT airport_name FROM airports_data WHERE flights.departure_airport IN 
		 	(SELECT airports_data.airport_code)) as airport_dep_name, 
		(SELECT airport_name FROM airports_data WHERE flights.arrival_airport IN 
		 (SELECT airports_data.airport_code)) as airport_arr_name 
   FROM flights WHERE arrival_airport ILIKE 'VKO';
	 
	 
	 
-- 7. Используя теоретико-множественную операцию, выведите количества всех рейсов, которые были совершены 26 августа, для
--каждой модели самолета, а также количества всех рейсов, которые были совершены 28 августа. В результате должны быть
--названия моделей самолетов и соответствующие количества рейсов.
	 
select model, count(*) as amount_flights from flights f
	 join aircrafts_data cr on f.aircraft_code = cr.aircraft_code
	 where extract(day from actual_departure) = 26 or extract(month from actual_departure) = 8
	 group by model
union
select model, count(*) as amount_flights from flights f
	 join aircrafts_data cr on f.aircraft_code = cr.aircraft_code
	 where extract(day from actual_departure) = 28 or extract(month from actual_departure) = 8
	 group by model;
	 
	 
	 
-- 8. Напишите запросы на основе использования теоретико-множественных операций, который выдает список городов: а) в
--которые можно улететь из Москвы, Санкт-Петербурга и Казани; б)в которые можно улететь из Москвы и Санкт-Петербурга, но
--нельзя улететь из Казани; в) в которые можно улететь из Москвы, а также выводит города, в которые нельзя улететь из
--Санкт-Петербурга.
	 
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE ANY(SELECT airport_code FROM airports_data WHERE airport_code ILIKE 'SVO' 
									  OR airport_code ILIKE 'VKO' 
									  OR airport_code ILIKE 'DME')
INTERSECT
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE 'LED'
INTERSECT 
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE 'KZN'
	ORDER BY city;
	 
	 
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE ANY(SELECT airport_code FROM airports_data WHERE airport_code ILIKE 'SVO' 
									  OR airport_code ILIKE 'VKO' 
									  OR airport_code ILIKE 'DME')
INTERSECT
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE 'LED'
EXCEPT
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE 'KZN'
	ORDER BY city;
	 
	 
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE ANY(SELECT airport_code FROM airports_data WHERE airport_code ILIKE 'SVO' 
									  OR airport_code ILIKE 'VKO' 
									  OR airport_code ILIKE 'DME')
EXCEPT
SELECT city FROM flights f
	JOIN airports_data port ON f.arrival_airport = port.airport_code
	WHERE departure_airport ILIKE 'LED';
	 
	 
	 
-- 9. Придумайте и напишите по одному (своему) запросу для каждой теоретико-множественной операции, а также для трех
--разных комбинаций этих операций к базе данных об авиаперевозках. Запросы у разных студентов не должны повторяться.
	 
SELECT ticket_no, book_ref, passenger_name FROM tickets
	 WHERE passenger_name ILIKE '%AK%'
UNION
SELECT ticket_no, book_ref, passenger_name FROM tickets 
	 WHERE passenger_name ILIKE '%AN%';
	 -- Выводит номер билета, бронирования и имя пассажира, в ФИ которых есть сочетание символов AK или AN 
	 
SELECT flight_no, arrival_airport FROM flights
	 WHERE departure_airport ILIKE 'LED'
EXCEPT
SELECT flight_no, arrival_airport FROM flights
	 WHERE arrival_airport ILIKE 'KZN';
	 -- Выводит номер полета и аэропорт пребытия, где вылет совершается из аэропорта Санкт-Петербурга, но не приземляется в Казани.
	 
--доп. 
SELECT t.a, t.b FROM t
	WHERE t.c = (SELECT q.q_id FROM q
			WHERE q.q_name = ‘test’ OFFSET 2 LIMIT 1)
	 
	 
SELECT t1.title_id, t1.title
FROM titles t1
WHERE EXISTS
		(SELECT *
		FROM titles t2 INNER JOIN sales s ON
		t2.title_id = s.title_id
		WHERE t2.title_id = t1.title_id)
	 
	
	 