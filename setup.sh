#!/bin/bash

# Проверка запуска от root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать от root"
   exit 1
fi

# Настройка времени
timedatectl set-timezone Europe/Moscow
apt install -y ntp
systemctl enable ntp

# Определяем доступную оперативную память
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_MB=$((RAM_KB / 1024))
RAM_GB=$((RAM_MB / 1024))

# Правило для расчета размера swap:
# - Если RAM < 2GB → SWAP = RAM x2
# - Если RAM 2-8GB → SWAP = RAM
# - Если RAM > 8GB → SWAP = 4GB
if [ $RAM_GB -lt 2 ]; then
    SWAP_SIZE=$((RAM_GB * 2))G
elif [ $RAM_GB -le 8 ]; then
    SWAP_SIZE=${RAM_GB}G
else
    SWAP_SIZE=4G
fi

# Оптимизация swappiness
SWAPPINESS=$((10 + 15 * RAM_GB / 8))
if [ $SWAPPINESS -gt 25 ]; then
    SWAPPINESS=25
fi

# Настройка swap
if [ ! -f /swapfile ]; then
    echo "Создаем swap файл ${SWAP_SIZE} (RAM: ${RAM_GB}GB)"
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    
    # Настройка swappiness
    echo "vm.swappiness=$SWAPPINESS" >> /etc/sysctl.conf
    sysctl -p
    echo "Swap настроен: размер ${SWAP_SIZE}, swappiness=$SWAPPINESS"
else
    echo "Swap файл уже существует"
fi

# Обновление системы и установка SSH
export DEBIAN_FRONTEND=noninteractive
apt update
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt install -y ssh

# Добавление второго пользователя
read -p "Введите имя второго пользователя: " NEWUSER
if id "$NEWUSER" &>/dev/null; then
    echo "Пользователь $NEWUSER уже существует, проверяем sudo права..."
    if ! groups "$NEWUSER" | grep -q '\bsudo\b'; then
        usermod -aG sudo "$NEWUSER"
        echo "Пользователь $NEWUSER добавлен в группу sudo."
    else
        echo "Пользователь $NEWUSER уже имеет sudo права."
    fi
else
    adduser --gecos "" --disabled-password "$NEWUSER"
    usermod -aG sudo "$NEWUSER"
    echo "Пользователь $NEWUSER создан и добавлен в sudo."
fi

# Изменение порта SSH и запрет root-доступа
read -p "Введите новый порт для SSH (например, 2222): " SSHPORT
sed -i "s/^#Port .*/Port $SSHPORT/" /etc/ssh/sshd_config
sed -i "s/^Port .*/Port $SSHPORT/" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
systemctl restart ssh

# Установка и настройка fail2ban и ufw
apt install -y fail2ban ufw

# Настройка fail2ban
cat >/etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = $SSHPORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 1h
bantime = 1d
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# Настройка ufw
ufw allow "$SSHPORT"/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable

# Смена паролей root и второго пользователя
echo "Смена пароля root"
passwd root
echo "Смена пароля пользователя $NEWUSER"
passwd "$NEWUSER"

# Установка базовых пакетов
apt install -y curl wget git net-tools zip unzip tmux htop 

echo "Настройка завершена. SSH теперь работает на порту $SSHPORT. Пользователь $NEWUSER добавлен."
