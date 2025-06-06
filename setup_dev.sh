#!/bin/bash

set -e

echo "[+] Atualizando o sistema..."
sudo apt update && sudo apt full-upgrade -y

echo "[+] Instalando dependências principais..."
sudo apt install -y curl wget unzip zip gnupg ca-certificates lsb-release software-properties-common apt-transport-https

echo "[+] Instalando Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code
rm packages.microsoft.gpg

echo "[+] Instalando Git..."
sudo apt install -y git

echo "[+] Instalando Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "[+] Atualizando Python para a última versão disponível..."
sudo apt install -y python3 python3-pip python3-venv
sudo ln -sf /usr/bin/python3 /usr/bin/python
sudo ln -sf /usr/bin/pip3 /usr/bin/pip

echo "[+] Instalando PHP e extensões..."
sudo apt install -y php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-mysql php-tokenizer php-pgsql php-sqlite3 php-common php-gd php-soap php-intl php-readline

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

echo "[+] Instalando Node.js (LTS) e npm..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "[+] Instalando MariaDB..."
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo "[+] Instalando Laravel..."
composer global require laravel/installer
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "[+] Criando e ativando Swap permanente (8GB)..."
SWAPFILE="/swapfile"

sudo swapoff -a || true
sudo rm -f $SWAPFILE

if ! sudo fallocate -l 8G $SWAPFILE; then
    echo "[!] fallocate falhou, tentando com dd..."
    sudo dd if=/dev/zero of=$SWAPFILE bs=1M count=8192
fi

sudo chmod 600 $SWAPFILE
sudo mkswap $SWAPFILE
sudo swapon $SWAPFILE

sudo sed -i '/\/swapfile/d' /etc/fstab
echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab

swapon --show
free -h

# === Solicita usuário e email para Git ===
read -rp "Digite o usuário Git (ex: user): " GIT_USER
read -rp "Digite o email Git (ex: fsag@gmail.com): " GIT_EMAIL

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

echo "[+] Configurando Git com usuário '$GIT_USER' e email '$GIT_EMAIL'..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "[+] Gerando nova chave SSH..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    echo "[!] Chave SSH já existe em $SSH_KEY_PATH. Pulando geração."
fi

echo "[+] Iniciando ssh-agent e adicionando chave..."
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

echo "[+] Chave pública gerada:"
echo "------------------------------------------------------------"
cat "$SSH_KEY_PATH.pub"
echo "------------------------------------------------------------"

GITHUB_TOKEN="SEU_TOKEN_GITHUB_AQUI"

if [ "$GITHUB_TOKEN" != "SEU_TOKEN_GITHUB_AQUI" ]; then
    echo "[+] Enviando chave pública para GitHub via API..."
    SSH_KEY=$(cat "$SSH_KEY_PATH.pub")
    TITLE="Notebook $(hostname) - $(date +'%Y-%m-%d %H:%M:%S')"

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/user/keys \
        -d "{\"title\":\"$TITLE\", \"key\":\"$SSH_KEY\"}")

    if [ "$RESPONSE" == "201" ]; then
        echo "[✔] Chave SSH adicionada com sucesso ao GitHub."
    elif [ "$RESPONSE" == "422" ]; then
        echo "[!] Chave já existe no GitHub."
    else
        echo "[!] Falha ao adicionar chave SSH ao GitHub. Código HTTP: $RESPONSE"
    fi
else
    echo "[ℹ] GITHUB_TOKEN não configurado. Pule o envio automático da chave SSH ao GitHub."
    echo "    Para enviar automaticamente, edite o script e insira seu token GitHub na variável GITHUB_TOKEN."
fi

echo "[✔] Instalação e configuração finalizadas com sucesso!"
echo "[ℹ] Reinicie ou faça logout/login para aplicar permissões do Docker, PATH do Laravel e grupo do usuário."
