#!/bin/bash

set -e

echo "[+] Atualizando o sistema..."
sudo apt update && sudo apt full-upgrade -y

echo "[+] Instalando dependências essenciais..."
sudo apt install -y curl wget unzip zip gnupg ca-certificates lsb-release software-properties-common apt-transport-https

# Visual Studio Code
echo "[+] Instalando Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code
rm packages.microsoft.gpg

# Google Chrome
echo "[+] Instalando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo apt install -y /tmp/chrome.deb || sudo apt-get -f install -y
rm /tmp/chrome.deb

# Steam
echo "[+] Instalando Steam..."
sudo apt install -y steam

# Git
echo "[+] Instalando Git..."
sudo apt install -y git

# Docker e Docker Compose
echo "[+] Instalando Docker e Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Python 3 e pip
echo "[+] Instalando Python 3 e pip..."
sudo apt install -y python3 python3-pip python3-venv
sudo ln -sf /usr/bin/python3 /usr/bin/python
sudo ln -sf /usr/bin/pip3 /usr/bin/pip

# PHP + extensões
echo "[+] Instalando PHP e extensões..."
sudo apt install -y php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-mysql php-tokenizer php-pgsql php-sqlite3 php-common php-gd php-soap php-intl php-readline

# Composer
echo "[+] Instalando Composer..."
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo 'ERRO: Assinatura do Composer inválida!'
    rm composer-setup.php
    exit 1
fi
php composer-setup.php --quiet
sudo mv composer.phar /usr/local/bin/composer
rm composer-setup.php

# Laravel
echo "[+] Instalando Laravel..."
composer global require laravel/installer
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Node.js LTS (18.x)
echo "[+] Instalando Node.js (LTS) e npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# PostgreSQL
echo "[+] Instalando PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Swap 8GB
echo "[+] Configurando Swap permanente (8GB)..."
SWAPFILE="/swapfile"
sudo swapoff -a || true
sudo rm -f $SWAPFILE
if ! sudo fallocate -l 8G $SWAPFILE; then
    echo "[!] fallocate falhou, criando swap com dd..."
    sudo dd if=/dev/zero of=$SWAPFILE bs=1M count=8192
fi
sudo chmod 600 $SWAPFILE
sudo mkswap $SWAPFILE
sudo swapon $SWAPFILE
sudo sed -i '/\/swapfile/d' /etc/fstab
echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
swapon --show
free -h

# Configuração Git user + email
read -rp "Digite o usuário Git (ex: user): " GIT_USER
read -rp "Digite o email Git (ex: teste@gmail.com): " GIT_EMAIL

echo "[+] Configurando Git..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# Gerar chave SSH se não existir
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "[+] Gerando chave SSH..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    echo "[!] Chave SSH já existe, pulando geração."
fi

eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

echo "[+] Sua chave pública SSH (adicione ao GitHub):"
echo "------------------------------------------------------------"
cat "$SSH_KEY_PATH.pub"
echo "------------------------------------------------------------"

# Clonar repositório (opcional)
read -rp "Quer clonar um repositório Git agora? (URL ou vazio para pular): " REPO_URL
if [[ -n "$REPO_URL" ]]; then
    git clone "$REPO_URL"
fi

echo "[✔] Setup finalizado! Reinicie ou faça logout/login para aplicar permissões Docker, PATH Laravel e grupos do usuário."
