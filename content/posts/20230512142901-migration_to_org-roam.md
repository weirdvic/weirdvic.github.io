+++
title = "Миграция в org-roam"
date = 2023-05-12T00:00:00+03:00
lastmod = 2023-05-29
tags = ["emacs", "org-mode", "org-roam", "python"]
categories = ["emacs"]
draft = false
+++

Недавно я начал использовать [org-roam](https://www.orgroam.com/) для управления своими заметками при помощи Emacs. Самим Emacs я пользуюсь уже довольно давно, но перечень задач, выполняемый в этой прекрасной "операционной системе" периодически изменяется. Прелесть Emacs, как многие уже отмечали, в том что это не цель, но путь. Можно начать использовать его как простой текстовый редактор, а затем постепенно добавлять или убирать функции, подстраивая систему под свой рабочий процесс. Часто это означает что ты перестаёшь пользоваться отдельной программой потому что её функции доступны и в Emacs. Так было у меня с отдельным эмулятором терминала когда я открыл для себя [vterm](https://github.com/akermu/emacs-libvterm). В другой раз я попытался настроить Emacs для работы с базами данных, но довольно быстро понял что использовать отдельный специализировнный инструмент в виде [DBeaver](https://dbeaver.io/) лично мне намного удобнее. В этот же раз речь пойдёт о задаче ведения заметок и о том как это _можно_ делать при помощи Emacs.

Для ведения различных рабочих и не очень заметок в последние годы я использовал [org-mode](https://orgmode.org/) в самом базовом варианте. У меня был один единственный файл `~/work.org`, в который каждый рабочий день за каждым рабочим днём я добавлял записи о том чем занимался вчера и чем планирую заняться сегодня. Выглядело это упрощённо вот так:

```org
* [2020-02-19]
Что сделал:
- Задача 1…
  Подробности по задаче
- Задача 2…
- Задача 3…
Что сделать:
- [X] Задача 1…
- [ ] Задача 2…
  Подробное описание задачи 2…
- [X] Задача 3…
```

Такой способ организации и ведения заметок может показаться примитивным, но на период когда я им пользовался, это был идеальный баланс между удобством ведения такого журнала и пользой от его ведения. Иногда всё что требуется сохранить это простой список дел, которые нужно отмечать в течение дня, какой-то кусок кода или ссылку и не более того. Конечно, я рассматривал и альтернативы вроде [Google Keep](https://keep.google.com), но в конечном итоге оказалось что ведение заметок в Emacs лично мне удобнее, а необходимости часто делиться содержимым заметок с кем-либо у меня нет.

Так или иначе, в определённый момент я стал использовать org-mode и для не связанных с работой заметок, например для хобби-проектов. Стали появляться новые org файлы, разбросанные по разным местам и никак не систематизированные. Кроме того, во время прохождения различных курсов и туториалов полезно делать хоть небольшие конспекты, которые также нужно где-то сохранять. Был соблазн собрать вообще все заметки в один мастер-файл `notes.org` и я знаю что некоторые пользователи Emacs придерживаются такого подхода. Но мне захотелось более структурированного решения для создания персональной базы знаний с возможностями поиска, отсутствием привязки к сторонним онлайн сервисам и удобным интерфейсом. Разворачивание собственной вики показалось громоздким, онлайн сервисы типа [Notion](https://www.notion.so/) мне не нравятся именно из-за онлайновости и проблем с доступностью функций и самих данных: сегодня функция n есть в бесплатном тарифе, завтра она может оказаться уже только в платном, а послезавтра сделают премиум фичей экспорт данных из сервиса.

В общем, под мои пожелания в итоге подошли два продукта: [Obsidian](https://obsidian.md/) и уже упомянутый [org-roam](https://www.orgroam.com/). Обе системы предназначены для ведения базы связанных между собой заметок, хранят данные в локально в простом текстовом формате и обладают возможностями расширения за счёт плагинов в случае Obsidian и за счёт мощи Emacs Lisp в случае org-roam. При этом порог вхождения однозначно ниже у Obsidian, с которого я и решил начать. Программа кроссплатформенная, легко устанавливается (в случае с Linux можно даже просто скачать и запустить AppImage файл), читать документацию чтобы просто начать добавлять заметки не требуется, интерфейс можно сказать интуитивный. В целом впечатления от использования очень приятные, наверное лучший вариант в своей категории если вы не пользователь Emacs. Я же пользуюсь Emacs и через несколько дней работы с Obsidian понял что держать отдельную программу только для заметок мне не нравится. И так хватает двух браузеров (Firefox и Chromium) и двух мессенджеров (Telegram и рабочий Google Chat) чтобы ещё держать рядом с работающим Emacs параллельно запущенный Obsidian. Кстати говоря, перенос мессенджеров внутрь Emacs это тоже вполне реально, но об этом в другой раз. Примерно через неделю использования Obsidian я решил что всё же стоит потратить время и усилия на конфиг Emacs и перейти на org-roam.

Что представляет из себя org-roam? Сайт проекта говорит об "a plain-text personal knowledge management system" и по-сути так оно и есть. Org-roam это система, построенная поверх емаксового org-mode и позволяющая структурированно хранить заметки в org файлах со связями между заметками для организации базы знаний. Хороший ресурс для начала знакомства с системой это её [мануал](https://www.orgroam.com/manual.html), в котором описаны базовые функции, вводится терминология и приводятся примеры конфигурации Emacs для начала работы. После прочтения мануала начинается увлекательный процесс допиливания системы под свои потребности aka "копипаст и переписывание кусков кода из чужих конфигов".

Одна из сильных сторон Emacs и одновременно его слабостей (см. [The Lisp Curse](http://www.winestockwebdesign.com/Essays/Lisp_Curse.html)) — очень редко есть единственный популярный и поддерживаемый способ делать что-либо. С одной стороны существование альтернатив это хорошо, но с другой это усложняет выбор обучение в случае если ты совсем новичок и для тебя все альтернативы отличаются лишь названиями. Причём эта особенность присутствует практически на всех уровнях взаимодействия с Emacs. Сейчас наиболее используемой версией Emacs является [GNU Emacs](https://www.gnu.org/software/emacs/), но были времена когда существовала альтернатива в виде [XEmacs](http://www.xemacs.org/). Сам GNU Emacs нынче можно установить как в относительно ванильной версии, так и в виде преднастроенных "дистрибутивов" вроде [Doom Emacs](https://docs.doomemacs.org/latest/) или [Spacemacs](https://www.spacemacs.org/). Внутри самого Emacs существует сильно больше одного способа управления сторонними пакетами, лично я пользуюсь [use-package](https://jwiegley.github.io/use-package/). Даже для org-roam как системы ведения заметок существует своя альтернатива — [Denote](https://protesilaos.com/emacs/denote) и в ходе поиска информации по настройкам org-roam я встречал упоминания о том что иногда люди переходят с одной системы на другую.

В ходе настройки своего Emacs я использовал эти статьи:

-   [My org-roam workflows for taking notes and writing articles](https://honnef.co/articles/my-org-roam-workflows-for-taking-notes-and-writing-articles/)
-   [My Org Roam Notes Workflow](https://hugocisneros.com/blog/my-org-roam-notes-workflow)

И даже несмотря на всё это, меня удивило то как реализован поиск по заметкам в org-roam. А организован он почти что никак — в уже упомянутом стартовом мануале есть небольшой пункт про настройку полнотекстового поиска посредством [Deft](https://jblevins.org/projects/deft/), но на этом и всё. Deft, как уже можно догадаться, тоже не единственный в своём роде, как минимум есть [Xeft](https://sr.ht/~casouri/xeft/). Но вообще поиск по Реддиту и Гитхабу показал что пользователи org-roam готовят поиск по заметкам кому как нравится. Для себя я остановился на [consult-org-roam](https://github.com/jgru/consult-org-roam), его функция поиска использует [ripgrep](https://github.com/BurntSushi/ripgrep) или обычный grep для поиска по файлам в org-roam.

Другой функцией, доступной из коробки в Obsidian является просмотр графа связей между отдельными заметками. Для org-roam существует пакет [org-roam-ui](https://github.com/org-roam/org-roam-ui), который просто  устанавливается в Emacs и позволяет по-всякому визуализировать связи между нодами:

<a id="figure--org-roam-ui-example"></a>

{{< figure src="/ox-hugo/org-roam-ui-01.png" caption="<span class=\"figure-number\">Figure 1: </span>Связи между нодами org-roam на момент написания статьи" >}}

После настройки визуализации и создания первых заметок на различные темы надо было решить что сделать со старым файлом `~/work.org`. Вариантов было немного:

-   Добавить файл в org-roam "как есть". В таком случае на графе это была бы единственная точка.
-   Разделить файл на отдельные заметки по дням, и в дальнейшем создавать новые заметки с использованием org-roam daily.

Я выбрал второй вариант, поэтому на графе много ни с чем не связанных нод. При желании их легко можно исключить из визуализации:

<a id="figure--org-roam-ui-without-dailies"></a>

{{< figure src="/ox-hugo/org-roam-ui-02.png" caption="<span class=\"figure-number\">Figure 2: </span>Граф связей в org-roam без daily заметок" >}}

Единый файл с заметками я разделил на отдельные файлы с помощью небольшого скрипта на Python:

```python
#!/usr/bin/env python3
import re,hashlib,time


# Задаём регулярное выражение, по которому будем определять, является ли
# текущая строка заголовком первого уровня в оригинальном org файле.
# В моём случае все заголовки первого уровня в файле имеют такой формат:
# * [2020-02-19 Ср]
# Собрать нужную регулярку можно на https://regex101.com/
headingRX = re.compile(r'^\*\s\[(\d{4}-\d{2}-\d{2})\s[а-яА-я]{2,3}\]$')

# Создаём хэш-объект, который будем использовать для генерации униальных ID
# каждого создаваемого org-roam файла.
hasher = hashlib.md5()

def createOrgRoamFile():
    '''Создает новый org-roam файл с шаблоном текста.'''
    # Получаем md5-хэш от значения текущей даты и текущего времени
    hasher.update(f'{currentDate}-{time.time()}'.encode('utf-8'))
    # Хэш будет использоваться в качестве ID ноды в org-roam
    nodeID = hasher.hexdigest()
    # Создаем шаблон, который будет записан в начало org-roam файла.
    # В минимальном варианте он будет выглядеть так:
    # :PROPERTIES:
    # :ID: <nodeID>
    # :END:
    # #+title: <currentDate>
    # #+date: [<currentDate>]
    #
    # Ниже будет собственно содержимое заметки.
    orgRoamTemplate = f':PROPERTIES:\n:ID: {nodeID}\n:END:\n#+title: {currentDate}\n#+date: [{currentDate}]\n\n'
    # Записываем шаблон в начало org-roam файла, используя currentDate в качестве названия файла.
    with open(f'{currentDate}.org', 'w') as output_file:
        output_file.write(orgRoamTemplate)

def splitOrgFile(inputFileName:str='notes.org') -> None:
    '''Разделяет входной org-mode файл на отдельные ноды org-roam.
    В качестве имени файла по-умолчанию используется notes.org.'''
    # В переменной currentDate будет храниться дата из текущего заголовка.
    # Дата используется при генерации ID создаваемой org-roam ноды, в шаблоне
    # заметки, а также в качестве имени создаваемого файла.
    global currentDate
    currentDate = ''

    with open(inputFileName, 'r') as inputFile:
        # Буффер для временного хранения строк файла перед записью в org-roam
        buffer = []
        # Читаем файл построчно
        for line in inputFile:
            # Если это первый найденный заголовок
            if not currentDate and headingRX.match(line):
                # Извлекаем дату из заголовка и открываем новый файл
                currentDate = headingRX.search(line).group(1)
                createOrgRoamFile()
            # Если мы уже нашли заголовок и создали файл и текущая строка
            # не является заголовком, добавляем строку во временный буфер.
            elif currentDate and not headingRX.match(line):
                buffer.append(line)
            # Если же мы уже нашли заголовок и создали файл и текущая строка
            # является заголовком, значит текущая строка — это новый заголовок.
            # Записываем буфер в файл, очищаем его и создаём новый файл.
            elif currentDate and headingRX.match(line):
                # Дописываем содержимое буфера в текущий файл
                with open(f'{currentDate}.org', 'a') as output_file:
                    output_file.writelines(buffer)
                    # Очищаем буфер, извлекаем дату из нового заголовка
                    # и создаём новый файл.
                    buffer = []
                    currentDate = headingRX.search(line).group(1)
                    createOrgRoamFile()

if  __name__ == '__main__':
    splitOrgFile()

```

И наконец, одной из самых интересных функций, которые можно реализовать в Emacs является генерация вебсайта из коллекции заметок. Как всегда есть несколько способов собирать сайт из org файлов, я решил использовать связку из org-roam и генератора статических сайтов [Hugo]({{< relref "20230516095757-hugo.md" >}}). Собственно, удобство ведения блога из Emacs и привело к созданию этого сайта.

Посты в моём случае это просто заметки org-roam, которые содержат в блоке `:PROPERTIES:` параметр `:KIND: post`. После того как пост написан, достаточно нажать `C-c n p` и org файл будет экспортирован в Markdown, который потом используется Hugo для генерации HTML страницы сайта.

Предполагаю что настройка Emacs ещё неоднократно будет изменяться, поэтому смысла приводить здесь фрагменты кода нет. Актуальную версию можно посмотреть в моём [репозитории](https://github.com/weirdvic/.emacs.d).
