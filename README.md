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


# HomeWork №6
1. Создаём новую ветку в репозитории  
$ git checkout -b terraform-1

2. Устанавливаем Terraform  
$ wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip  
$ unzip terraform_0.12.9_linux_amd64.zip  
$ mv terraform /usr/bin

3. Создаём папку terraform и обновляем файл .gitignore  
$ mkdir terraform  
$ wget https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/.gitignore.example  
$ echo | cat .gitignore.example > .gitignore  
$ rm .gitignore.example

4. Создаём файл main.tf, описываем провайдер. Инициализируем Terraform.  
$ terraform init

5. Помещаем puma.service и deploy.sh из прошлого ДЗ в папку terraform/files  
$ mv ../config-scripts/deploy.sh 
$ gsutil cp gs://packer-base-bucket/puma-server.service files/ 

6. Дополняем файл main.tf, приводя его часть с описанием ресурса к подобному виду.  
https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/part_of_main.tf

6. Выполняем планирование изменений и, убедившись, что всё в порядке, применяем.  
$ terraform plan  
$ terraform apply (предпочитаю не использовать параметр -auto-approve, чтобы без сюрпризов)

7. Создаём variables.tf и определяем в ней переменные.

8. Редактируем main.tf, используя определённые в variables.tf переменные.

9. Создаём файл terraform.tfvars для хранения значений переменных и секретов.

10. Заново создаём машину уже со всеми применёнными изменениями  
$ terraform plan  
$ terraform apply

11. Определяем input переменную для приватного ключа. Для этого выполняем следующие действия:
- Добавляем описание переменной в variables.tf
- Добавляем значение переменной (путь к файлу закрытого ключа) в terraform.tfvars
- Меняем в main.tf значение private key = file(var.private_key_path)

12. Определяем input переменную для задания зоны.
- Аналогично предыдущему, но дописываем default = "europe-west1-b" в variables.tf

13. Выполняем форматирование. В каталоге Terrafrom выполняем команду  
$ terraform fmt

14. Создаем для примера файл terraform.tfvars.example, заменив некоторые данные

## Дополнительное задание №1
Для добавления ключа в метаданные проекта воспользуемся следующей конструкцией:  
```
resource "google_compute_project_metadata" "ssh-keys" {
  metadata = {
    user:${file(var.public_key_path)}
  }
```
  
Для добавления нескольких ключей:
```
resource "google_compute_project_metadata" "ssh-keys" {
  metadata = {
    ssh-keys = <<EOF
    vlad:${file(var.public_key_path)}
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
    appuser3:${file(var.public_key_path)}
EOF
  }
}
```
При выполнении terraform apply затираются все внесённые через web изменения

## Дополнительное задание №2

- Создаём второй инстанс reddit-app-2 путём копирования кода reddit-app
- Создаём файл lb.tf. В нём нам будут необходимы 3 ресурса:  
  google_compute_http_health_check, создание балансировщика  
  google_compute_target_pool, указываем какие инстансы будем балансировать  
  google_compute_forwardig_rule, создаём правило проксирования
- Модифицируем файл outputs.tf, указывая наши инстансы с атрибутами  
- Коммитим сделанное перед выполнением второй части задания

## Дополнительное задание №2 (пункт 2)

Выполнение задания указанным выше способом имеет под собой ряд минусов.  
1. Неудобное масштабирование. Меняем сразу много файлов при появлении нового хоста.
2. В случае, если хостов у нас много - файл main.tf будет монструозным :)
3. Высокая вероятность ошибки при редактировании файлов.  
Поэтому вносим следующие изменения:
- Редактируем файл main.tf. Добавляем параметр count и изменяем параметр name.  
ВНИМАНИЕ!! Из-за изменения имени серверов они пересоздадутся.
- Редактируем файл lb.tf, а именно параметр instances.
- Модифицируем файл outputs.tf, вместо явных названий приложений пишем порядковые номера.
- Добавляем переменную server_count со значением по-умолчанию 1.


# HomeWork №7
1. Создаём новую ветку в репозитории  
$ git checkout -b terraform-2

2. В файле terraform.tfvars выставляем значение server_count = 1  

3. Переносим lb.tf в поддиректорию files  
$ git mv lb.tf files/

4. Добавляем информацию о текущем правиле default-allow-ssh в state файл  
Это необходимо для возможности его редактирования вместо создания нового  
$ terraform import google_compute_firewall.firewall_ssh default-allow-ssh

5. Вносим изменения в файл main.tf, описывая правило доступа к серверам по ssh  

6. Добавляем ресурс reddit-app-ip для создания статического адреса нашим terraform'ом

7. Присваиваем созданный ранее IP-адрес нашему серверу с приложением 

8. Разделяем инфраструктуру на несколько VM. Первым делом переписываем шаблоны packer.  
Для этого создаем 2 файла:  
db.json, где в сегменте "provisioners" указываем скрипт установки MongoDB  
app.json, где в сегменте "provisioners" указываем скрипт установки Ruby

9. Создаём новые шаблоны packer'ом  
$ packer build -var-file=variables.json app.json
$ packer build -var-file=variables.json db.json

10. В директории terraform создаём файлы db.tf и app.tf.  
Копируем в них необходимые для функционирования VM ресурсы.

11. Создаём файлы vpc.tf для SSH-правила и ssh.tf для описание SSH-ключей проекта.

12. Создаём директорию modules, размещаем в ней 2 директории app и db  
В обеих директориях создаём файлы:  
main.tf  
outputs.tf
variables.tf  

13. В файле main.tf указываем путь к модулям в формате "./modules/app", затем выполняем  
$ terraform get

14. Указываем в корневом файле outputs.tf путь к аналогичному файлу в модуле app
```
output "app_external_ip" {
  value = module.app.app_external_ip
}
```

15. Создаём модуль vpn, размещаем в нем файлы:  
main.tf
outputs.tf
variables.tf  
В файл main.tf прописываем:  
```
resource "google_compute_firewall" "firewall_ssh" {
  name = "default-allow-ssh"
  description = "Allow SSH from anywhere"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

```

16. Добавляем переменную для source_ranges, описываем её в variables.tf
```
variable source_ranges {
  description = "Allowed IP addresses"
  default = ["0.0.0.0/0"]
}
```

17. Меняем значение default на наш внешний IP-адрес, пробуем подключиться по ssh  
$ ssh vlad@35.240.102.227 - Подключение проходит успешно

18. Меняем значение default на случайний внешний IP-адрес, пробуем подключиться по ssh  
$ ssh vlad@35.240.102.227 - Подключение не проходит

19. Возвращаем значение default 0.0.0.0/0

20. Реализовано разделение на stage и prod путём создания новых директорий в корневой

21. Добавлен модуль storage-bucket:  
Outputs:  
storage-bucket_url = gs://reddit-app-storage-bucket

## Дополнительное задание №1

- Для реализации удалённого бэкенда воспользуемся созданным в прошлом шаге Backet'ом  
Создаём файл backend.tf в корневой директории stage со следующим содержанием:  
```
terraform {
  backend "gcs" {
    bucket = "reddit-app-storage-bucket"
    prefix = "terraform/state/stage"
  }
}

```
Аналогично поступаем и для prod

- Теперь проверяем работу в другом репозитории  
$ mkdir ~/test  
$ mkdir ~/test/stage  
$ cp -R /terraform/modules ~/test/ && cp *.tf* ~/test/stage/  
$ cd ~/test/stage && terraform init  
Получаем сообщение:  
Successfully configured the backend "gcs"! Terraform will automatically  
use this backend unless the backend configuration changes.

- Теперь проверим работу блокировок, выполняем terraform destroy в обеих директориях  
В первой (по счёту) директории всё выполняется успешно, а вот во второй получаем ошибку:  
Error: Error locking state ... googleapi: Error 412: Precondition Failed, conditionNotMet


## Дополнительное задание №2

- Для использования файлов в provisioners перенесём их в папку модуля app
- Отредактируем пути в файле main.tf модуля app следующим образом:  
source = "../modules/app/files/puma.service"  
script = "../modules/app/files/deploy.sh"

-Теперь нам необходимо настроить взаимодействие приложения с БД:
1. Создадим output-переменную db_internal_ip в модуле db
```
output "db_internal_ip" {
  value = google_compute_instance.db.network_interface.0.network_ip
}
```
2. В файлах main.tf сред stage и prod передадим значение этой переменной модулю app
```
db_internal_ip   = module.db.db_internal_ip
```
3. Объявим эту переменную в файле variables.tf модуля app
```
variable db_internal_ip {
  description = "Database network IP"
}
```
4. Добавим в main.tf provisioner для передачи этой переменной в систему
```
  provisioner "remote-exec" {
    inline = ["echo export DATABASE_URL=\"${var.db_internal_ip}\" >> ~/.profile"]
  }
```  
Мы реализовали передачу ip-адреса БД приложению. Однако база всё равно не работает.  
Для решения этой проблемы необходимо отредактировать mongod.conf в системе с БД:
5. Создадим "правильный" mongod.conf и разместим его в папке files модуля db
6. Опишем подключение к серверу в файле main.tf модуля db
```
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "vlad"
    agent       = false
    private_key = file(var.private_key_path)
  }
```
Для выполнения данной операции необходимо заранее объявить переменную ключа в variables.tf:
```
variable private_key_path {
  description = "Path to the public key used to connect to instance"
}
```
7. Туда же добавим 2 provisioner'a для размещения этого файла в системе
```
  provisioner "file" {
    source = "../modules/db/files/mongod.conf"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv /tmp/mongod.conf /etc/mongod.conf && sudo systemctl restart mongod"]
  }
```
Теперь выполним terraform apply и убедимся, что наше приложение полностью функционирует.


# HomeWork №8
1. Создадим новую ветку  
$ git checkout -b ansible-1

2. Создадим файд requirements.txt с описанием требуемой версии ansible и выполним:  
$ sudo pip install -r requirements.txt

3. Создадим файл inventory с описанием информации, необходимой для подключения по SSH к хостам

4. Выполним команды для проверки работы файла:  
$ ansible appserver -i ./inventory -m ping  
$ ansible dbserver -i inventory -m ping

5. Создадим ansible.cfg для хранения дефолтных параметров

6. Сократим inventory-файл и разделим описанные в нём хосты на группы.

7. Выполним несколько команд для проверки корректности всех выполненных настроек  
$ ansible app -m ping  
$ ansible app -m command -a 'ruby -v'  
$ ansible app -m shell -a 'ruby -v; bundler -v'  

8. Воспользуемся модулями ansible для проверки состояния сервисов на хостах  
$ ansible db -m systemd -a name=mongod  
$ ansible db -m service -a name=mongod

9. Напишем playbook clone.yml для клонирования приложения из git, выполним  
$ ansible-playbook clone.yml  
Увидим, что плейбук выполнен, но, т.к. такая папка уже была создана, никаких изменений нет.

10. Теперь удалим папку с приложением и опять выполним playbook clone.yml  
$ ansible-playbook clone.yml  
Теперь в вкачестве результата выполнения указано: "changed: [appserver]" и "changed=1"


## Дополнительное задание №1

Для создания файла inventory.json воспользуемся Inventory plugins.
1. Установим необходимые пакеты для авторизации Google  
$ sudo pip install requests google-auth

2. Сформируем в GCP файл для аутентификации в формате json

3. Создадим Inventory-файл со следующим содержанием:  
```
plugin: gcp_compute
projects:
  - infra-253311
zones:
  - europe-west1-b
filters: []
auth_kind: serviceaccount
service_account_file: "/home/vlad/.gcp/infra-253311-496a801da892.json"

```

4. Сформируем json файл  
$ ansible-inventory -i inventory.gcp.yml --list | tee inventory.json

5. Выполним:  
$ ansible -i inventory.gcp.yml all -m ping  
Получаем следующий вывод:
```
104.155.27.197 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

34.76.239.78 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```


# HomeWork №9
1. Создадим новую ветку  
$ git checkout -b ansible-2

2. Закомментируем провижининг в конфигурации модулей app и db в Terraform

3. Реализуем 2 подхода в создании плейбуков, создав файлы:  
reddit_app_multiple_plays.yml  
reddit_app_one_play.yml

4. Теперь создадим отдельные плейбуки для каждого действия, разделив предыдущие  
app.yml  
db.yml  
deploy.yml

5. Объединим выполнение данных плейбуков в site.yml

6. Пересоздадим инфраструктуру и проверим корректность работы site.yml  
Так же меняем IP-адреса в inventory.yml и IP-адрес сервера БД в переменной db_host  
$ cd terraform/stage && terraform destroy --auto-approve  
$ terraform apply --auto-approve  
$ cd .. && cd ../ansible && ansible-playbook site.yml  

Далее убеждаемся, что сайт доступен.  

7. Создадим packer_app.yml, заменив им скрипт packer/scripts/install_ruby.sh  
Для этого воспользуемся модулем apt:
```
apt:
      update_cache: yes
      name: "{{ packages }}"
    vars:
      packages:
      - ruby-full
      - ruby-bundler
      - build-essential
```

8. Теперь необходимо заменить скрипт packer/scripts/install_mongod.sh  
Здесь нам потребуется несколько модулей: apt_key, apt_repository и service  
Создадим файл packer_db.yml:
```
  tasks:
  - name: Add APT Key
    apt_key:
      url: https://www.mongodb.org/static/pgp/server-3.2.asc
      state: present

  - name: Add mongoDB repository
    apt_repository:
      repo: deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
      state: present

  - name: Update repos && MongoDB Installation
    apt:
      update_cache: yes
      name: mongodb-org
      state: present

  - name: Enable MongoDB
    service:
      name: mongod
      enabled: yes
      state: started
```

9. Теперь укажем пути к новым файлам в разделе provisioners в JSON-файах Packer'a

10. Теперь проврим, что инфраструктура собирается корректно:  
- Удаляем старые образы Packer'a
- Создаём новые:  
$ packer build -var-file=variables.json app.json  
$ packer build -var-file=variables.json db.json

- Пересоздаём инфраструктуру  
$ cd ../terraform && terraform destroy --auto-approve  
$ terraform apply --auto-approve

- Меняем ip-адреса в файле inventory.yml и IP-адрес сервера БД в переменной db_host

- Выполняем все созданные ранее плейбуки для разворота приложения  
$ cd ../ansible && ansible-playbook site.yml


## Дополнительное задание №1

При выполнении данного задания мы столкнулись с тем, что после каждого пересоздания  
инфраструктуры необходимо вручную переписывать внешние адреса серверов и внутренний  
адрес сервера БД. Это неудобно. Для решения этой проблемы у нас уже есть Dynamic  
Inventory, созданный в прошлом домашнем задании. Воспользуемся им.  

1. Отредактируем файл ansible.cfg, указав в качестве Inventory файл inventory.gcp.yml

2. Теперь мы можем динамически получать адреса наших хостов. Но они не разделены на группы.  
Исправляем эту ситуацию, добавив в файл следующую конструкцию
```
groups:
  app: "'app' in name"
  db: "'db' in name"
```

3. Теперь необходимо передать внутренний адрес сервера БД в файл app.yml. Для этого  
сначала необходимо этот адрес получить. Воспользуемся модулем compose:
```
compose:
  ip: networkInterfaces[0].networkIP
```

4. Описанная выше конструкция позволяет нам получать внутренние IP серверов.  
Однако, чтобы передать переменную, необходимо описать имя хоста. Добавляем:
```
hostnames:
  - name
```

5. Теперь передаём значение переменной в app.yml
```
vars:
  db_host: "{{ hostvars['reddit-db'].ip }}"
```
Пытаемся выполнить плейбук и ничего не получается, потому что ансибл не может  
подключиться к хостам по имени.

6. Соответственно, необходимо добавить соответствие. Дописываем:  
```
compose:
  ...
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```

7. Теперь пересоздаем инфраструктуру и запускаем play.  
$ cd ../terraform/stage && terraform destroy --auto-approve
$ terraform apply --auto-approve
$ cd ../ansible && ansible-playbook site.yml


# HomeWork №10
1. Создадим новую ветку  
$ git checkout -b ansible-3

2. Создадим 2 новые роли: app и db  
$ ansible-galaxy init app  
$ ansible-galaxy init db

3. Теперь займёмся наполнением роли db, необходимо изменить 3 .yml файла в папках:  
/roles/db/tasks/main.yml  
/roles/db/handlers/main.yml  
/roles/db/defaults/main.yml

4. Так же перенесём шаблон файла mongod.conf.j2 в папку  
/roles/db/templates/mongod.conf.j2

5. Выполним аналогичные действия для роли app, только тут ещё заполним папку files:  
/roles/app/files/puma.service

6. В файлах tasks/main.yml обеих ролей изменим полные пути к src файлам на их имена

7. Приведём плейбуки к виду для вызова роли, например - db.yml:
```
- name: App configuration
  hosts: app
  become: true
  vars:
    db_host: "{{ hostvars['reddit-db'].ip }}"
  
  roles:
    - app
```

8. Заново создадим инфраструктуру и проверим работоспособность ролей  
$ terraform destroy --auto-approve  
$ terraform apply --auto-approve  
$ cd ../ansible && ansible-playbook site.yml

9. Перед дальнейшими действиями необходимо немного изменить конфигурацию Terraform  
Реализация данных изменений подробно описана в дополнительном задании №1

10. Настроим наш ansible для управления stage и prod инфраструктурой  
Реализация данных изменений подробно описана в дополнительном задании №1

11. Рассортируем по папкам файлы из корня директории Ansible

12. В файл ansible.cfg допишем:
```
[defaults]
...
roles_path = ./roles

[diff]
always = True
context = 5
...
```

13. Проверим корректную работу обоих окружений  

14. Установим jdauphant.nginx  
$ touch environments/stage/requirements.yml  
$ touch environments/prod/requirements.yml  

15. Добавим в них запись с названием и версией данной роли  

16. Установим роль  
$ ansible-galaxy install -r environments/stage/requirements.yml

17. Добавим в файлы stage/group_vars/app и prod/group_vars/app:
```
nginx_sites:
  default:
    - listen 80
    - server_name "reddit"
    - location / {
        proxy_pass http://127.0.0.1:9292;
      }
```

18. Добавим в terraform открытие 80 порта для окружений stage и prod  
В файле app/main.tf в ресурсе google_compute_firewall допишем:  
ports    = ["80", "9292"]

19. В Ансибле в файл playbooks/app.yml добавим вызов роли jdauphant.nginx

20. Заново создадим окружение stage, выполним плейбук site.yml и проверим 80 порт  
$ cd terraform/stage && terraform apply --auto-approve  
$ cd .. && cd .. && ansible-playbook ansible/playbooks/site.yml --check  
*Данная команда не отрабатывает до конца и завершается ошибкой. Однако  
$ ansible-playbook ansible/playbooks/site.yml  
Выполняется без ошибок и после завершения плея reddit-app доступен по 80-му порту

21. Создадим файл ~/.ansible/vault.key

22. Опишем его в ansible.cfg  
```
[defaults]
...
vault_password_file = ~/.ansible/vault.key
```

23. Создадим 2 файла с логинами-паролями пользователей и зашифруем их  
$ ansible-vault encrypt environments/prod/credentials.yml  
$ ansible-vault encrypt environments/stage/credentials.yml  

24. Добавим в плейбук playbooks/site.yml строку " - import_playbook: users.yml"

25. Пересоздадим всю инфраструктуру и проверим, что созданные учетки работают


## Дополнительное задание №1
Работа с Dynamic Inventory уже была настроена в предыдущих заданиях.  
Теперь разделим среды stage и prod.  

### Первым делом необходимо настроить terraform:

- Объявим переменную environment в файле terraform/stage/variables.tf
```
variable environment {
  description = "Environment type: stage or prod"
  default = "stage"
}
```

- Передадим данную переменную в модули с помощью файла terraform/stage/main.tf
```
...
module "app" {
  ...
  environment      = var.environment
}

module "db" {
  ...
  environment      = var.environment
}
```
- Теперь проделаем аналогичную процедуру для prod-среды, изменив stage на prod.

- Осталось объявить переменную в модулях.  
Добавим в terraform/modules/app/variables.tf и terraform/modules/db/variables.tf
```
variable environment {
  description = "Environment type: stage or prod"
}
```

- Используем нашу переменную в названиях серверов БД и приложения  
В файле terraform/modules/db/main.tf отредактируем строчку:  
```
name         = "reddit-db-${var.environment}"
```
Аналогично в файле terraform/modules/app/main.tf

- Теперь наши сервера будут называться reddit-app-stage/prod и reddit-db-stage/prod

### Настраиваем ansible
- Перенесём наш inventory.gcp.yml в директории stage и prod.

- В директории stage изменим модуль groups нашего инвентори:
```
groups:
  app: "'app-stage' in name"
  db: "'db-stage' in name"
```

- Аналогичные действия произведём и с prod

- Теперь создадим перемененные групп хостов.  
В файле environments/stage/group_vars/app установим следующее значение db_host:
```
db_host: "{{ hostvars['reddit-db-stage'].ip }}"
```
В environments/prod/group_vars/app:
```
db_host: "{{ hostvars['reddit-db-prod'].ip }}"
```

- Такое же разделение сделаем для файла group_vars/all различных окружений

- Допишем модуль debug для вывода названия окружения перед выполнением плейбуков


## Дополнительное задание №2
Для внесения изменений в TravisCI настроим trytravis:
1. Установим trytravis  
$ pip install trytravis

2. Создадим тестовый репозиторий - https://github.com/finrerty/trytravis-test.git

3. Укажем его в качестве основного для trytravis'a  
$ trytravis --repo ssh://git@github.com/finrerty/trytravis-test

4. Зайдём в корень репозитория и выполним команду  
$ trytravis  

5. Дожидаемся ответа, что билд прошёл успешно.

6. Теперь необходимо настроить тесты. Для этого пишем простой скрипт tests.sh:
```
#!/bin/bash
# install ansible for packer validate
sudo pip install --upgrade pip
sudo pip install ansible

#packer
packer validate -var-file=packer/variables.json.example packer/app.json
packer validate -var-file=packer/variables.json.example packer/db.json
packer validate -var-file=packer/variables.json.example packer/immutable.json
packer validate -var-file=packer/variables.json.example packer/ubuntu16.json

#install terraform & tflint
curl https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip -o /tmp/terraform.zip
sudo unzip /tmp/terraform.zip terraform -d /usr/bin/
curl https://raw.githubusercontent.com/wata727/tflint/master/install_linux.sh | bash

#terraform stage
cd terraform/stage
terraform get && terraform init
tflint
terraform validate

#terraform prod
cd ../prod
terraform get && terraform init
tflint
terraform validate

#Install Ansible-lint
cd .. && cd ..
sudo pip install ansible-lint

#Ansible
ansible-lint -x 401 ansible_playbooks/*
```

7. Для успешного прохождения тестов так же необходимо изменить пути в скриптах  
Packer'a с scripts/startup_script.sh на packer/scripts/startup_script.sh.

8. И указываем в файле .travis.yml к нему путь для выполнения
```
...
before_install:
- sh ./play-travis/tests.sh
...
```

9. Выполняем trytravis

10. Все тесты успешно выполнены  
https://travis-ci.com/finrerty/trytravis-test/jobs/249120234
