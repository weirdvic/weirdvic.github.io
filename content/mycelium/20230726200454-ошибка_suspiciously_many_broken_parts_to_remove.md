+++
title = "Ошибка suspiciously many broken parts to remove"
date = 2023-07-26T00:00:00+03:00
lastmod = 2023-07-31
tags = ["snippets", "Clickhouse"]
draft = false
+++

При запуске сервера [Clickhouse]({{< relref "20230614122907-clickhouse.md" >}}) после аварийной перезагрузки или проблем с файловой системой может появиться большое число ошибок и сервер просто не запустится. В логах Clickhouse ошибки будут примерно такие:

```org
2023.07.26 19:26:36.621640 [ 2366 ] {} <Error> Application: DB::Exception: Suspiciously many (29) broken parts to remove.: Cannot attach table anyclass.event from metadata file /var/lib/clickhouse/store/430/430da485-c4de-4665-830d-a485c4de4665/event.sql from query ATTACH TABLE … clickhouse from path /var/lib/clickhouse/metadata/clickhouse
```

В таком случае может помочь создание файла `/var/lib/clickhouse/flags/force_restore_data` и перезапуск сервера:

```bash
sudo -u clickhouse touch /var/lib/clickhouse/flags/force_restore_data
sudo systemctl restart clickhouse-server
```
