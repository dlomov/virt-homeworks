# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
```bash
➜  06-db-04-postgresql git:(master) ✗ docker run --rm --name postgresql13 \
    -e POSTGRES_PASSWORD=postgres \
    -v my_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    -d postgres:13
Unable to find image 'postgres:13' locally
13: Pulling from library/postgres

➜  06-db-04-postgresql git:(master) ✗ docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                    NAMES
e710a2aa7648   postgres:13   "docker-entrypoint.s…"   43 seconds ago   Up 24 seconds   0.0.0.0:5432->5432/tcp   postgresql13 
```
Подключитесь к БД PostgreSQL используя `psql`.

```bash
➜  06-db-04-postgresql git:(master) ✗ docker exec -it postgresql13 bash
root@e710a2aa7648:/# psql -U postgres
psql (13.9 (Debian 13.9-1.pgdg110+1))
Type "help" for help.

postgres=#
```
Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД - \l и \l+
- подключения к БД - \conninfo
- вывода списка таблиц - \dtS
- вывода описания содержимого таблиц - \dS+
- выхода из psql - \q

## Задача 2

Используя `psql` создайте БД `test_database`.
```sql
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
```
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.
```bash
➜  06-db-04-postgresql git:(master) ✗ docker cp ./test_data/test_dump.sql postgresql13:/tmp
➜  06-db-04-postgresql git:(master) ✗ docker exec -it postgresql13 bash
root@e710a2aa7648:/# psql -U postgres -f /tmp/test_dump.sql  test_database
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
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)
ALTER TABLE
```
Перейдите в управляющую консоль `psql` внутри контейнера.
```bash
root@e710a2aa7648:/# psql -U postgres
psql (13.9 (Debian 13.9-1.pgdg110+1))
Type "help" for help.

postgres=# 
```

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

```sql
postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# \dt+
                              List of relations
 Schema |  Name  | Type  |  Owner   | Persistence |    Size    | Description 
--------+--------+-------+----------+-------------+------------+-------------
 public | orders | table | postgres | permanent   | 8192 bytes |
(1 row)

test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=#

```
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

```sql
select avg_width from pg_stats where tablename = 'orders' order by avg_width desc limit 1;
 avg_width 
-----------
        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

```sql
CREATE TABLE orders_1 (CHECK (price > 499)) INHERITS (orders);
INSERT INTO orders_1 SELECT * FROM orders WHERE price > 499;
CREATE TABLE orders_2 (CHECK (price <= 499)) INHERITS (orders);
INSERT INTO orders_2 SELECT * FROM orders WHERE price <= 499;
DELETE FROM ONLY orders;
test_database=# \dt
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | orders   | table | postgres
 public | orders_1 | table | postgres
 public | orders_2 | table | postgres
(3 rows)

```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?
```TEXT
Можно, если прописать RULE INSERT:
```
```SQL
CREATE RULE orders_1 AS ON INSERT TO orders WHERE ( price > 499 ) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
CREATE RULE orders_2 AS ON INSERT TO orders WHERE ( price <= 499 ) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
```
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
```bas
export PGPASSWORD=postgres && pg_dump -U postgres test_database > /tmp/test_database_dump.sql
```
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```text
Можно добавить атрибут UNIQUE на уровне таблиц патриций:
```
```sql
ALTER TABLE public.orders_1 ADD UNIQUE (title);
ALTER TABLE public.orders_2 ADD UNIQUE (title);
```
---
