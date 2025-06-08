# Многоэтапная сборка для оптимизации размера образа
FROM node:20-alpine AS builder

# Установка необходимых системных зависимостей для native модулей
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    musl-dev \
    giflib-dev \
    pixman-dev \
    pangomm-dev \
    libjpeg-turbo-dev \
    freetype-dev

# Создание рабочей директории
WORKDIR /app

# Копирование файлов конфигурации для установки зависимостей
COPY package*.json ./
COPY tsconfig.json ./

# Установка зависимостей
RUN npm ci --only=production && \
    npm install typescript@latest && \
    npm cache clean --force

# Копирование исходного кода
COPY src ./src

# Сборка TypeScript проекта
RUN npm run build

# Производственный образ
FROM node:20-alpine AS production

# Установка системных зависимостей для runtime
RUN apk add --no-cache \
    cairo \
    jpeg \
    pango \
    musl \
    giflib \
    pixman \
    libjpeg-turbo \
    freetype

# Создание пользователя для безопасности
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Создание рабочей директории
WORKDIR /app

# Копирование package.json для установки только production зависимостей
COPY package*.json ./

# Установка только production зависимостей
RUN npm ci --only=production && \
    npm cache clean --force

# Копирование собранного приложения из builder stage
COPY --from=builder /app/dist ./dist

# Копирование дополнительных файлов если они нужны
COPY eng.traineddata ./

# Создание директорий для данных
RUN mkdir -p uploads && \
    chown -R nodejs:nodejs /app

# Переключение на непривилегированного пользователя
USER nodejs

# Открытие порта
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Запуск приложения
CMD ["node", "dist/index.js"] 