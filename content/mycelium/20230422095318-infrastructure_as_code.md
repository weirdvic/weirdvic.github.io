+++
title = "Infrastructure as Code"
lastmod = 2023-07-29
tags = ["IaC", "DevOps"]
draft = false
+++

Infrastructure-as-Code или IaC это автоматизированный подход к описанию и управлению IT инфраструктурой не через ручное редактирование файлов конфигураций на серверах, а с применением специальных инструментов. Инструменты IaC являются важной частью практик [DevOps]({{< relref "0226a081-527d-47e3-bb61-24e10f1db907" >}}) и концепций CI/CD.

Под инфраструктурой в данном случае понимается совокупность аппаратных и программных компонентов, составляющих IT среду, таких как серверы, устройства хранения данных, сетевые устройства и т.д.

Основная идея IaC в том чтобы перенести практики, применяющиеся в разработке ПО на управление инфраструктурой. Сам код для управления инфраструктурой может быть написан как в декларативном стиле, так и в императивном. При декларативном подходе описывается желаемое состояние системы (в идеале), а необходимые действия для достижения этого состояния производит инструмент управления конфигурацией. Ну а при императивном подходе мы указываем что конкретно нужно сделать.

Также между разными инструментами существует различие в методе инициации обновления. Различают push метод это когда изменения конфигурации приходят с некоего управляющего хоста на управляемые и pull метод, когда управляемые хосты по-расписанию или при других условиях сами запрашивают обновление конфигурации у управляющего хоста.

К наиболее распространённым в практике инструментам IaC относятся:

-   [Terraform]({{< relref "20230721135308-terraform.md" >}})
-   Cloudformation
-   [Ansible]({{< relref "20230523211109-ansible.md" >}})
-   SaltStack
-   Puppet

Инструменты, использующие IaC подход можно разделить на две большие группы:

1.  Инструменты для развёртывания(provisioning) инфраструктуры, такие как Terraform и Cloudformation
2.  Инструменты для конфигурации инфраструктуры как Ansible, Puppet, Chef

Provisioning инфраструктуры это процесс создания компонентов инфраструктуры и предоставления доступа конечным пользователям.

Важной характеристикой IaC инструментов является [идемпотентность]({{< relref "20230728152604-идемпотентность.md" >}}).
