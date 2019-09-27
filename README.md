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
Сервер - Test_VPN
Порт - 19153/UDP

10. Конфигурация серверов
bastion_IP = 35.210.48.2
someinternalhost_IP = 10.132.0.3


# HomeWork №4

testapp_IP = 34.77.99.242
testapp_port = 9292

1. Создаём новую ветку в репозитории
$ git checkout -b cloud-testapp

2. Переносим файлы прошлого ДЗ в отдельную папку VPN
$ git mv setupvpn.sh VPN/setupvpn.sh
Аналогично для второго файла

3. Устанавливаем google SDK по инструкции https://cloud.google.com/sdk/docs/

4. Создаём новый инстанс
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure

5. Подключаемся к серверу и устанавливаем Ruby
$ ssh vlad@reddit-app
$ sudo apt update
$ sudo apt install -y ruby-full ruby-bundler build-essential

6. Устанавливаем MongoDB, запускаем и добавляем в автозапуск.
$ wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
$ echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
$ sudo apt update
$ sudo apt install -y mongodb-org
$ sudo systemctl start mongod
$ sudo systemctl enable mongod

7. Деплоим приложение.
$ git clone -b monolith https://github.com/express42/reddit.git
$ cd reddit && bundle install
$ puma -d

## Дополнительное задание №1
gcloud compute instances create reddit-app-test\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=/home/vlad/devops_courses/finrerty_infra/startup_script.sh

Если хотим загрузить из url, то помещаем файл в bucket и используем строку 
--metadata startup-script-url=gs://bucket/startup_script.sh

## Дополнительное задание №2
Создание правила фаерволла:
gcloud compute firewall-rules create puma-rule --allow tcp:9292 --target-tags=puma-server

# HomeWork #5

1. Создаём новую ветку в репозитории
$ git checkout -b packer-base

2. Переносим файлы прошлого ДЗ в отдельную папку config-scripts
$ git mv *.sh config-scripts/

3. Устанавливаем Packer
$ wget https://releases.hashicorp.com/packer/1.4.3/packer_1.4.3_linux_amd64.zip
$ unzip packer_1.4.3_linux_amd64.zip
$ mv packer /user/bin

4. Создаём ADC
$ gcloud auth application-default login

5. Создаем директорию packer, помещаем туда ubuntu16.json со следующим содержанием

6. Дополняем его скриптами install_ruby.sh и install_mongodb.sh

7. Проверяем корректность файла и build'им образ
$ packer validate ./ubuntu16.json 
$ packer build ubuntu16.json

8. Создаём из полученного шаблона виртуальную машину и подключаемся к ней
$ ssh -i ~/.ssh/vlad vlad@35.233.52.106

9. Деплоим приложение при помощи deploy.sh

10. Добавляем Network Tag puma-server для открытия порта приложения.

11. Параметризируем шаблон ubuntu16.json, используя следующую конструкцию:
"project_id": "{{user `project_id`}}"

ВАЖНО! ` - не одиночная кавычка!!

12. Добавляем следующие опции builder для GCP в файлы ubuntu16.json и variables.json
"image_description"
"disk_size"
"disk_type"
"network"
"tags"

## Дополнительное задание №1
Созданы файлы:
immutable.json
в качестве скрипта при запуске взят чуть доработанный startup_script.sh из прошлого ДЗ

Запуск билда:
$ packer build -var-file=variables.json immutable.json

## Дополнительное задание №2
gcloud compute instances create reddit-app-test \
>   --image=reddit-full-1569413083 \
>   --restart-on-failure

