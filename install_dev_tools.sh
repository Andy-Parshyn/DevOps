#!/bin/bash

set -e

# --- 1. Docker ---
if command -v docker &>/dev/null; then
  echo "Docker вже встановлено: $(docker --version)"
else
  echo "Встановлення Docker..."
  curl -fsSL https://get.docker.com | sh
  echo "Docker встановлено: $(docker --version)"
fi

# --- 2. Docker Compose ---
if command -v docker-compose &>/dev/null; then
  echo "Docker Compose вже встановлено: $(docker-compose --version)"
else
  echo "Встановлення Docker Compose..."
  sudo apt-get install -y docker-compose
  echo "Docker Compose встановлено: $(docker-compose --version)"
fi

# --- 3. Python ---
if command -v python3 &>/dev/null; then
  echo "Python вже встановлено: $(python3 --version)"
else
  echo "Встановлення Python..."
  sudo apt-get install -y python3 python3-pip
  echo "Python встановлено: $(python3 --version)"
fi

# --- 4. Django ---
if pip3 show django &>/dev/null; then
  echo "Django вже встановлено"
else
  echo "Встановлення Django..."
  pip3 install django --break-system-packages
  echo "Django встановлено"
fi