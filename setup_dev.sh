#!/bin/bash

set -e  # Encerra o script se ocorrer qualquer erro

echo "🛠️ Atualizando sistema e instalando ferramentas essenciais..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  curl wget gnupg lsb-release software-properties-common \
  apt-transport-https ca-certificates xdg-utils openssh-client

# -------- Visual Studio Code --------
echo "📦 Instalando Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm microsoft.gpg
sudo apt update
sudo apt install -y code

# -------- PHP & Laravel --------
echo "🐘 Instalando PHP e Laravel..."
sudo apt install -y php php-cli php-mbstring unzip curl php-xml composer
composer global require laravel/installer

# Garante que o path do Composer esteja no PATH
if ! grep -q 'composer/vendor/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
  export PATH="$HOME/.composer/vendor/bin:$PATH"
fi

# -------- Python --------
echo "🐍 Instalando Python..."
sudo apt install -y python3 python3-pip

# -------- Node.js --------
echo "🟩 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# -------- Git --------
echo "🔧 Instalando Git..."
sudo apt install -y git

# -------- Docker --------
echo "🐳 Instalando Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

echo "⚠️ Você precisa sair e entrar novamente na sessão para usar o Docker sem sudo."

# -------- Steam --------
echo "🎮 Instalando Steam..."
sudo apt install -y steam

# -------- Google Chrome --------
echo "🌐 Instalando Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# -------- PostgreSQL --------
echo "🐘 Instalando PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# -------- Atualizando dependências --------
echo "🔁 Atualizando dependências novamente..."
sudo apt update && sudo apt upgrade -y

# -------- SSH para GitHub --------
echo "🔐 Gerando chave SSH para GitHub..."
if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
  read -p "Digite o e-mail para usar na chave SSH do GitHub: " ssh_email
  ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
else
  echo "🔑 Chave SSH já existe. Pulando geração."
fi

# Copia a chave pública para exibição
echo "🔑 Sua chave pública SSH:"
cat ~/.ssh/id_ed25519.pub

# Tenta abrir a página do GitHub para adicionar a chave
echo "🌐 Abrindo GitHub para adicionar a chave SSH..."
xdg-open https://github.com/settings/ssh/new

# -------- Configuração do Git --------
echo "📁 Configurando Git e clonando repositório..."
git config --global user.name "UserName"
git config --global user.email "Email@gmail.com"

# Clonagem via SSH (se a chave for adicionada com sucesso)
REPO_SSH="" 
git clone "$REPO_SSH" || echo "⚠️ Falha ao clonar via SSH. Verifique se a chave foi adicionada ao GitHub."

echo "✅ Tudo instalado com sucesso!"

