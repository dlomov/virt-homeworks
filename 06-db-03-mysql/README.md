# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
[Docker-compose.yaml](https://github.com/dlomov/virt-homeworks/blob/master/06-db-03-mysql/docker-compose.yaml).
```bash
➜  06-db-03-mysql git:(master) ✗ docker-compose -f docker-compose.yaml up -d
[+] Running 12/12
 ⠿ mysql Pulled                                                                                             complete                                                                                              103.7s 
[+] Running 3/3
 ⠿ Network 06-db-03-mysql_db_net     Created                                                                                   0.1s 
 ⠿ Volume "06-db-03-mysql_mysql_db"  Created                                                                                   0.0s
 ⠿ Container mysql                   Started 
```


Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.
```bash
➜  06-db-03-mysql git:(master) ✗ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS                          PORTS     NAMES
427e26325c16   mysql:8   "docker-entrypoint.s…"   2 minutes ago   Restarting (1) 18 seconds ago             mysql
➜  06-db-03-mysql git:(master) ✗ docker cp test_data/test_dump.sql mysql:/tmp 
                                bash-4.4# mysql -u root -p test_db < /tmp/test_dump.sql
```
Перейдите в управляющую консоль `mysql` внутри контейнера.
```bash
➜  06-db-03-mysql git:(master) ✗ docker exec -it mysql-docker bash
                                bash-4.4# mysql -u root -p test_db
```

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```sql
mysql> status
--------------
mysql  Ver 8.0.32 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          14
Current database:       test_db
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.32 MySQL Community Server - GPL
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```sql
mysql> USE test_db;
Database changed
mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> SHOW FULL TABLES;
+-------------------+------------+
| Tables_in_test_db | Table_type |
+-------------------+------------+
| orders            | BASE TABLE |
+-------------------+------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300.
```sql
mysql> SELECT COUNT(*) FROM orders WHERE price > '300';
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"
```sql
mysql> CREATE USER 'test'@'localhost' 
    ->     IDENTIFIED WITH mysql_native_password BY 'test-pass'
    ->     WITH MAX_CONNECTIONS_PER_HOUR 100
    ->     PASSWORD EXPIRE INTERVAL 180 DAY
    ->     FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
    ->     ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
Query OK, 0 rows affected (0.04 sec)
```
Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
```sql
mysql> GRANT SELECT ON test_db.* TO test@localhost;
Query OK, 0 rows affected, 1 warning (0.05 sec)
```
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';
+------+-----------+------------------------------------------------+
| USER | HOST      | ATTRIBUTE                                      |
+------+-----------+------------------------------------------------+
| test | localhost | {"last_name": "Pretty", "first_name": "James"} |
+------+-----------+------------------------------------------------+
1 row in set (0.01 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
```sql
mysql> set profiling=1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
Изучите вывод профилирования команд `SHOW PROFILES;`.
```sql
mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                |
+----------+------------+----------------------------------------------------------------------+
|        1 | 0.00083450 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test' |
|        2 | 0.00027400 | SELECT DATABASE()                                                    |
|        3 | 0.00017175 | set profiling=1                                                      |
+----------+------------+----------------------------------------------------------------------+
3 rows in set, 1 warning (0.00 sec)
```

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```sql
mysql> SELECT table_schema,table_name,engine FROM information_schema.tables WHERE table_schema = DATABASE();
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)
```
Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`
```sql
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.18 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.17 sec)
Records: 5  Duplicates: 0  Warnings: 0
```
```sql
mysql> SHOW PROFILES;
+----------+------------+------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                |
+----------+------------+------------------------------------------------------------------------------------------------------+
|        5 | 0.17417725 | ALTER TABLE orders ENGINE = MyISAM                                                                   |
|        6 | 0.16801050 | ALTER TABLE orders ENGINE = InnoDB                                                                   |
+----------+------------+------------------------------------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```
## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.
```text
Файл лежит в /etc/.
```

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```sql
cat etc/my.cnf  
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/

innodb_flush_method = O_DSYNC
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = ON
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 4G
innodb_log_file_size = 100M
```

---
