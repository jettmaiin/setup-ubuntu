#!/bin/bash

# Проверка запуска от root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать от root"
   exit 1
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
apt install -y curl wget git net-tools

echo "Настройка завершена. SSH теперь работает на порту $SSHPORT. Пользователь $NEWUSER добавлен."
