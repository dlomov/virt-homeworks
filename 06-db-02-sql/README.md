# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

### Ответ

- [docker-compose манифест](docker-compose.yml)
- docker-compose -f docker-compose.yaml up -d
- Запустили и проверили версию и подключился к базе
```bash
docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                    NAMES
b57f1e6beead   06-db-02-sql-postgres   "docker-entrypoint.s…"   8 minutes ago   Up 8 minutes   0.0.0.0:5432->5432/tcp   06-db-02-sql-postgres-1

psql -h localhost -U pguser -d pgdb -c "SELECT version();"
                                                     version
------------------------------------------------------------------------------------------------------------------        
 PostgreSQL 12.0 (Debian 12.0-2.pgdg100+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 8.3.0-6) 8.3.0, 64-bit
(1 row)

psql -h localhost -U pguser -d pgdb
psql (14.5 (Ubuntu 14.5-0ubuntu0.22.04.1), server 12.0 (Debian 12.0-2.pgdg100+1))

pgdb=# \l
List of databases
Name    | Owner  | Encoding |  Collate   |   Ctype    | Access privileges
-----------+--------+----------+------------+------------+-------------------
pgdb      | pguser | UTF8     | en_US.utf8 | en_US.utf8 |
postgres  | pguser | UTF8     | en_US.utf8 | en_US.utf8 |
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
```sql
CREATE DATABASE test_db;
CREATE USER "test-admin-user" WITH PASSWORD '***';
```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```sql
test_db=# CREATE TABLE orders (id SERIAL, наименование VARCHAR, цена INT, PRIMARY KEY(id));
CREATE TABLE clients (id SERIAL, "фамилия" VARCHAR,"страна проживания" VARCHAR, "заказ" INT,
PRIMARY KEY (id), FOREIGN KEY(заказ) REFERENCES orders(id));
CREATE INDEX idx_country ON clients ("страна проживания");
```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
```
- создайте пользователя test-simple-user
```sql
CREATE USER "test-simple-user" WITH PASSWORD '***';
``` 
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";
```

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
```sql
test_db=# \l
                              List of databases
   Name    | Owner  | Encoding |  Collate   |   Ctype    | Access privileges 
-----------+--------+----------+------------+------------+-------------------
 pgdb      | pguser | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | pguser | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | pguser | UTF8     | en_US.utf8 | en_US.utf8 | =c/pguser        +
           |        |          |            |            | pguser=CTc/pguser
 template1 | pguser | UTF8     | en_US.utf8 | en_US.utf8 | =c/pguser        +
           |        |          |            |            | pguser=CTc/pguser
 test_db   | pguser | UTF8     | en_US.utf8 | en_US.utf8 | 
(5 rows)
```
- описание таблиц (describe)
```sql
test_db=# \d+ orders
                                                        Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------------+-------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 наименование | character varying |           |          |                                    | extended |              |
 цена         | integer           |           |          |                                    | plain    |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap

test_db=# \d+ clients
                                                           Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default               | Storage  | Stats target | Description
-------------------+-------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 фамилия           | character varying |           |          |                                     | extended |              |
 страна проживания | character varying |           |          |                                     | extended |              |
 заказ             | integer           |           |          |                                     | plain    |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "idx_country" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```sql
test_db=# SELECT * from information_schema.table_privileges WHERE grantee in ('test-admin-user', 'test-simple-user') order by grantee asc;
```
- список пользователей с правами над таблицами test_db
```sql
 grantor |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
---------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 pguser  | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 pguser  | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | clients    | INSERT         | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | clients    | SELECT         | NO           | YES
 pguser  | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | clients    | DELETE         | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
 pguser  | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
 pguser  | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 pguser  | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 pguser  | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 pguser  | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 pguser  | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 pguser  | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 pguser  | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 pguser  | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(22 rows)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

```sql
insert into orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);

test_db=# SELECT * FROM orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)
```
Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```sql
insert into clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');

test_db=# SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ 
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |
  2 | Петров Петр Петрович | Canada            |
  3 | Иоганн Себастьян Бах | Japan             |
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
(5 rows)
```
Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
```sql
test_db=# select count (*) from orders;
 count 
-------
     5
(1 row)

test_db=# select count (*) from clients;
 count 
-------
     5
(1 row)
```
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
Подсказк - используйте директиву `UPDATE`.
```sql
test_db=# SELECT * from clients where "заказ" is not null;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```sql
test_db=# EXPLAIN SELECT * from clients where "заказ" is not null;
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72)
   Filter: ("заказ" IS NOT NULL)
(2 rows)
```
- `Seq Scan` - используется последовательное чтение данных таблицы
- `cost` - затратность операции
  - `0.00` - затраты на получение первой строки
  - `1.05` - затраты на получение всех строк
- `rows` - приблизительное количество возвращаемых строк при выполнении операции `Seq Scan`
- `width` - средний размер одной строки в байтах

EXPLAIN показывает ожидания планировщика, для анализа на реальных данных можно использовать EXPLAIN (ANALYZE)

```sql
test_db=# EXPLAIN (ANALYZE) SELECT * from clients where "заказ" is not null;
                                             QUERY PLAN
-----------------------------------------------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72) (actual time=0.082..0.083 rows=3 loops=1)
   Filter: ("заказ" IS NOT NULL)
   Rows Removed by Filter: 2
 Planning Time: 0.201 ms
 Execution Time: 0.209 ms
(5 rows)
```
- `actual time` - реальное время в миллисекундах, затраченное для получения первой строки и всех строк соответственно
- `rows` - реальное количество строк, полученных при `Seq Scan`
- `loops` - сколько раз пришлось выполнить операцию `Seq Scan`

## Задача 6

- Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
```bash
docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED        STATUS        PORTS                    NAMES
root@ce1ad94c7a3c   06-db-02-sql-postgres   "docker-entrypoint.s…"   28 hours ago   Up 28 hours   0.0.0.0:5432->5432/tcp   06-db-02-sql-postgres-1
➜  06-db-02-sql git:(master) ✗ docker exec -it ce1ad94c7a3c bash

root@ce1ad94c7a3c:/ pg_dump -U pguser -W test_db > /backups/test_db.dump

root@ce1ad94c7a3c:/# ls /backups/
test_db.dump

➜  06-db-02-sql git:(master) ✗ docker volume ls
DRIVER    VOLUME NAME
local     06-db-02-sql_backup-vol
local     06-db-02-sql_data-vol
```
Остановите контейнер с PostgreSQL (но не удаляйте volumes).
```bash
➜  06-db-02-sql git:(master) ✗ docker-compose down
[+] Running 2/2
 ⠿ Container 06-db-02-sql-postgres-1  Removed                                                                                                                                                0.8s 
 ⠿ Network 06-db-02-sql_default       Removed
```
Поднимите новый пустой контейнер с PostgreSQL.
```bash
docker run -d -v 06-db-02-sql_backup-vol:/data postgres:12.0
```
Восстановите БД test_db в новом контейнере.
Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
```bash
docker ps
docker exec -it 05678b29dc9a bash
root@05678b29dc9a:/# ls /data
test_db.dump
root@05678b29dc9a:/# exit
psql -U postgres
postgres=# CREATE DATABASE test_db;
CREATE DATABASE
postgres=# CREATE USER "pguser" WITH PASSWORD 'pguser';
CREATE ROLE
postgres=# CREATE USER "test-admin-user" WITH PASSWORD '123';
CREATE ROLE
postgres=# CREATE USER "test-simple-user" WITH PASSWORD '123';
\q
root@05678b29dc9a:/# psql -U postgres test_db < /data/test_db.dump
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      1
(1 row)

 setval
--------
      1
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
GRANT

```
Базу восстановил, но перед этим создал роли и пустую базу test_db.
- Проверил, данные консистентны.
```psql
root@05678b29dc9a:/# psql -U postgres 
psql (12.0 (Debian 12.0-2.pgdg100+1))
Type "help" for help.

postgres=# \connect test_db
You are now connected to database "test_db" as user "postgres".
test_db=# SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)

test_db=# SELECT * FROM orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)
```
---
