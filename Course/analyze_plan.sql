-- 1. Проверьте, выполняется ли параллельно запрос, вычисляющий суммарную стоимость билетов, каждый из которых
--дороже 7000. Поясните элементы плана запроса.

EXPLAIN SELECT count(amount) FROM ticket_flights WHERE amount >= 7000;

/* 2. Проверьте, как выполняется (параллельно или последовательно, почему) запрос из п. 1, если чтение из таблицы перелетов 
оформлено как общее табличное выражение (CTE). Используйте указание MATERIALIZED (WITH CTE name AS MATERIALIZED (SELECT ...),
чтобы планировщик не раскрывал общее табличное выражение. Поясните элементы плана запроса.*/

EXPLAIN WITH amount_tc AS MATERIALIZED (SELECT * FROM ticket_flights)
SELECT count(amount) FROM amount_tc WHERE amount >= 7000;

/*3.Напишите двумя способами (с помощью агрегатной функции, с помощью сортировки и LIMIT) запрос, выбирающий
максимальную цену билета. Проверьте план выполнения. Какой метод доступа выбрал Планировщик? Эффективен ли
такой доступ? Создайте индекс по столбцу ticket_flights.amount. Снова проверьте план выполнения запроса. Какой
метод доступа выбрал планировщик теперь? Объясните план запроса.*/

EXPLAIN SELECT max(amount) FROM ticket_flights;

EXPLAIN SELECT amount FROM ticket_flights ORDER BY amount DESC LIMIT 1;

CREATE INDEX ON ticket_flights(amount);
EXPLAIN SELECT max(amount) FROM ticket_flights;


/*4. Создайте include-индекс для таблицы flights (по полю flight_id с любым неключевым столбцом). Проанализируйте
план запроса, использующего данные из ключевого столбца и выбранного неключевого, объясните его. Замените
созданным индексом индекс, поддерживающий первичный ключ таблицы, не забудьте сохранить целостность данных.*/

CREATE INDEX idx_flights_flight_id ON flights(flight_id) INCLUDE (departure_airport, arrival_airport);
EXPLAIN ANALYZE  SELECT flight_id, departure_airport FROM flights WHERE flight_id = 1;


/*5. Напишите запрос, находящий информацию о перелетах стоимостью более 200 000 руб. Какой метод доступа был выбран? 
Сколько времени выполняется запрос? Запретите выбранный метод доступа, снова выполните запрос и сравните время выполнения. 
Для запрета метода доступа установите один из параметров в значение off: - enable_seqscan, - enable_indexscan, - enable_bitmapscan.
Например: SET enable_seqscan = off; Прав ли был оптимизатор?*/

EXPLAIN ANALYZE SELECT * FROM ticket_flights WHERE amount > 200000;

-- Запрет последовательного сканирования
SET enable_bitmapscan = off;

-- Выполнение запроса с запретом последовательного сканирования
EXPLAIN ANALYZE SELECT * FROM ticket_flights WHERE amount > 200000;


-- 6.3

EXPLAIN ANALYZE SELECT count(*) FROM ticket_flights WHERE fare_conditions = 'Economy'; 

EXPLAIN ANALYZE SELECT count(*) FROM ticket_flights WHERE fare_conditions = 'Comfort';

EXPLAIN ANALYZE SELECT count(*) FROM ticket_flights WHERE fare_conditions = 'Business';

CREATE INDEX ind_fare_cond ON ticket_flights(fare_conditions);



/*23-24 Практическая */

CREATE INDEX idx_flights_arr_airport ON flights(arrival_airport);
SELECT * FROM flights f JOIN airports a ON f.arrival_airports = a.airport_code
WHERE a.city = 'Москва';
