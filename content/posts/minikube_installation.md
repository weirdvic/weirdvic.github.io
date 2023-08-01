+++
title = "Установка Minikube в Oracle Linux"
date = 2023-05-30T00:00:00+03:00
lastmod = 2023-07-21
tags = ["kubernetes", "podman", "nginx", "minikube"]
draft = false
+++

## Введение {#введение}

В этой статье я бы хотел зафиксировать процесс запуска учебного кластера [Kubernetes]({{< relref "20230426095140-kubernetes.md" >}}) в виде [Minikube]({{< relref "20230530171940-minikube.md" >}}) на сервере под управлением  [Oracle Linux]({{< relref "20230515192117-oracle_linux.md" >}}).

Подразумевается что сам сервер с доступом по ssh у нас уже есть. Я использую бесплатный инстанс в [Oracle Cloud]({{< relref "20230601214753-oracle_cloud.md" >}}), но в принципе можно использовать любое другое облако или даже любой другой хостинг, вплоть до подкроватного. Для запуска Minikube [необходимо минимум](https://minikube.sigs.k8s.io/docs/start/#what-youll-need) 2 ядра процессора и 2 Гб оперативной памяти.
Если мы используем free-tier облака от Oracle, то следует использовать машины на Ampere A1. Бесплатных лимитов хватает либо на то чтобы создать 2 машины с двумя ядрами, либо одну с четырьмя.

Я использую свою виртуальную машину для изучения Oracle Linux и [Podman]({{< relref "20230515190145-podman.md" >}}). Также нам понадобятся установленные на хосте cURL и [Nginx]({{< relref "20230515223342-nginx.md" >}}). Для генерации пароля нам понадобится утилита `htpasswd`, в Oracle Linux она входит в пакет с названием `httpd-tools`. Я буду делать доступ с привязкой домена, для наших целей подойдёт любой домен, вплоть до бесплатных от [Freenom](https://www.freenom.com). Для большей безопасности и других бонусов я использую прокси от [Cloudflare]({{< relref "20230515222941-cloudflare.md" >}}). Обо всём этом подробнее дальше.


## Устанавливаем Minikube {#устанавливаем-minikube}

Сама по себе установка Minikube довольно простая и описана в [документации](https://minikube.sigs.k8s.io/docs/start/):

```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
```

После этого необходимо создать кластер. Мы используем Podman, это явно нужно указать при создании:

```shell
minikube start --driver=podman
```

После окончания создания кластера, им уже можно пользоваться на удалённой машине, для проверки работоспособности предлагается выполнить команду:

```shell
minikube kubectl -- get pods -A
```

Если всё хорошо, можем двигаться дальше.


## Планируем удалённый доступ {#планируем-удалённый-доступ}

Кластер доступен на самом сервере, а мы хотим работать с ним с нашей локальной машины, как поступить в данном случае? По-умолчанию API-сервер Minikube принимает только локальные соединения, а значит нам понадобится настроить Nginx в качестве [реверс-прокси]({{< relref "20230516102127-reverse_proxy.md" >}}), который будет принимать авторизованные запросы на внешний IP нашего сервера и проксировать их на внутренний адрес API Kubernetes.

Иными словами, я хочу достигнуть следующей схемы:

<a id="figure--Minikube access diagram"></a>

{{< figure src="/ox-hugo/minikube-access-diagram.svg" caption="<span class=\"figure-number\">Figure 1: </span>Схема доступа к Minikube на сервере." >}}

Мы будем отправлять команды при помощи локального kubectl, запросы к API будут уходить на специальный домен или поддомен за [Cloudflare]({{< relref "20230515222941-cloudflare.md" >}}), оттуда проксироваться на виртуальную машину с запущенным [Minikube]({{< relref "20230530171940-minikube.md" >}}). На самой машине хостовый [Nginx]({{< relref "20230515223342-nginx.md" >}}) будет принимать подключения, проверять базовую авторизацию и проксировать доверенные подключения на локальный адрес Minikube.


## Настройка Nginx на сервере {#настройка-nginx-на-сервере}

Начнём с простого — сгенерируем пароль для защиты нашего подключения, в этой команде `minikube` — имя пользователя для HTTP авторизации:

```shell
sudo htpasswd -c /etc/nginx/.htpasswd minikube
```

Для примера можем использовать пароль `b3VyU3VwZXJTZWNyZXRQYXNzd29yZAo=`.

Разумеется, пароль надо где-нибудь сохранить, он нам ещё понадобится.

Для того чтобы наш Nginx мог проксировать запросы к Kubernetes API, ему нужны SSL сертификаты и здесь у меня возникла путаница. Поскольку Podman не требует запуска от root-пользователя, Minikube через Podman можно запускать от обычного пользователя. Следовательно, конфиг Minikube будет храниться в домашней директории обычного пользователя(в моих примерах стандартное имя пользователя `opc`) и файлы из него не будут доступны другим пользователям(например `nginx`). Самым простым решением будет скопировать файлы ключа и сертификата в директорию Nginx.

```shell
sudo mkdir -p /etc/nginx/certs
sudo cp /home/opc/.minikube/profiles/minikube/client.key /etc/nginx/certs/minikube-client.key
sudo cp /home/opc/.minikube/profiles/minikube/client.key /etc/nginx/certs/minikube-client.key
```

После этого можем создать конфиг реверс-прокси Nginx. У меня используется SSL сертификаты от Cloudflare, приведу пример той части конфига, которая нас интересует:

```nginx
# В http блоке добавляем такую штуку, это способ создать "глобальную переменную"
# в конфиге Nginx и в дальнейшем использовать её в разных других блоках.
# Быстро узнать адрес API Minikube можно командой minikube ip
map $host $MINIKUBE_IP {
  default "192.168.49.2";
}

# Ниже идёт серверный блок для приёма входящих подключений с авторизацией
# В примере используется субдомен k.examplehomelab.tk
# Сам субдомен предварительно нужно создать в Cloudflare, а также скачать
# сертификат и ключ для главного домена. Настройка SSL для Cloudflare это
# не очень сложная, хоть и обширная тема, материалов по которой много.
# https://developers.cloudflare.com/ssl/get-started/
server {
  listen       443 ssl http2;
  # Используем имя субдомена
  server_name  k.examplehomelab.tk;
  # Используем сертификат основного домена, благо Cloudflare даёт
  # wildcard сертификат типа *.examplehomelab.tk
  ssl_certificate "/etc/nginx/ssl/examplehomelab.tk.pem";
  ssl_certificate_key "/etc/nginx/ssl/examplehomelab.tk.key";
  ssl_session_cache shared:SSL:1m;
  ssl_session_timeout  10m;
  ssl_ciphers PROFILE=SYSTEM;
  ssl_prefer_server_ciphers on;
  auth_basic "Administrator’s Area";
  # Путь к нашему файлу для проверки авторизации
  auth_basic_user_file /etc/nginx/.htpasswd;

  # Собственно настройка проксирования запросов к API
  location / {
  proxy_http_version 1.1;
  proxy_pass https://$MINIKUBE_IP:8443;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "upgrade";
  # А здесь сертификат для общения с API Minikube по HTTPS
  proxy_ssl_certificate /etc/nginx/certs/minikube-client.crt;
  proxy_ssl_certificate_key /etc/nginx/certs/minikube-client.key;
  }
}
```

Конечно, конфиг не идеален, но для моего сценария использования вполне подходит. Выполняем стандартные манипуляции чтобы обновить конфиг:

```shell
sudo nginx -t
sudo service nginx reload
```

На этом этапе уже можно попробовать открыть наш адрес в браузере, если всё настроено корректно, браузер запросит авторизацию, а после ввода логина(`minikube`) и пароля(`b3VyU3VwZXJTZWNyZXRQYXNzd29yZAo=`) мы увидим список доступных путей Kubernetes API. Можем двигаться дальше, к настройке локального kubectl.


## Настройка kubectl {#настройка-kubectl}

Настал момент настроить подключение к кластеру с нашей локальной машины. По-умолчанию на сервере конфигурация Minikube хранится в файле `~/.kube/config`. Скопируем этот файл к себе на машину по тому же пути, он будет выглядеть примерно так:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/opc/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Tue, 30 May 2023 13:39:51 GMT
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: cluster_info
    server: https://192.168.49.2:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Tue, 30 May 2023 13:39:51 GMT
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/opc/.minikube/profiles/minikube/client.crt
    client-key: /home/opc/.minikube/profiles/minikube/client.key
```

Нужно поправить пару мест.

1.  Заменяем `server: https://192.168.49.2:8443` на наш внешний адрес сервера.
2.  В конце файла закомментировать или удалить строчки `client-certificate` и `client-key`, а вместо них добавить `username` со значением `minikube` и `password` со значением нашего пароля для HTTP авторизации.

Сохраняем файл и проверяем работоспособность:

```shell
kubectl get all -A
```

Для дополнительной безопасности ещё можно использовать правила Cloudflare чтобы ограничить доступ к API по стране или IP адресу если он у вас статический.

На этом всё, в дальнейшем можно работать с кластером так же как и с запущенным локально Minikube.
