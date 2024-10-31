--2. Создайте копии таблицы aircrafts: aircrafts_tmp и aircraft_log. Создайте триггер,
--который копирует в aircraft_log информацию о каждом новом самолете,
--добавляемом в aircrafts_tmp. Проверьте работу триггера, сохраните скриншоты
--результатов.+

--CREATE TABLE aircrafts_tmp (LIKE aircrafts);
--CREATE TABLE aircrafts_log (LIKE aircrafts);

CREATE OR REPLACE FUNCTION trg_add_value() RETURNS trigger 
AS $$
BEGIN
		INSERT INTO aircrafts_log (aircraft_code, model, range)
		VALUES (NEW.aircraft_code, NEW.model, NEW.range);
		RETURN NEW;
		
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_value
AFTER INSERT OR UPDATE ON aircrafts_tmp
FOR EACH ROW EXECUTE FUNCTION trg_add_value();

INSERT INTO aircrafts_tmp(aircraft_code, model, range)
VALUES('567','Боинг 567-600','1000');

SELECT * FROM aircrafts_log;

--3. Создайте копии таблиц flights, aircrafts, seats. Напишите триггер, который
--выполняется перед удалением записи из таблицы aircrafts. Триггер проверяет
--наличие в таблицах flights и seats записей, относящихся к удаляемому самолету, и,
--если такие записи есть, удаляет их. Проверьте работоспособность триггера,
--сохраните результаты. +

--CREATE TABLE flights_copy (LIKE flights);
--CREATE TABLE seats_copy (LIKE seats);

CREATE OR REPLACE FUNCTION trg_delete_aircr() RETURNS trigger
AS $$
BEGIN
		DELETE FROM flights_copy WHERE aircraft_code = OLD.aircraft_code;
		DELETE FROM seats_copy WHERE aircraft_code = OLD.aorcraft_code;
		RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_aircraft_delete
BEFORE DELETE ON aircrafts_tmp
FOR EACH ROW EXECUTE FUNCTION trg_delete_aircr();

DELETE FROM aircrafts_tmp WHERE aircraft_code = '773';

SELECT * FROM aircrafts_tmp WHERE aircraft_code = '773';
SELECT * FROM flights_copy WHERE aircraft_code = '773';
SELECT * FROM seats_copy  WHERE aircraft_code = '773';


--4. Требуется обновлять общую сумму бронирования (total_amount в таблице bookings)
--при изменении данных о бронировании: изменении количества билетов,
--относящихся к бронированию, или стоимости билета (amount в ticket_flights) в
--бронировании. По аналогии с решением задачи 2 со слайда 87, создайте
--необходимые триггеры для автоматического обновления суммы бронирования при
--упомянутых изменениях. Проверьте работу триггеров, сохраните скриншоты
--результатов.

CREATE TABLE bookings_copy AS SELECT * FROM bookings;


CREATE OR REPLACE FUNCTION trg_update_booking_amount()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE bookings
    SET total_amount = (SELECT SUM(amount * ticket_no)
                        FROM ticket_flights_tmp
                        WHERE ticket_no = NEW.ticket_no)
    WHERE ticket_no = NEW.ticket_no;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- 2 present
CREATE OR REPLACE TRIGGER trig_update_booking_amount
AFTER UPDATE OF ticket_no ON ticket_flights_copy
FOR EACH ROW
EXECUTE FUNCTION trg_update_booking_amount();

INSERT INTO ticket_flights_copy(ticket_no, flight_id, fare_conditions, amount)
VALUES('00012345','30650','Business',42300.00);

UPDATE ticket_flights_copy SET amount = 42300 WHERE  ticket_no = '0005433102310';

DELETE FROM ticket_flights_copy WHERE ticket_no = '0005435212357';

SELECT * FROM ticket_flights_copy 
SELECT * FROM bookings_copy


CREATE OR REPLACE FUNCTION trg_update_booking_amount1()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE bookings
    SET total_amount = (SELECT SUM(amount * ticket_no)
                        FROM ticket_flights_tmp
                        WHERE ticket_no = NEW.ticket_no)
    WHERE ticket_no = NEW.ticket_no;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trig_update_booking_amount1
AFTER UPDATE OF amount ON ticket_flights_copy
FOR EACH ROW
EXECUTE FUNCTION trg_update_booking_amount1();

INSERT INTO ticket_flights_copy(ticket_no, flight_id, fare_conditions, amount)
VALUES('00012345','30650','Business','42300.00');

DELETE FROM ticket_flights_copy WHERE amount = '42100.00';

SELECT * FROM ticket_flights_copy 
SELECT * FROM bookings
