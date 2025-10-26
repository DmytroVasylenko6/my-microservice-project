#!/bin/bash

# ============================
#  install_dev_tools.sh
#  Bash-скрипт для автоматичного встановлення:
#  - Docker
#  - Docker Compose
#  - Python 3.9+
#  - Django
# ============================

set -e  # зупиняти виконання при помилці

echo "=== Перевірка та встановлення необхідних інструментів ==="

# ----------------------------
# 1. Docker
# ----------------------------
if ! command -v docker &> /dev/null; then
    echo "[1/4] Встановлюємо Docker..."
    sudo apt update -y
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "✅ Docker встановлено."
else
    echo "✅ Docker уже встановлений."
fi

# ----------------------------
# 2. Docker Compose
# ----------------------------
if ! command -v docker-compose &> /dev/null; then
    echo "[2/4] Встановлюємо Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose встановлено."
else
    echo "✅ Docker Compose уже встановлений."
fi

# ----------------------------
# 3. Python 3.9+
# ----------------------------
if ! command -v python3 &> /dev/null; then
    echo "[3/4] Встановлюємо Python 3..."
    sudo apt update -y
    sudo apt install -y python3 python3-pip
    echo "✅ Python 3 встановлено."
else
    PY_VER=$(python3 -V | awk '{print $2}')
    echo "✅ Python уже встановлений (версія $PY_VER)."
fi

# ----------------------------
# 4. Django
# ----------------------------
if ! python3 -m django --version &> /dev/null; then
    echo "[4/4] Встановлюємо Django..."
    pip3 install --upgrade pip
    pip3 install django
    echo "✅ Django встановлено."
else
    DJANGO_VER=$(python3 -m django --version)
    echo "✅ Django уже встановлений (версія $DJANGO_VER)."
fi

echo "🎉 Усі інструменти встановлені або вже були присутні в системі."
