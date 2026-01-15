#!/usr/bin/env bash
set -euo pipefail

# ==============================
# VARIABLES CONFIGURABLES
# ==============================
PLACEHOLDER="joker"                   # Nombre simbólico del host
HOST_BASE_PATH="/home/docker"         # Carpeta base de todos los VPS

DOCKERVPS="darkbrickhust"             # Identificador del VPS
DARKBRICKHUST_USER="darkbrickhust"    # Usuario dedicado
DARKBRICKHUST_GROUP="docker"          # Grupo para docker
DARKBRICKHUST_UID="1500"
DARKBRICKHUST_GID="1500"

DARKBRICKHUST_PATH="${HOST_BASE_PATH}/${DOCKERVPS}"
DARKBRICKHUST_LOGS="${DARKBRICKHUST_PATH}/logs"
DARKBRICKHUST_CONFIG="${DARKBRICKHUST_PATH}/config"
DARKBRICKHUST_DATA="${DARKBRICKHUST_PATH}/data"

# ==============================
# 1️⃣ Creación del usuario y grupo
# ==============================
echo "Creando grupo y usuario para $DOCKERVPS..."
if ! getent group $DARKBRICKHUST_GROUP >/dev/null; then
    sudo groupadd -g $DARKBRICKHUST_GID $DARKBRICKHUST_GROUP
fi

if ! id -u $DARKBRICKHUST_USER >/dev/null 2>&1; then
    sudo useradd -m -u $DARKBRICKHUST_UID -g $DARKBRICKHUST_GROUP -s /bin/bash $DARKBRICKHUST_USER
fi

echo "Usuario y grupo creados correctamente."

# ==============================
# 2️⃣ Preparación de los directorios
# ==============================
echo "Creando estructura de directorios para $DOCKERVPS..."
sudo mkdir -p "$DARKBRICKHUST_LOGS" "$DARKBRICKHUST_CONFIG" "$DARKBRICKHUST_DATA"
sudo chown -R $DARKBRICKHUST_USER:$DARKBRICKHUST_GROUP "$DARKBRICKHUST_PATH"
sudo chmod -R 750 "$DARKBRICKHUST_PATH"

echo "Directorios creados y permisos configurados."

# ==============================
# 3️⃣ Instalación de Docker
# ==============================
echo "Instalando Docker en el host..."
if ! command -v docker >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker ya está instalado."
fi

# Añadir usuario al grupo docker para poder usar Docker sin sudo
sudo usermod -aG docker $DARKBRICKHUST_USER

echo "Docker instalado y usuario $DARKBRICKHUST_USER añadido al grupo docker."

echo "✅ Preparación del host completada."
