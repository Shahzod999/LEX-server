#!/bin/bash

# Deployment script for production server
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 Production deployment started...${NC}"

# Проверка переменных окружения
if [ -z "$JWT_SECRET" ] || [ -z "$OPENAI_API_KEY" ] || [ -z "$MONGO_PASSWORD" ]; then
    echo -e "${RED}❌ Required environment variables not set${NC}"
    echo "Please set: JWT_SECRET, OPENAI_API_KEY, MONGO_PASSWORD"
    exit 1
fi

# Backup
echo -e "${YELLOW}💾 Creating backup...${NC}"
if docker volume ls | grep -q lex_mongodb_data; then
    docker run --rm -v lex_mongodb_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/mongodb-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
fi

# Update code
echo -e "${YELLOW}📥 Updating code...${NC}"
git pull origin main

# Deploy with nginx
echo -e "${YELLOW}🔧 Deploying with nginx...${NC}"
docker-compose --profile with-nginx up -d --build

# Health check
echo -e "${YELLOW}🏥 Performing health check...${NC}"
sleep 15

if curl -f http://localhost/health &> /dev/null; then
    echo -e "${GREEN}✅ Production deployment successful!${NC}"
    echo -e "${GREEN}🌐 Server is running at http://localhost${NC}"
else
    echo -e "${RED}❌ Health check failed!${NC}"
    docker-compose logs app
    exit 1
fi