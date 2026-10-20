# Каркас проекта

```
server-deploy/
│
├── backup.sh
├── restore.sh
├── install.sh
├── verify.sh
├── update.sh
│
├── VERSION
├── LICENSE
├── README.md
│
├── lib/
│   ├── bootstrap.sh
│   ├── logger.sh
│   ├── errors.sh
│   ├── utils.sh
│   ├── archive.sh
│   ├── crypto.sh
│   ├── manifest.sh
│   ├── package.sh
│   ├── service.sh
│   ├── system.sh
│   ├── network.sh
│   └── module.sh
│
├── modules/
│   ├── users/
│   ├── ssh/
│   ├── ufw/
│   ├── unbound/
│   ├── amneziawg/
│   └── mita/
│
├── configs/
│
├── templates/
│
├── docs/
│
├── tests/
│
├── runtime/
│
└── backups/
```

# API модулей

Каждый модуль будет выглядеть одинаково.

```
modules/unbound/
```


```
module.conf

install.sh

backup.sh

restore.sh

verify.sh
```

Каждый модуль реализует одинаковый интерфейс:

```
module_install
module_backup
module_restore
module_verify
```

Ядро вызывает только эти функции. Благодаря этому можно будет добавить, например, mongodb или redis, просто создав новый каталог в modules/.

Но ядро будет запускать их одинаково.

```
run_module install unbound

run_module backup unbound

run_module restore unbound
```

## module.conf

Каждый модуль описывает себя.

Например

```
NAME=unbound
VERSION=1.0
DESCRIPTION=Recursive DNS resolver

DEPENDENCIES=()

REQUIRES_NETWORK=false

ENABLED=true
```

## bootstrap.sh

Это будет сердце проекта.

Любой скрипт начинается одинаково.

```
#!/usr/bin/env bash

set -Eeuo pipefail

source bootstrap.sh
```

Bootstrap делает

```
инициализация
↓
проверка root
↓
поиск проекта
↓
создание runtime
↓
логирование
↓
trap
↓
загрузка библиотек
```

# Единая обработка ошибок

```
ERROR: Cannot restore module 'unbound'

Reason:
Configuration file not found

Action:
Restore aborted
```

# Логирование

Логирование уровня production.

```
[INFO]
[WARN]
[ERROR]
[DEBUG]
[OK]
```

цветами и одновременно записью в файл.

# Runtime

Вообще никаких временных файлов в /tmp.

Будет

```
runtime/
logs/
work/
restore/
backup/
locks/
```

После завершения всё удаляется.

# Manifest

```
{
  "backupVersion":1,
  "projectVersion":"1.0",
  "hostname":"",
  "distribution":"Ubuntu",
  "release":"24.04",
  "kernel":"",
  "arch":"amd64",
  "created":"",
  "publicIP":"",
  "modules":[
  ],
  "checksums":{
  }
}
```


# Версионность backup

Каждый архив будет содержать

```
manifest.json
```

например

```
{
    "backup_format":1,
    "project_version":"1.0.0",
    "created":"...",
    ...
}
```

# Контроль целостности

Каждый файл ``SHA-256``

После восстановления автоматически проверяется.

# Dry Run

Например, ```./restore.sh --dry-run```

ничего не меняет, только показывает

# Resume

Если восстановление оборвалось

например

```
Mita
↓
ошибка
```

следующий запуск продолжит а не начнет сначала.

# Lock

Чтобы случайно нельзя было запустить одновременно

```
backup

restore
```


# Dependency Graph

Модули сами объявляют зависимости

```
users
↓
ssh
↓
ufw
↓
unbound
↓
awg
↓
mita
```

# План реализации

## Этап 1. Core Framework (≈ 1500 строк)

Цель — получить полностью рабочий каркас.

```
server-deploy/

bootstrap.sh
logger.sh
errors.sh
utils.sh
module.sh
archive.sh
crypto.sh
manifest.sh

backup.sh
restore.sh
verify.sh

configs/project.conf
```

## Этап 2. Модульная система

```
modules/users
modules/ssh
modules/system
```

После этого будет сохраняться:
* пользователи
* home
* authorized_keys
* sudoers

## Этап 3

```
modules/ufw
modules/unbound
```

## Этап 4

```
modules/amneziawg
```

## Этап 5

```
modules/mita
```

## Этап 6

Автоматическая проверка

```
verify.sh
```

## Этап 7

Документация

