
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---


## Важно!

Перед отправкой работы на проверку удаляйте неиспользуемые ресурсы.
Это важно для того, чтоб предупредить неконтролируемый расход средств, полученных в результате использования промокода.

Подробные рекомендации [здесь](https://github.com/netology-code/virt-homeworks/blob/virt-11/r/README.md)

---

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.


```
- Быстрое понимание текущей конфигурации
- Скорость и уменьшение затрат на конфигурирацию инфраструктуры
- Легче сделать восстановление изменений
- Эффективный способ отслеживания инфраструктуры и повторного развертывания
- Масштабируемость и стандартизация
```
- Какой из принципов IaaC является основополагающим?

```
Идемпотентность - свойство объекта или операции при повторном применении операции к объекту давать тот же результат,
что и при первом.
```

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
```
- При неуспешной доставке конфигурации на сервер, оповестит об этом.
- Для описания конфигурационных файлов используется удобный для чтения формат YAML.
- Работает без агента на клиентах, использует ssh для доступа на клиент
- Ansible Galaxy - огромное комьюнити, где можно найти практически любое решение.
```
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?
```
Push надёжней, т.к. централизованно управляет конфигурацией и исключает ситуации, когда кто-то что-то исправил напрямую на сервере и не отразил в репозитории - это может потеряться или создавать непредсказуемые ситуации. Но не исключен риск если кто-то проникнет в ваш репозиторий git и сможет push'ить вредоносный код.
```
## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

> VirtualBox 6 на Windows 
```bash
$ vagrant --version
Vagrant 2.3.0
```
```bash
vagrant@vagrant1:~$ ansible --version
ansible [core 2.12.8]
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
