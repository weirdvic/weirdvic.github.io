+++
title = "Настройка локального container registry"
date = 2023-08-15T00:00:00+03:00
lastmod = 2023-11-01
tags = ["Docker", "Kubernetes"]
draft = false
+++

## Вводная часть {#вводная-часть}

В этой заметке рассказывается как запустить локально реестр образов контейнеров, который будет доступен как из [Docker]({{< relref "20230515190259-docker.md" >}})/[Podman]({{< relref "20230515190145-podman.md" >}}) на хосте, так и внутри [Kubernetes]({{< relref "20230426095140-kubernetes.md" >}}).


## Запуск локального реестра {#запуск-локального-реестра}


### Запуск контейнера с реестром {#запуск-контейнера-с-реестром}

Запускаем на хостовой машине официальный образ `registry:2.8`, образы будут храниться в примонтированной директории.

```bash
podman run --detach --name=registry --restart=always \
       --publish 5000:5000 \
       --volume ~/.registry/storage:/var/lib/registry registry:2.8
```


### Правка /etc/hosts {#правка-etc-hosts}

Добавляем в `/etc/hosts` на хосте Minikube имя `registry.devops-tools.svc.cluster.local` в строчку для `localhost`, так что у меня теперь файл выглядит так:

```cfg
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 registry.devops-tools.svc.cluster.local
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 registry.devops-tools.svc.cluster.local
```

Проверяем что реестр уже доступен с хостовой машины:

```bash
curl registry.devops-tools.svc.cluster.local:5000/v2/_catalog
```

Если всё сделали правильно, в ответе должно быть `{"repositories":[]}`.


### Добавление реестра в настройки Docker или Podman {#добавление-реестра-в-настройки-docker-или-podman}

В случае использования Docker достаточно создать или отредактировать файл `/etc/docker/daemon.json` чтобы он содержал следующую секцию:

```json
{
  "insecure-registries": ["registry.devops-tools.svc.cluster.local:5000"]
}
```

В случае если мы используем Podman, нужно либо отредактировать файл `/etc/containers/registries.conf`, либо(что более предпочтительно) создать новый файл `/etc/containers/registries.conf.d/000-local-registry.conf` со следующим содержимым:

```toml
[[registry]]
location = "registry.devops-tools.svc.cluster.local"
insecure = true
```

После этого перезапускаем Docker демон, а в случае с Podman просто проверяем корректно ли добавился репозиторий командой `podman info`.

Перезапускаем Minikube, добавив параметр `--insecure-registry`:

```bash
minikube start --driver=podman --insecure-registry registry.devops-tools.svc.cluster.local:5000
```


### Настройка статического IP адреса {#настройка-статического-ip-адреса}

Чтобы Minikube мог обращаться к реестру, доступному на хосте, нужно добавить второй адрес для loopback интерфейса хоста. Я использую [Oracle Linux]({{< relref "20230515192117-oracle_linux.md" >}}), поэтому команды привожу для этого дистрибутива:

```bash
export DEV_IP="172.16.1.1/24"
sudo nmcli device modify lo +ipv4.addresses ${DEV_IP}
```

Чтобы изменения не слетали при перезагрузке, редактируем файл `/etc/NetworkManager/system-connections/lo.nmconnection` и добавляем туда секцию для второго IP адреса интерфейса:

```toml
[ipv4]
address2=172.16.1.1/24
method=manual
```


### Правка /etc/hosts в Minikube {#правка-etc-hosts-в-minikube}

Внутри Minikube нужно добавить в `/etc/hosts` запись, указывающую на наш реестр образов:

```bash
export DEV_IP="172.16.1.1"
minikube ssh "echo \"${DEV_IP}      registry.devops-tools.svc.cluster.local\" | sudo tee -a  /etc/hosts"
```


### Создание сервиса Kubernetes {#создание-сервиса-kubernetes}

Теперь нам нужно создать сервис внутри кластера и эндпоинт Kubernetes, указывающий на адрес нашего хоста. У меня [Jenkins]({{< relref "20230809085954-jenkins.md" >}}) запущен внутри неймспейса `devops-tools`, как запустить Jenkins в кластере Minikube рассказано [здесь]({{< relref "20230809090530-установка_jenkins.md" >}}).

```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: registry
  namespace: devops-tools
spec:
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 5000
---
kind: Endpoints
apiVersion: v1
metadata:
  name: registry
  namespace: devops-tools
subsets:
  - addresses:
      - ip: 172.16.1.1
    ports:
      - port: 5000
```


## Итоги {#итоги}

В целом на этом всё. Если всё сделано правильно, реестр образов будет доступен как внутри кластера, так и с хостовой машины по адресу `registry.devops-tools.svc.cluster.local`. Мне локальный реестр был нужен ради того чтобы собирать образы при помощи Jenkins и Kaniko, о чём будет рассказано в отдельной заметке.
