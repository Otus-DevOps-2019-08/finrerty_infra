# finrerty_infra
finrerty Infra repository

# HomeWork №2

1. Клонируем репозиторий себе на локальную машину
$ git clone git@github.com:Otus-DevOps-2019-08/<GITHUB_USER>_infra.git

2. Создаем ветку для данного ДЗ
$ git checkout -b play-travis

3. Производим интеграцию Slack и GitHub

4. Создаем файл travis.yml
dist: trusty
sudo: required
language: bash
before_install:
- curl https://raw.githubusercontent.com/express42/otus-homeworks/2019-08/run.sh |
bash

5. Устанавливаем Travis на локальную Ubuntu.
Для этого требуется предварительно установить пакеты ruby и ruby-dev
$ apt install ruby ruby-dev
$ gem install travis

6. Шифруем свой закрытый ключ утилитой travis и редактируем файл travis.yml (происходит автоматически)
$ travis login
$ travis encrypt "devops-team-otus:{TOKEN}#vladislav_kotov" --add notifications.slack.rooms

7. Делаем коммит, проверяем, что уведомления о коммите и тестировании билда появились в чате в Слаке.

8. Исправляем ошибку в файле play-travis/test.py (1 + 1 = 2, а не 1)


# HomeWork №3

1. Создаём новую ветку в репозитории
$ git checkout -b cloud-bastion

2. Регистрируемся в GCP

3. Создаём проект Infra, идентификатор - infra-253311

4. Создаём публичный ssh-ключ для подключения к виртуалкам в GCP.
$ ssh-keygen -t rsa -f ~/.ssh/vlad -C vlad -P ""

5. Создаём 2 виртуальные машины: с внешним IP и без.

6. Способ подключения к хосту без внешнего IP (someinternalhost) с локальной машины:
$ ssh -J vlad@35.210.48.2 10.132.0.3

7. Для подключения к someinternalhost напрямую по имени создаем файл ~/.ssh/config:
$ touch ~/.ssh/config
и записываем туда:
Host someinternalhost
Hostname 10.132.0.3
ProxyJump vlad@35.210.48.2
User vlad

8. На bastion разворачиваем VPN-сервер, используя файл setupvpn.sh

9. Настраиваем VPN
Организация - otus
Пользователь - test
PIN - 6214157507237678334670591556762
Сервер - Test_VPN
Порт - 19153/UDP

10. Конфигурация серверов
bastion_IP = 35.210.48.2
someinternalhost_IP = 10.132.0.3
