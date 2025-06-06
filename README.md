# 🚀 Script de Instalação de Ambiente de Desenvolvimento no Kali

Este script automatiza a instalação de diversas ferramentas de desenvolvimento em sistemas baseados no **Ubuntu/Kali Linux**. Ele instala PHP, Laravel, Node.js, Python, Git, Docker, VS Code, Google Chrome, Steam, PostgreSQL e ainda clona um repositório do GitHub.

## ✅ O que este script instala

- [x] **Atualizações do sistema**
- [x] Ferramentas essenciais: `curl`, `wget`, `gnupg`, etc.Ubuntu
- [x] **Visual Studio Code**
- [x] **PHP + Composer + Laravel**
- [x] **Python 3 + pip**
- [x] **Node.js (v18.x)**
- [x] **Git**
- [x] **Docker e Docker Compose**
- [x] **Steam**
- [x] **Google Chrome**
- [x] **PostgreSQL**
- [x] Clona repositório do GitHub e configura `git`

---

## ⚙️ Requisitos

- Ubuntu 20.04 ou superior
- Acesso de superusuário (`sudo`)

---

## 🧰 Como usar

1. **Clone este repositório ou salve o script**

   ```bash
   git clone https://github.com/Olavo15/ubuntu-dev-boost.git
   cd seu-repositorio

2. Dê permissão de execução ao script

    ```bash
    chmod +x setup_dev.sh
3. Execute o script
    ```bash 
    ./setup_dev.sh
4. Configure os dados do Git e o repositório para clonagem no setup.sh antes de rodar o script:
    ```bash
    echo "📁 Configurando Git e clonando repositório..."
    git config --global user.name "SeuNome"
    git config --global user.email "seuemail@gmail.com"

    Insira aqui a URL SSH do seu repositório no GitHub:
    REPO_SSH="git@github.com:SeuUsuario/seu-repositorio.git"
    git clone "$REPO_SSH" || echo "⚠️ Falha ao clonar via SSH. Verifique se a chave foi adicionada ao GitHub."

5. 📝 Configurações manuais necessárias
    ```bash
    Reinicie a sessão após a instalação para que o grupo docker seja aplicado corretamente:
        logout
## ⚠️ Observações

    O script usa set -e, ou seja, interrompe a execução se algum comando falhar.

    Após instalar o Docker, é necessário reiniciar a sessão para usar docker sem sudo.

    Laravel será instalado globalmente via Composer.
