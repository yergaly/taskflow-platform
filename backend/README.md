# TaskFlow Backend Server (Mac Studio)

## Общая информация

Этот Mac Studio используется как **домашний сервер** для проекта TaskFlow.

Сервер автоматически запускает FastAPI после загрузки macOS и работает круглосуточно.

Используется:

- macOS
- Python + FastAPI
- Uvicorn
- LaunchDaemon
- Tailscale
- GitHub

---

# Структура проекта

```
taskflow-platform/
│
├── backend/
│   ├── main.py
│   ├── auth.py
│   ├── models.py
│   ├── google_sheet.py
│   ├── requirements.txt
│   ├── .venv/
│   └── management-xxxxxxxx.json
│
└── taskflow/
```

---

# Где находится LaunchDaemon

```
/Library/LaunchDaemons/com.yergali.taskflow-api.plist
```

Проверить:

```bash
ls /Library/LaunchDaemons
```

---

# Проверить статус сервера

```bash
sudo launchctl print system/com.yergali.taskflow-api
```

или

```bash
launchctl list | grep taskflow
```

Если сервер работает, увидите что-то вроде

```
12345    0    com.yergali.taskflow-api
```

---

# Запустить сервер

Если сервис выгружен:

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.yergali.taskflow-api.plist
```

---

# Перезапустить сервер

После изменения кода или настроек:

```bash
sudo launchctl kickstart -k system/com.yergali.taskflow-api
```

---

# Полностью остановить сервер

```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.yergali.taskflow-api.plist
```

Проверить:

```bash
launchctl list | grep taskflow
```

Если ничего не выводит — сервер остановлен.

---

# Снова запустить после остановки

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.yergali.taskflow-api.plist
```

---

# Проверить, слушает ли FastAPI порт

```bash
lsof -i :8000
```

или

```bash
netstat -an | grep 8000
```

---

# Проверить API

Локально:

```bash
curl http://127.0.0.1:8000
```

или

```
http://localhost:8000/docs
```

Через Tailscale:

```
http://<tailscale-ip>:8000/docs
```

---

# Логи

Просмотреть последние сообщения:

```bash
tail -f /var/log/taskflow-api.log
```

Ошибки:

```bash
tail -f /var/log/taskflow-api-error.log
```

Очистить лог:

```bash
sudo truncate -s 0 /var/log/taskflow-api.log
sudo truncate -s 0 /var/log/taskflow-api-error.log
```

---

# Изменение LaunchDaemon

Редактировать:

```bash
sudo nano /Library/LaunchDaemons/com.yergali.taskflow-api.plist
```

После изменения обязательно:

```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.yergali.taskflow-api.plist

sudo launchctl bootstrap system /Library/LaunchDaemons/com.yergali.taskflow-api.plist
```

или

```bash
sudo launchctl kickstart -k system/com.yergali.taskflow-api
```

---

# Обновление проекта через GitHub

Перейти в проект:

```bash
cd /Volumes/Projects/taskflow-platform
```

Получить изменения:

```bash
git pull --rebase
```

После обновления перезапустить FastAPI:

```bash
sudo launchctl kickstart -k system/com.yergali.taskflow-api
```

---

# Если изменился requirements.txt

Активировать окружение:

```bash
cd backend

source .venv/bin/activate
```

Обновить зависимости:

```bash
pip install -r requirements.txt
```

Перезапустить сервис:

```bash
sudo launchctl kickstart -k system/com.yergali.taskflow-api
```

---

# Если удалилось виртуальное окружение

Создать заново:

```bash
python3 -m venv .venv

source .venv/bin/activate

pip install -r requirements.txt
```

---

# Проверить настройки питания

```bash
pmset -g
```

Должно быть примерно:

```
sleep 0
disksleep 0
displaysleep 0
autorestart 1
tcpkeepalive 1
womp 1
```

---

# Изменить настройки питания

Никогда не засыпать:

```bash
sudo pmset -a sleep 0
```

Не выключать экран:

```bash
sudo pmset -a displaysleep 0
```

Не останавливать диски:

```bash
sudo pmset -a disksleep 0
```

Автоматически включаться после восстановления питания:

```bash
sudo pmset -a autorestart 1
```

---

# Проверить Tailscale

Статус:

```bash
tailscale status
```

IP:

```bash
tailscale ip
```

Funnel:

```bash
tailscale funnel 8000
Available on the internet:

https://mac-studio.tailbc593.ts.net/
|-- proxy http://127.0.0.1:8000
```

---

# Проверить Python

```bash
python --version
```

или

```bash
python3 --version
```

---

# Проверить Uvicorn

```bash
which uvicorn
```

---

# Проверить виртуальное окружение

Активировать:

```bash
source .venv/bin/activate
```

Выход:

```bash
deactivate
```

---

# Если FastAPI не запускается

Проверить:

```
1. launchctl print
2. tail -f error.log
3. python main.py
4. requirements.txt
5. management-xxxxxxxx.json
```

---

# GitHub

Получить изменения:

```bash
git pull --rebase
```

Отправить изменения:

```bash
git add .

git commit -m "Описание изменений"

git push
```

---

# Проверить процессы

Uvicorn:

```bash
ps aux | grep uvicorn
```

Python:

```bash
ps aux | grep python
```

---

# Перезагрузка Mac

```bash
sudo reboot
```

После загрузки сервер должен стартовать автоматически.

Проверить:

```bash
launchctl list | grep taskflow
```

или

```bash
sudo launchctl print system/com.yergali.taskflow-api
```

---

# Полезные команды

Показать текущую папку

```bash
pwd
```

Список файлов

```bash
ls
```

Скрытые файлы

```bash
ls -la
```

Размер папок

```bash
du -sh *
```

Свободное место

```bash
df -h
```

---

# Проверочный чек-лист

После любой перезагрузки:

- [ ] Mac включился автоматически
- [ ] Tailscale работает
- [ ] FastAPI запущен
- [ ] `/docs` открывается
- [ ] Git работает
- [ ] Логи записываются
- [ ] `launchctl print system/com.yergali.taskflow-api` показывает `state = running`

Если все пункты отмечены — сервер работает корректно.
