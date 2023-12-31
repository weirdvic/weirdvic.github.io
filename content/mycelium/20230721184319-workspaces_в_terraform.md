+++
title = "Workspaces в Terraform"
lastmod = 2023-07-21
tags = ["Terraform"]
draft = false
+++

Определение рабочего пространства из [официальной документации](https://developer.hashicorp.com/terraform/language/state/workspaces) довольно расплывчатое. Условно рабочим пространством можно назвать постоянные данные и [cостояние(state)]({{< relref "20230721184206-состояние_в_terraform.md" >}}) для определённого бэкенда. Каждое рабочее пространство обладает собственным файлом состояния. Использовать рабочие пространства для разделения между разными окружениями(например development и production) плохая идея потому что рабочие пространства хранятся в одном месте и к ним применяются одинаковые ограничения доступа. Плюс легко ошибиться и выполнить команду в неправильном пространстве.


## Как создать новое рабочее пространство? {#как-создать-новое-рабочее-пространство}

`terraform workspace new <WORKSPACE_NAME>`


## Как определить текущее рабочее пространство? {#как-определить-текущее-рабочее-пространство}

`terraform workspace show`
