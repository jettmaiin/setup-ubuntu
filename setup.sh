#!/bin/bash

#!/bin/bash

# Проверка запуска от root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт нужно запускать от root"
   exit 1
fi

# Обновление системы и установка SSH
apt update && apt -y upgrade
apt install -y ssh

# Добавление второго пользователя
read -p "Введите имя второго пользователя: " NEWUSER
adduser --shell /bin/bash "$NEWUSER"

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
filter = ssh
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
ufw enable

# Смена паролей root и второго пользователя
echo "Смена пароля root"
passwd root
echo "Смена пароля пользователя $NEWUSER"
passwd "$NEWUSER"

# Установка базовых пакетов
apt install -y curl wget git

echo "Настройка завершена. SSH теперь работает на порту $SSHPORT. Пользователь $NEWUSER добавлен."
