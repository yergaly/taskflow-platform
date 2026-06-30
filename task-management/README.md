#Проверить, работает ли сервис
launchctl list | grep taskflow

#Остановить
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.yergali.taskflow-api.plist

#Запустить
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.yergali.taskflow-api.plist

#Перезапустить (KICKSTART)
launchctl kickstart -k gui/$(id -u)/com.yergali.taskflow-api

#Перезапустить
launchctl unload ~/Library/LaunchAgents/com.yergali.taskflow-api.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.yergali.taskflow-api.plist
