-- SQLite
--SELECT MIN(create_date) FROM advertising_companies;

SELECT * FROM users;
SELECT * FROM advertising_companies;
SELECT * FROM payment_date;
 
 /* WITH join_tables AS (
    SELECT * FROM users as u 
        JOIN advertising_companies ac ON u.owner_id = ac.id 
        JOIN payment_date pd ON u.id = pd.user_id 
        )

SELECT * FROM join_tables; */
/*
WITH join_tables2 AS (
    SELECT * FROM  payment_date pd
        JOIN users u ON pd.user_id = u.id
        JOIN advertising_companies ac ON pd.rk_id = ac.id 
        --WHERE (u.owner_id IS NULL OR u.owner_id NOT IN (SELECT ac.id FROM advertising_companies ac)) 
        )
SELECT * FROM join_tables2; 

WITH join_table AS (
    SELECT pd.id, ac.create_date, user_id, rk_id, ac.is_main, SUM(sum), name, owner_id FROM payment_date pd
        LEFT JOIN advertising_companies ac ON pd.rk_id = ac.id
        LEFT JOIN users u ON pd.user_id = u.id
            WHERE sum > 0
        GROUP BY pd.user_id, rk_id
        )

SELECT * FROM join_table;*/ 

-- Выбираем все названия кампаний
WITH company_name AS (
    SELECT id, name as company FROM users u WHERE owner_id IS NULL -- Условие обозачения компаний NULL
                                                OR owner_id NOT IN (SELECT id FROM users) -- значение не существует 
        ),

join_table2 AS (
    SELECT * FROM users u -- Соединение всех таблиц 
        LEFT JOIN payment_date pd ON u.id = pd.user_id
        LEFT JOIN (SELECT id as ac_id, create_date as ac_date, is_main FROM advertising_companies) sub ON pd.rk_id = sub.ac_id -- подпроцес для изменения названий столбцов
        LEFT JOIN company_name cn ON u.owner_id = cn.id
        ),

agrigated_table AS (
    SELECT ac_date, name, company, owner_id, user_id, rk_id, is_main, SUM(sum) as sum FROM join_table2
        WHERE sum > 0 OR owner_id NOT IN (SELECT id FROM users) 
            GROUP BY ac_date, user_id, rk_id
            -- Подсчет суммы платежей в зависимости от даты создания РК, компании и id РК
            ),

min_date AS (
    SELECT name, MIN(ac_date) as min_d FROM agrigated_table GROUP BY name -- Создание множества дать ранних РК
    ),

max_index_rk AS (
                SELECT MAX(rk_id) FROM agrigated_table WHERE ac_date IN (SELECT min_d FROM min_date) GROUP BY ac_date, name
                -- Создание множества id наибольших РК в зависимости от даты 
                )


SELECT * FROM agrigated_table WHERE ((name, ac_date) IN (SELECT name, min_d FROM min_date) AND is_main = 0 AND rk_id IN max_index_rk) 
                                    OR is_main = 1 OR is_main IS NULL;

/*SELECT company, SUM(sum) as budget FROM agrigated_table WHERE (ac_date IN (SELECT min_d FROM min_date) AND is_main = 0 AND rk_id IN max_index_rk) 
                                OR is_main = 1 OR is_main IS NULL
                                GROUP BY company;*/

--SELECT ac_date, name, company, SUM(sum) FROM agrigated_table 
   -- WHERE ac_date IN (

   --SELECT MIN(ac_date), name, company, owner_id, user_id, rk_id, is_main, sum FROM agrigated_table GROUP BY user_id;
