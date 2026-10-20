# Что делает bootstrap()

Порядок выполнения

```
bootstrap()
↓
check bash version
↓
find project root
↓
load config
↓
create runtime
↓
load libraries
↓
install traps
↓
check root
↓
create lock
↓
ready
```

# Переменные проекта

После bootstrap всегда существуют:

```
PROJECT_ROOT
PROJECT_VERSION
PROJECT_CONFIG
PROJECT_RUNTIME
PROJECT_LOG_DIR
PROJECT_WORK_DIR
PROJECT_LOCK_DIR
PROJECT_BACKUP_DIR
PROJECT_TEMP_DIR
```

Любой модуль может использовать их.

# Структура runtime

При запуске автоматически создается

```
runtime/
logs/
work/
locks/
tmp/
```

# Lock

Каждый процесс получает собственный lock.

Например

```
runtime/locks/backup.lock
runtime/locks/restore.lock
runtime/locks/verify.lock
```

Два backup одновременно запускаться не смогут.


# Trap

Будет зарегистрировано

```
EXIT
ERR
INT
TERM
```

Например

```
Ctrl+C
↓
очистить временные файлы
↓
снять lock
↓
закрыть лог
↓
exit
```

# Проверка Bash

Минимум ```Bash 5.0```

# Определение PROJECT_ROOT

Будет использоваться реальный путь к самому bootstrap.

Поэтому запуск возможен из любой директории.

Например

```
cd /tmp
/root/server-backup/backup.sh
```

будет работать.

# Конфигурация

По умолчанию ```configs/project.conf```

Но можно

```
PROJECT_CONFIG_FILE=/root/test.conf
backup.sh
```

# Проверка root

Eсли ```EUID != 0```, получаем

```
ERROR
This program must be run as root.
```
Без попыток использовать sudo автоматически.

# Инициализация директорий

Автоматически создаются

```
runtime/
runtime/logs
runtime/work
runtime/tmp
runtime/locks
```
через ```mkdir -p```

# Загрузка библиотек

bootstrap загружает

```
logger.sh
errors.sh
utils.sh
manifest.sh
archive.sh
crypto.sh
module.sh
```

Поэтому дальше можно писать

```
log_info
die
module_run
archive_create
```

без дополнительных source.

# Что bootstrap НЕ делает

Он никогда:
* не устанавливает пакеты
* не запускает backup
* не запускает restore
* не читает модули
* не работает с архивами
* не работает с сервисами

# Публичный API

После загрузки будут доступны
```
bootstrap
cleanup
create_runtime
load_config
load_libraries
check_root
check_bash
create_lock
remove_lock
```
Никаких других функций снаружи использовать нельзя.

# Структура файла

```
bootstrap.sh

├── constants
├── globals
├── public api
├── private api
├── trap handlers
└── bootstrap()
```
