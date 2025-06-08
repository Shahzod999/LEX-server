#!/bin/bash

# Скрипт развертывания LEX Server с локальной базой данных
set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🗄️ LEX Server with Local Database${NC}"
echo -e "${GREEN}=================================${NC}"

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

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
        echo -e "${YELLOW}Note: MONGO_USERNAME and MONGO_PASSWORD not needed for local DB${NC}"
        exit 1
    else
        echo -e "${RED}❌ .env.example file not found${NC}"
        exit 1
    fi
fi

# Проверка локальной базы данных
echo -e "${BLUE}📂 Checking local database...${NC}"
if [ ! -d "./dataBase" ]; then
    echo -e "${YELLOW}⚠️  dataBase directory not found, creating...${NC}"
    mkdir -p dataBase
fi

# Проверка прав доступа к dataBase
if [ ! -w "./dataBase" ]; then
    echo -e "${YELLOW}⚠️  Fixing permissions for dataBase directory...${NC}"
    chmod 755 ./dataBase
fi

# Создание директории для логов
mkdir -p logs

# Остановка существующих контейнеров
echo -e "${YELLOW}📦 Stopping existing containers...${NC}"
docker-compose down

# Информация о локальной базе данных
echo -e "${BLUE}🗄️ Database Information:${NC}"
echo -e "${GREEN}  • Type: Local MongoDB${NC}"
echo -e "${GREEN}  • Path: ./dataBase${NC}"
echo -e "${GREEN}  • Connection: mongodb://mongodb:27017/lex-ai${NC}"
echo -e "${GREEN}  • No authentication required${NC}"

# Сборка и запуск
echo -e "${YELLOW}🔨 Building and starting containers with local database...${NC}"
docker-compose up -d --build

# Ожидание запуска
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 15

# Проверка статуса
echo -e "${YELLOW}🔍 Checking container status...${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""
    echo -e "${GREEN}🌐 Application URLs:${NC}"
    echo -e "${GREEN}  • Server: http://localhost:3000${NC}"
    echo -e "${GREEN}  • Health: http://localhost:3000/health${NC}"
    echo -e "${GREEN}  • WebSocket: ws://localhost:3000/ws/chat${NC}"
    echo ""
    echo -e "${GREEN}🗄️ Database Access:${NC}"
    echo -e "${GREEN}  • Local path: $(pwd)/dataBase${NC}"
    echo -e "${GREEN}  • Docker access: docker-compose exec mongodb mongosh lex-ai${NC}"
    echo -e "${GREEN}  • External access: mongosh mongodb://localhost:27017/lex-ai${NC}"
    echo ""
    echo -e "${BLUE}📊 Container Status:${NC}"
    docker-compose ps
else
    echo -e "${RED}❌ Deployment failed!${NC}"
    echo -e "${YELLOW}📋 Container logs:${NC}"
    docker-compose logs
    exit 1
fi 