+++
title = "Быстрый запуск WireGuard сервера"
date = 2023-08-01T00:00:00+03:00
lastmod = 2023-11-09
tags = ["Cloud", "WireGuard", "VPN"]
draft = false
+++

## Постановка задачи {#постановка-задачи}

По работе понадобилось желательно быстро запустить VPN сервер с возможностью быстрого создания и отключения новых пользователей.
Для создания VPN я практически всегда пользуюсь [WireGuard](https://www.wireguard.com/) потому что он быстрый, поддерживается из коробки в [Linux]({{< relref "20231109155504-linux.md" >}}) и в RouterOS и позволяет использовать разные конфигурации.

Например, у меня есть необходимость доступа к компьютеру, находящемуся за NAT. У меня есть VPS с внешним IP адресом и доступом по SSH. Я запустил на VPS сервер WireGuard, подключил целевую машину клиентом и теперь могу ходить на неё через VPS. Через тот же VPS у меня настроен тоннель до домашней сети, так что когда мне нужен доступ к файлам на домашнем хранилище, я могу подключиться через интернет.

Проблема с WireGuard в другом — долгое время отсутствовали удобные интерфейсы для управления пользователями, генерацию ключей и обновление конфига сервера приходилось делать вручную. Это терпимо если тоннели нужно перенастраивать редко, например если VPN используется только членами семьи или для статических тоннелей, но в случае необходимости оперативно добавить/убрать пользователей предпочтительнее какой-никакой GUI.


## Решение — wg-easy {#решение-wg-easy}

На самом деле для WireGuard сервера уже есть несколько веб-интерфейсов, но в данном случае я решил использовать [wg-easy](https://github.com/wg-easy/wg-easy/).

Из плюсов:

-   Простые установка и запуск
-   Создание, отключение и удаление клиентов VPN
-   Возможность отобразить конфиг в виде QR-кода, который можно отсканировать приложением WireGuard для Android или iOS

Из минусов (но может быть и плюсом…):

-   Проект поставляется в [Docker]({{< relref "20230515190259-docker.md" >}}), так что на сервере придётся ставить Docker


## Установка и запуск {#установка-и-запуск}

Элементарные, по README проекта, без каких-либо подводных камней:

1.  Получить доступ к хосту, на котором будем запускать сервер. Я создал бесплатную виртуалку в [Oracle Cloud]({{< relref "20230601214753-oracle_cloud.md" >}}) c 2 ядрами и гигабайтом оперативки. Для простого VPN этого будет достаточно.
2.  Установить Docker на хост:
    ```bash
    curl -sSL https://get.docker.com | sh
    sudo usermod -aG docker $(whoami)
    # После этого обязательно нужно перелогиниться
    ```
3.  Создать где-нибудь файлик start-server.sh со следующим содержимым:
    ```bash
    docker run \
           --detach \
           --name=wg-easy \
           --restart=unless-stopped \
           # В WG_HOST должен быть внешний IP адрес сервера
           -e WG_HOST=$(curl -Ls https://checkip.info) \
           # Пароль от веб-интерфейса
           -e PASSWORD="U3VwZXJTZWNyZXRBZG1pblBhc3N3b3JkCg" \
           -v ~/.wg-easy:/etc/wireguard \
           # На UDP порт будут поступать входящие подключения
           # На TCP порту находится веб-интерфейс
           # Если доступ по внешнему IP не нужен, то можно
           # привязаться к локалхосту:
           # -p 127.0.0.1:51821:51821/tcp \
           -p 51820:51820/udp \
           -p 51821:51821/tcp \
           --cap-add=NET_ADMIN \
           --cap-add=SYS_MODULE \
           --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
           --sysctl="net.ipv4.ip_forward=1" \
           weejewel/wg-easy
    ```
4.  Запускаем сервер скриптом, проверяем что контейнер стартанул нормально.
5.  Если требуется, вносим изменения в настройки фаервола облачного провайдера, чтобы разрешить входящие подключения на UDP порт.

Более безопасным вариантом использования будет открывать наружу только UDP порт для входящих подключений клиентов, а TCP порт привязывать к локальному порту хоста, использовав параметр `-p 127.0.0.1:51821:51821/tcp` в команде для запуска сервера. При таких настройках для доступа к веб-интерфейсу потребуется открыть SSH тоннель, это можно сделать добавлением ключа при подключении к серверу, например так:

```bash
ssh -L localhost:51821:localhost:51821 admin@wireguard-server
```

Но указывать этот параметр при каждом подключении неудобно, поэтому я храню настройки тоннелей в `~/.ssh/config`:

```cfg
Host wireguard-server
  HostName 123.123.123.123
  User admin
  LocalForward 51821 localhost:51821
```

После подключения с пробросом порта можем открыть в браузере страницу <http://localhost:51821> и залогиниться в веб-интерфейс сервера.
Дальнейшие операции по созданию и управлению пользователями в целом понятны.


## Слабые места и задание со звёздочкой {#слабые-места-и-задание-со-звёздочкой}

-   Необходимость замены IP адреса
    В случае если IP нашего сервера забанили и мы хотим его сменить, либо хотим перенести пользователей на другой сервер — во всех случаях, когда у нас меняется IP сервера, клиентам придётся обновлять конфиг WireGuard на своей стороне. Эту проблему можно обойти если использовать в конфиге не IP адрес, а домен, который будет указывать на текущее расположение нашего сервера.
