-- Доп
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(50),
    room_number INT,
    day1 FLOAT,
    day2 FLOAT,
    day3 FLOAT,
    day4 FLOAT,
    day5 FLOAT,
    day6 FLOAT,
    day7 FLOAT,
    day8 FLOAT,
    day9 FLOAT,
    day10 FLOAT
);

INSERT INTO Patients (patient_id, full_name, room_number, day1, day2, day3, day4, day5, day6, day7, day8, day9, day10)
VALUES
(1, 'Алексей Иванов', 1, 36.7, 37.0, 37.2, 37.5, 37.3, 37.1, 37.4, 37.2, 37.0, 36.8),
(2, 'Елена Смирнова', 1, 36.9, 36.8, 37.1, 37.4, 37.2, 37.0, 37.3, 37.1, 36.9, 36.7),
(3, 'Иван Петров', 1, 37.0, 36.9, 37.2, 37.5, 37.3, 37.1, 37.4, 37.2, 37.0, 36.8),
(4, 'Ольга Козлова', 2, 36.8, 36.7, 37.0, 37.3, 37.1, 36.9, 37.2, 37.0, 36.8, 36.6),
(5, 'Дмитрий Соколов', 2, 36.9, 36.8, 37.1, 37.4, 37.2, 37.0, 37.3, 37.1, 36.9, 36.7),
(6, 'Мария Ильина', 2, 36.7, 36.6, 36.9, 37.2, 37.0, 36.8, 37.1, 36.9, 36.7, 36.5),
(7, 'Константин Смирнов', 3, 36.8, 36.7, 37.0, 37.3, 37.1, 36.9, 37.2, 37.0, 36.8, 36.6),
(8, 'Анна Новикова', 3, 36.9, 36.8, 37.1, 37.4, 37.2, 37.0, 37.3, 37.1, 36.9, 36.7),
(9, 'Сергей Александров', 3, 36.7, 36.6, 36.9, 37.2, 37.0, 36.8, 37.1, 36.9, 36.7, 36.5),
(10, 'Ирина Васильева', 4, 36.8, 36.7, 37.0, 37.3, 37.1, 36.9, 37.2, 37.0, 36.8, 36.6),
(11, 'Павел Морозов', 4, 36.9, 36.8, 37.1, 37.4, 37.2, 37.0, 37.3, 37.1, 36.9, 36.7),
(12, 'Екатерина Кузнецова', 4, 36.7, 36.6, 36.9, 37.2, 37.0, 36.8, 37.1, 36.9, 36.7, 36.5),
(13, 'Александр Лебедев', 5, 36.8, 36.7, 37.0, 37.3, 37.1, 36.9, 37.2, 37.0, 36.8, 36.6),
(14, 'Наталья Степанова', 5, 36.9, 36.8, 37.1, 37.4, 37.2, 37.0, 37.3, 37.1, 36.9, 36.7),
(15, 'Артем Белов', 5, 36.7, 36.6, 36.9, 37.2, 37.0, 36.8, 37.1, 36.9, 36.7, 36.5),
(16, 'Ольга Макарова', 6, 36.8, 36.7, 37.0, 37.3, 37.1, 36.9, 37.2, 37.0, 36.8, 36.6),
(17, 'Владимир Соловьев', 6, 36.9, 36.8, 37.1, 37.4, 37.2, 37.0, 37.3, 37.1, 36.9, 36.7),
(18, 'Татьяна Попова', 6, 36.7, 36.6, 36.9, 37.2, 37.0, 36.8, 37.1, 36.9, 36.7, 36.5),
(19,'Игорь Королев', 2, 36.8 ,36.7 ,37.0 ,37.3 ,37.1 ,36.9 ,37.2 ,37.0 ,36.8 ,36.6 ),
(20,'Евгения Сидорова', 3, 36.9 ,36.8 ,37.1 ,37.4 ,37.2 ,37.0 ,37.3 ,37.1 ,36.9 ,36.7 );

SELECT room_number, full_name, day1, day2, day3, day4, day5, day6, day7, day8, day9, day10,
avg(day1) OVER (ORDER BY room_number),
avg(day2) OVER (ORDER BY room_number),
avg(day3) OVER (ORDER BY room_number),
avg(day4) OVER (ORDER BY room_number),
avg(day5) OVER (ORDER BY room_number),
avg(day6) OVER (ORDER BY room_number),
avg(day7) OVER (ORDER BY room_number),
avg(day8) OVER (ORDER BY room_number),
avg(day9) OVER (ORDER BY room_number),
avg(day10) OVER (ORDER BY room_number)
FROM Patients;
-----------------------------------

--1. С помощью запроса, использующего концепцию оконных функций, 
--выведите накопленные суммы продаж билетов по дням в каждом месяце. +

WITH find_date AS (SELECT date_trunc('day', scheduled_departure) as flight_date, count(amount) as sum_sold FROM flights f
				   JOIN ticket_flights tf ON f.flight_id = tf.flight_id
					GROUP BY date_trunc('day', scheduled_departure))
SELECT flight_date, sum_sold, sum(sum_sold) OVER (w ORDER BY flight_date) AS accum FROM find_date
													WINDOW w AS (PARTITION BY date_trunc('month', flight_date));
													
													
--2. С помощью запроса, использующего концепцию оконных функций, по каждой модели самолета, выполняющего
--рейсы, выведите ежедневное количество пассажиров.+

SELECT DISTINCT model, date_trunc('day', scheduled_departure) as flight_date, count(ticket_no) 
					OVER (PARTITION BY date_trunc('day', scheduled_departure), model) FROM flights f
					JOIN ticket_flights tf ON f.flight_id = tf.flight_id
					JOIN aircrafts ar ON f.aircraft_code = ar.aircraft_code
					
					
--3. С помощью запроса, использующего концепцию оконных функций, по каждой модели самолета, выполняющего
--рейсы, выведите ежедневное количество рейсов, накопленное количество рейсов, скользящее среднее количества
--рейсов по предыдущему, текущему и следующему дням, относительное количество рейсов, приходящееся на весь
--рассматриваемый период полетов.+

WITH count_flights AS (SELECT DISTINCT model, date_trunc('day', scheduled_departure) as flight_date, count(flight_id) as amount 
				FROM flights f
					JOIN aircrafts ar ON f.aircraft_code = ar.aircraft_code
					 GROUP BY model, date_trunc('day', scheduled_departure))
SELECT model, flight_date, amount, sum(amount) OVER (ORDER BY model, flight_date) AS accum_value,
	round(avg(amount) OVER (ORDER BY model ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 1) AS mov_avg,
	sum(amount) OVER (PARTITION BY model)/ sum(amount) OVER () AS relative_coun
	FROM count_flights;


--4. Модифицируйте запрос с 15 слайда: определите для фрейма в качестве начала (frame_start) запись,
--предшествующую текущей, отстоящую от нее на 3, а в качестве конца (frame_end) – запись, отстоящую от текущей
--вперед на 1.

SELECT b.book_ref, b.book_date,
	extract( 'month' from b.book_date ) AS month,
	extract( 'day' from b.book_date ) AS day,
	count( * ) OVER DESC (PARTITION BY date_trunc( 'month', b.book_date) ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING
	) AS count FROM ticket_flights tf
		JOIN tickets t ON tf.ticket_no = t.ticket_no
		JOIN bookings b ON t.book_ref = b.book_ref
			WHERE tf.flight_id = 1
				ORDER BY b.book_date;


--5. Модифицируйте запрос со слайда 20 таким образом, чтобы он для каждого аэропорта вычислял разницу между его
--вычислять разницу между его географической широтой и широтой, на которой находится самый южный аэропорт в
--этом же часовом поясе.

SELECT airport_name, city, timezone, latitude,
	last_value( latitude ) OVER tz AS first_in_timezone,
	latitude - last_value( latitude ) OVER tz AS delta,
	rank() OVER tz
FROM airports
WHERE timezone IN ( 'Asia/Irkutsk', 'Asia/Krasnoyarsk' )
WINDOW tz AS ( PARTITION BY timezone ORDER BY latitude DESC )
ORDER BY timezone, rank;


--6. С помощью запроса, использующего концепцию оконных функций, вычислите ранги моделей самолетов по числу
--совершенных ими полетов – чем больше полетов, тем выше ранг. +

SELECT model, count(flight_id) as sum_flights, rank() OVER (ORDER BY count(flight_id)) FROM flights f
		JOIN aircrafts ar ON f.aircraft_code = ar.aircraft_code
		GROUP BY model;
				   

--7. Используя ROLLUP, GROUPING SETS, CUBE (напишите одни и те же запросы разными способами) вычислите суммы
--продаж билетов на авиарейсы по моделям самолетов, дням, месяцам и сумму продаж за весь период. ???
SELECT to_char(book_date, 'dd') AS day,
          to_char(book_date, 'mon') AS month,
		  aircraft_code,
		  sum(total_amount) FROM bookings b
		  JOIN tickets t ON b.book_ref = t.book_ref
		  JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
		  JOIN flights f ON tf.flight_id = f.flight_id
	GROUP BY grouping sets((day, month), (aircraft_code), ()); 


SELECT to_char(book_date, 'dd') AS day,
          to_char(book_date, 'mon') AS month,
		  aircraft_code,
		  sum(total_amount) FROM bookings b
		  JOIN tickets t ON b.book_ref = t.book_ref
		  JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
		  JOIN flights f ON tf.flight_id = f.flight_id
	GROUP BY ROLLUP(day, month, aircraft_code)
	Order by day, month, aircraft_code; 
	
	
SELECT to_char(book_date, 'dd') AS day,
          to_char(book_date, 'mon') AS month,
		  aircraft_code,
		  sum(total_amount) FROM bookings b
		  JOIN tickets t ON b.book_ref = t.book_ref
		  JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
		  JOIN flights f ON tf.flight_id = f.flight_id
	GROUP BY CUBE(day, month, aircraft_code); 


--8. Используя ROLLUP, GROUPING SETS, CUBE (напишите одни и те же запросы разными способами) вычислите
--количества полетов по аэропорту отправления, аэропорту прибытия, статусу, дате отправления.
SELECT departure_airport, arrival_airport, status, 
		to_char(scheduled_departure, 'YYYY-MM-DD') as date, 
		count(flight_id) FROM flights
GROUP BY GROUPING SETS (departure_airport, arrival_airport, status, date);

SELECT departure_airport, arrival_airport, status, 
		to_char(scheduled_departure, 'YYYY-MM-DD') as date, 
		count(flight_id) FROM flights
GROUP BY ROLLUP (departure_airport, arrival_airport, status, date);

SELECT departure_airport, arrival_airport, status, 
		to_char(scheduled_departure, 'YYYY-MM-DD') as date, 
		count(flight_id) FROM flights
GROUP BY CUBE (departure_airport, arrival_airport, status, date);

--9. Придумайте запрос для данных из БД авиарейсов, реализующий группировку со слайда 40.

SELECT departure_airport, arrival_airport, status, 
		to_char(scheduled_departure, 'YYYY-MM-DD') as date, 
		aircraft_code,
		count(flight_id) FROM flights
GROUP BY date, CUBE (departure_airport, aircraft_code), GROUPING SETS ((arrival_airport), (status));