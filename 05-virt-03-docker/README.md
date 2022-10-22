
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

---

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.
## Ответ

Ссылка на репозиторий https://hub.docker.com/r/dlomov/nginx

```bash
#подготовим Nginx для запуска
~/www$ nano index.html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>Im DevOps Engineer!!!!</h1>
</body>
</html>
~/www$ cd ..
$ mkdir conf.d
$ cd conf.d
~/conf.d$ nano default.conf
server {
        listen          80;
        server_name     _;


        location /      {
                root    /var/www/html;
                index   index.html index.htm;
        }
}
:~/conf.d$ cd ..
#Запускаем в интерактивном режиме -it с входом в bash
$ docker run -it --rm -p 8080:80 -v ~/www:/var/www/html -v ~/conf.d:/etc/nginx/conf.d nginx bash
:/# service nginx start
#Или в фоне -d
$ docker run --rm -p 8080:80 -v ~/www:/var/www/html -v ~/conf.d:/etc/nginx/conf.d -d nginx
b7042e637be715f64b344ab8d3c3bdeb98bea1e3ad82d91ff67fe800b21bc367
#Проверим
$ curl localhost:8080
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
#подготовим папки с файлами для сборки Dockerfile
$ mkdir dlomov
$ cp -r conf.d dlomov/
$ cp -r www dlomov/
#создадим Dockerfile
$ nano Dockerfile
$ cat Dockerfile
FROM nginx
MAINTAINER dlomov "******@gmail.com"
COPY www/index.html /var/www/html/index.html
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
ENTRYPOINT ["nginx", "-g", "daemon off;"]
#соберем образ
$ docker build -t dlomov/nginx:v1 .
[+] Building 12.3s (9/9) FINISHED
#проверим
$ docker run -d -p 8080:80 --name Netology dlomov/nginx:v1
b75682214356a092cbfff3a77d4e6dbdb87e582088438387662645824dd7313c
$ docker ps -a
CONTAINER ID   IMAGE            STATUS        PORTS                  NAMES
b75682214356   dlomov/nginx:v1  Up 5 seconds  0.0.0.0:8080->80/tcp   Netology
#пушим на докер хаб
$ docker push dlomov/nginx:v1
The push refers to repository [docker.io/dlomov/nginx]

```

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

## Ответ

- Высоконагруженное монолитное java веб-приложение;
> Физическая машина, чтобы не расходовать ресурсы на виртуализацию и из-за монолитности не будет проблем с разворачиванием на разных машинах.
- Nodejs веб-приложение;
> Docker, для более простого воспроизведения зависимостей в рабочих средах
- Мобильное приложение c версиями для Android и iOS;
> Виртуальные машины, проще для тестирования, размещения на одной хостовой машине
- Шина данных на базе Apache Kafka;
> Docker, есть готовые образы для apache kafka, на руку изолированность приложений, а также легкий откат на стабильные версии в случае обнаружения багов в продакшене
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
> Docker, Elasticsearch доступен для установки как образ docker, проще удалять логи, удобнее при кластеризации - меньше времени на запуск контейнеров.
- Мониторинг-стек на базе Prometheus и Grafana;
> Docker. Есть готовые образы, приложения не хранят данные, что удобно при контейниризации, удобно масштабировать и быстро разворачивать.
- MongoDB, как основное хранилище данных для java-приложения;
> Физическая машина как наиболее надежное, отказоустойчивое решение. Либо виртуальный сервер.
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry
> Могут быть применены все варианты, в зависимости от наличия соответствующих ресурсов. Но для большей изолированности лучше использовать docker.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

## Ответ

```bash
#Запускаем контейнеры с Centos и Debian
➜  ~ docker run -it --rm -d --name centos -v $(pwd)/data:/data centos:latest
1f0f5649a9b5341bfec915ea80e72c58434fa5f203671a9b9c65db5c908bdac6
➜  ~ docker run -it --rm -d --name debian -v $(pwd)/data:/data debian:stable
0149440b8802da7d2f7e0503a8d23eea720c8f70d689fcb0f55ef7ec8027810e
#Подключились в контейнер Centos и создали файл
➜  ~ docker exec -it centos bash
[root@1f0f5649a9b5 /]# echo "I'm CentOS!" > /data/centos.txt
[root@1f0f5649a9b5 /]# exit
#Создали файл на хосте
➜  ~ echo "I'm Host!" > data/host.txt
#Подключились к контейнеру с Debian и вывели ls папки data
➜  ~ docker exec -it debian bash
root@0149440b8802:/# ls -l data/
total 8
-rw-r--r-- 1 root root 12 Oct 22 05:07 centos.txt
-rw-r--r-- 1 1000 1000  9 Oct 22 05:09 host.txt
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.


---