#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting LEX Server deployment...${NC}"

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi

# Проверка .env файла
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from .env.example...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}📝 Please edit .env file with your actual values${NC}"
        exit 1
    else
        echo -e "${RED}❌ .env.example file not found${NC}"
        exit 1
    fi
fi

# Создание директории для логов
mkdir -p logs

# Остановка существующих контейнеров
echo -e "${YELLOW}📦 Stopping existing containers...${NC}"
docker-compose down

# Сборка и запуск
echo -e "${YELLOW}🔨 Building and starting containers...${NC}"
docker-compose up -d --build

# Проверка статуса
echo -e "${YELLOW}🔍 Checking container status...${NC}"
sleep 10

if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🌐 Server is running at http://localhost:3000${NC}"
    echo -e "${GREEN}📊 Health check: http://localhost:3000/health${NC}"
else
    echo -e "${RED}❌ Deployment failed!${NC}"
    echo -e "${YELLOW}📋 Container logs:${NC}"
    docker-compose logs
    exit 1
fi