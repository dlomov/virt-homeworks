# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
[Dockerfile]
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
```bash
➜  06-db-05-elasticsearch git:(master) ✗ docker build -t dlomov/elasticsearch:8.6.0 .
➜  06-db-05-elasticsearch git:(master) ✗ docker push dlomov/elasticsearch:8.6.0
The push refers to repository [docker.io/dlomov/elasticsearch]
```
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины
```bash
➜  06-db-05-elasticsearch git:(master) ✗ docker run --rm -d -p 9200:9200 dlomov/elasticsearch:8.6.0 
6363c9239eefede67fa43d682825a93f4dc3a934988ddad79fe2dd13f2c9ecac
➜  06-db-05-elasticsearch git:(master) ✗ curl http://localhost:9200/
{
  "name" : "netology_test",
  "cluster_name" : "netology",
  "cluster_uuid" : "6OzDBOibRvOwpoRwCRsMpA",
  "version" : {
    "number" : "8.6.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "f67ef2df40237445caa70e2fef79471cc608d70d",
    "build_date" : "2023-01-04T09:35:21.782467981Z",
    "build_snapshot" : false,
    "lucene_version" : "9.4.2",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
➜  06-db-05-elasticsearch git:(master) ✗ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
➜  06-db-05-elasticsearch git:(master) ✗ curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 2
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}

```
Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl 'localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 RyfYTqxbT5qU0UBePq0g1Q   1   0          0            0       225b           225b
yellow open   ind-3 UMqW6X8RQVW5VbhmL9FsJg   4   2          0            0       900b           900b
yellow open   ind-2 6h_RboY8SeGYTePkWeZTvA   2   1          0            0       450b           450b
```
Получите состояние кластера `elasticsearch`, используя API.
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444}
```
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
```
Одна нода не может размещать реплики. Secondary shards в состоянии unassigned т.к. нету нод для реплик. Primary shards и Secondary shards не могут находиться на одном узле, если реплика не назначена.
```
Удалите все индексы.
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X DELETE "localhost:9200/ind-1,ind-2,ind-3?pretty" 
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
```bash
➜  06-db-05-elasticsearch git:(master) ✗ docker exec -u root -it ecstatic  bash
[root@6363c9239eef elasticsearch]# mkdir $ES_HOME/snapshots
```
Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.
```bash
curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/elasticsearch-8.6.0/snapshots"
  }
}' 
{"acknowledged" : true}
```

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```bash
curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

curl -X GET "localhost:9200/_cat/indices?v&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  ExilkJVUQ1aSOqwkuIP37g   1   0          0            0       225b           225b
```
[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.
```bash
curl -X PUT "localhost:9200/_snapshot/netology_backup/my_snapshot?pretty"
{
  "accepted" : true
}
````
**Приведите в ответе** список файлов в директории со `snapshot`ами.
```bash
ls -lh /elasticsearch-8.6.0/snapshots/
total 36K
-rw-r--r-- 1 elasticsearch elasticsearch  844 Jan  24 22:07 index-2
-rw-r--r-- 1 elasticsearch elasticsearch    8 Jan  24 22:07 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch 4.0K Jan  24 22:07 indices
-rw-r--r-- 1 elasticsearch elasticsearch  18K Jan  24 22:07 meta-ExilkJVUQ1aSOqwkuIP37g-w.dat
-rw-r--r-- 1 elasticsearch elasticsearch  355 Jan  24 22:07 snap-ExilkJVUQ1aSOqwkuIP37g-w.dat
```
Удалите индекс `test` и создайте индекс `test-2`. 
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}
{
  "acknowledged" : true
}
```
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X PUT "localhost:9200/test-2?pretty"
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 
**Приведите в ответе** список индексов.
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X GET "localhost:9200/_cat/indices?v&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   test-2 B0k8_HYGS8q-kgRK4FYuAA   1   1          0            0       225b           225b
```

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty -H 'Content-Type: application/json' -d'
{"include_global_state":true}'
{"accepted" : true}
```
```bash
➜  06-db-05-elasticsearch git:(master) ✗ curl -X GET "localhost:9200/_cat/indices?v&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   test-2 B0k8_HYGS8q-kgRK4FYuAA   1   1          0            0       225b           225b
green  open   test   gBEyGCQzEdOqkFF2b8DtDO   1   0          0            0       225b           225b
```
Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
