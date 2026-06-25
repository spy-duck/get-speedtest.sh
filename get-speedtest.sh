#!/bin/bash

set -e

RUN_TEST=false

while getopts "s" opt; do
  case ${opt} in
    s )
      RUN_TEST=true
      ;;
    \? )
      echo "Использование: $0 [-s]"
      echo "  -s    Запустить speedtest сразу после установки с автосогласием"
      exit 1
      ;;
  esac
done

echo "=== Запуск официального скрипта настройки репозитория Ookla ==="
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

CURRENT_CODENAME=$(lsb_release -cs 2> /dev/null)
TARGET_FILE="/etc/apt/sources.list.d/ookla_speedtest-cli.list"

echo "=== Исправление репозитория для версии $CURRENT_CODENAME ==="

if [ -f "$TARGET_FILE" ]; then
    sudo sed -i "s/$CURRENT_CODENAME/jammy/g" "$TARGET_FILE"
    echo "Успешно: В файле $TARGET_FILE версия $CURRENT_CODENAME заменена на jammy."
else
    echo "Ошибка: Файл $TARGET_FILE не найден!"
    exit 1
fi

echo "=== Обновление списков пакетов и установка speedtest ==="
sudo apt update
sudo apt install -y speedtest

echo "=== Установка успешно завершена! ==="

# Проверяем, был ли передан аргумент -s
if [ "$RUN_TEST" = true ]; then
    echo "=== Запуск автоматической проверки скорости ==="
    speedtest --accept-license --accept-gdpr
fi
