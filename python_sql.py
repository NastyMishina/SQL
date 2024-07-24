import psycopg2 as psp # Вар 18
#1.


def create_tables():
    cur.execute('''CREATE TABLE services (
                    id INT PRIMARY KEY NOT NUll,
                    name CHARACTER VARYING);
                    ''')
    cur.execute('''CREATE TABLE patients(  
                number int PRIMARY KEY NOT NUll,
                    surname CHARACTER VARYING, 
                    address CHARACTER VARYING,
                    birth_year int);
                    ''')
    cur.execute('''CREATE TABLE rendered_services(  
                patient int  NOT NULL,
                    id int, 
                    visit_time TIME NOT NULL,
                    cost numeric,
                    PRIMARY KEY (patient, visit_time),
                    FOREIGN KEY (patient) REFERENCES patients (number),
                    FOREIGN KEY (id) REFERENCES services (id));
                    ''')
    print(cur.statusmessage)


# 2.
def insert_data(tb_name, columns, data):
    cur.execute(f'''INSERT INTO {tb_name} {columns} VALUES {data};''')
    print(cur.statusmessage)

def insert_many_services(tb_name, data):
    cur.executemany(f'''INSERT INTO {tb_name} VALUES (%s, %s);''', data)
    print(cur.statusmessage)

def insert_many_patients(tb_name, data):
    cur.executemany(f'''INSERT INTO {tb_name} VALUES (%s, %s, %s, %s);''', data)
    print(cur.statusmessage)

def insert_many_rend_services(tb_name, data):
    cur.executemany(f'''INSERT INTO {tb_name} VALUES (%s, %s, %s, %s);''', data)
    print(cur.statusmessage)




services = [(101, 'Лечение зубов'),
            (102, 'Протезирование'),
            (103, 'Отбеливание'),
            (104, 'Чистка полости рта'),
            (105, 'Декоративное украшение зубов'),
            (106, 'Рентгенодиагностика'),
            (107, 'Пародонтология'),
            (108, 'Исправление прикуса'),
            (109, 'Реставрация'),]

"""cur.execute('''INSERT INTO services (id, name) VALUES (100, 'Удаление зубов');''')
cur.executemany('''INSERT INTO services VALUES (id, name);''', services)
"""
patients = [(4, 'Зотов', 'Павлова 1, 10', 1964),
            (5, 'Ковалева', 'Свободы 81, 70', 1989),
            (6, 'Сидоров', 'NULL', 1989),
            (7, 'Фролов', 'Почтовая 65, 6', 1961),
            (8, 'Татаринова', 'Соборная 2, 10', 1975),
            (9, 'Ильин', 'Урицкого 67, 3', 1987),
            (10, 'Сафронова', 'Каляева 13, 20', 1980)]
"""
cur.execute('''INSERT INTO patients (number, surname, address, birth_year) 
            VALUES (1, 'Петров', 'Солнечная 8, 46', 1989),
            (2, 'Иванов', 'Радищева 22, 22', 1961),
            (3, 'Потапова', 'Горького 37, 12', 1968);
            ''')
cur.executemany('''INSERT INTO patients (number, surname, address, birth_year);''', patients)
"""

rendered_services = [(1, 102, '12:00:00', 600.0000),
                     (8, 104, '15:00:00', 500.0000),
                     (8, 109, '10:00:00', 100.0000),
                     (10, 107, '08:00:00', 250.0000),
                     (6, 104, '17:00:00', 1000.0000),
                     (2, 105, '21:00:00', 750.0000),
                     (4, 103, '19:00:00', 400.0000),
                     (7, 102, '12:00:00', 5000.0000),
                     (3, 109, '11:30:00', 260.0000),
                     (4, 106, '10:40:00', 340.0000),
                     (1, 102, '17:10:00', 560.0000),
                     (9, 104, '15:00:00', 50.0000),
                     (10, 107, '08:45:00', 100.0000),
                     (7, 100, '09:00:00', 2500.0000),
                     (3, 100, '10:30:00', 400.0000),
                     (2, 103, '11:00:00', 980.0000),
                     (1, 100, '16:00:00', 120.0000),
                     (4, 101, '12:40:00', 300.0000),
                     (9, 100, '14:35:00', 460.0000),
                     (6, 105, '20:00:00', 900.0000)]



#3. 
def print_rows():
    result = cur.fetchall()
    for row in result:
        print(row)


def select_all(tb_name, columns='*'):
    cur.execute(f"SELECT {columns} FROM {tb_name}")
    print_rows()
    

def select_where(tb_name, cur_col, param, columns='*'):
    cur.execute(f"SELECT {columns} FROM {tb_name} WHERE {cur_col} = {param}")
    print_rows()


def select_join(tb_name, tb_name_j, join_on, cur_col, param, columns='*'):
    cur.execute(f"SELECT {columns} FROM {tb_name} JOIN {tb_name_j} ON {tb_name}.{join_on} = {tb_name_j}.{join_on} WHERE {tb_name}.{cur_col} = {param}")
    print_rows()


#4. 
def update(tb_name, cur_col, param, condition_col, condition_param):
    cur.execute(f"UPDATE {tb_name} SET {cur_col} = {param} WHERE {condition_col} = {condition_param}")
    print(cur.statusmessage)
    

#5.
def delete_rows(tb_name, cur_col, param):
    cur.execute(f"DELETE FROM {tb_name} WHERE {cur_col} = {param}")
    print(cur.statusmessage)


def delete_all(tb_name):
    cur.execute(f"DELETE FROM {tb_name}")
    print(cur.statusmessage)

try:
    con = psp.connect(
        database="Dentistry",
        user="postgres",
        password="DwAe9653",
        host="localhost",
        port='5433'
    )
except (psp.Error, Exception) as er:
    print("Ошибка при подключении к PostgreSQL", er)


cur = con.cursor()
'''
create_tables()

insert_data('services', '(id, name)', "(100, 'Удаление зубов')")
insert_many_services('services', services)

insert_data('patients', '(number, surname, address, birth_year)', "(1, 'Петров', 'Солнечная 8, 46', 1989), (2, 'Иванов', 'Радищева 22, 22', 1961), (3, 'Потапова', 'Горького 37, 12', 1968)")
insert_many_patients('patients', patients)

insert_many_rend_services('rendered_services', rendered_services)'''

print('\nALL')
select_all('patients')
print('\nWHERE')
select_where('rendered_services', 'id', 102)
print('\nJOIN WHERE')
select_join('services', 'rendered_services', 'id', 'id', 102)

#update('patients', 'surname', "'Серегин'", 'number', 2)

#delete_rows('rendered_services', 'patient', '2')
delete_all('rendered_services')
con.commit()
con.close()
