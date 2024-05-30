#!/bin/bash
echo "Starting ATOL drivers installer..."

read -p "Введите номер версии (например, 1.0.0): " soft_ver

if [ -z "$soft_ver" ]; then
    echo "Необходимо ввести номер версии."
    exit 1
fi

cd ~/"$soft_ver"/installer/deb || exit 1

# Функция для установки пакетов
function install() {
    if [ ! -f "$1" ]; then
        echo "Файл $1 не найден."
        return 1
    fi
    
    # Проверяем архитектуру и устанавливаем пакет
    case "$2" in
        amd64)
            sudo dpkg -i --force-depends "$1"
            ;;
        i386)
            sudo dpkg --force-architecture -i "$1"
            ;;
        *)
            echo "Неизвестная архитектура."
            return 1
            ;;
    esac
}

# Функция для удаления пакетов
function remove() {
    if [ ! -f "$1" ]; then
        echo "Файл $1 не найден."
        return 1
    fi
    
    # Проверяем архитектуру и удаляем пакет
    case "$2" in
        amd64)
            sudo apt-get -y purge $(dpkg -l | grep "^rc  " | awk '{print $2}')
            sudo apt-get -y autoremove
            ;;
        i386)
            sudo dpkg --purge --force-architecture $(dpkg -l | grep "^rc  " | awk '{print $2}')
            sudo dpkg --remove --force-architecture $(dpkg -l | grep "^rc  " | awk '{print $2}')
            sudo dpkg --purge --force-architecture $(dpkg -l | grep "^ii  " | awk '{print $2}')
            sudo dpkg --remove --force-architecture $(dpkg -l | grep "^ii  " | awk '{print $2}')
            ;;
        *)
            echo "Неизвестная архитектура."
            return 1
            ;;
    esac
}

# Выводим меню
echo "Меню:"
echo "1. Установить AMD64"
echo "2. Установить i386"
echo "3. Удалить AMD64"
echo "4. Удалить i386"
echo "5. Выйти"

# Получаем выбор пользователя
read -p "Выберите пункт меню (1-5): " choice

case "$choice" in
    1) install "*_amd64.deb" amd64 ;;
    2) install "*_i386.deb" i386 ;;
    3) remove "*_amd64.deb" amd64 ;;
    4) remove "*_i386.deb" i386 ;;
    5) exit ;;
    *) echo "Неверный выбор." ;;
esac
