# 🏗️ Общая архитектура

    Проект построен на Node.js + Express + TypeScript и следует архитектуре MVC (Model-View-Controller) c дополнительными слоями middleware и утилит.

# 📁 Структура директорий

    Основные компоненты:
    src/ - основной исходный код
    dataBase/ - локальная MongoDB база данных
    uploads/ - файлы пользователей
    scripts/ - тестовые и служебные скрипты
    node_modules/ - зависимости

src/
├── index.ts # Точка входа приложения
├── config/ # Конфигурации
│ ├── db.ts # Подключение к MongoDB
│ └── websocketConfig.ts # Настройки WebSocket
├── models/ # Модели данных (Mongoose)
│ ├── User.ts # Модель пользователя
│ ├── Chat.ts # Модель чата и сообщений
│ ├── Document.ts # Модель документов
│ └── Reminder.ts # Модель напоминаний
├── controllers/ # Бизнес-логика
│ ├── usersController.ts
│ ├── chatController.ts
│ ├── documentController.ts
│ ├── websocketController.ts # WebSocket сервер
│ └── ...
├── routes/ # API маршруты
│ ├── usersRoutes.ts
│ ├── chatRoutes.ts
│ ├── documentRoutes.ts
│ └── ...
├── middleware/ # Промежуточное ПО
│ ├── userMiddleware.ts # Аутентификация/авторизация
│ ├── uploadMiddleware.ts # Загрузка файлов
│ └── asyncHandler.ts # Обработка асинхронных ошибок
├── types/ # TypeScript типы
├── utils/ # Вспомогательные функции

# 🗄️ База данных

MongoDB + Mongoose ODM:
User - пользователи (имя, email, пароль, профиль)
Chat - чаты с ссылками на сообщения
Message - отдельные сообщения чата
Document - загруженные документы с метаданными
Reminder - напоминания пользователей

# 🔧 Основные технологии

    Backend Stack:
    Node.js + Express - веб-сервер
    TypeScript - типизированный JavaScript
    MongoDB + Mongoose - база данных
    WebSocket (ws) - реалтайм коммуникация
    JWT - аутентификация
    bcrypt - хеширование паролей

    AI/ML интеграции:
    OpenAI API - GPT-4 для анализа документов и чата
    Tesseract.js - OCR для извлечения текста из изображений
    pdf-parse - парсинг PDF файлов
    mammoth - работа с DOCX файлами

    Файловая система:
    multer - загрузка файлов
    fs - работа с файловой системой

# 🔄 Архитектурные паттерны

1. REST API Architecture
   GET/POST/PUT/DELETE /api/users # Пользователи
   GET/POST/PUT/DELETE /api/chats # Чаты
   GET/POST/PUT/DELETE /api/documents # Документы
2. WebSocket Real-time Communication
   // Поддержка множественных чатов
   interface WebSocketMessage {
   type: "message" | "subscribe_chat" | "create_chat"
   data: { message?, chatId?, token? }
   }

3. Middleware Pipeline
   // Аутентификация → авторизация → контроллер
   authenticate → isOwnerOrAdmin → controller

4. File Processing Pipeline
   Upload → Extract Text → AI Analysis → Save to DB
   (PDF/DOCX/Images → OCR/Parse → OpenAI → MongoDB)

# ⚡ Ключевые особенности

1. Multi-Chat WebSocket Server
   Поддержка множественных активных чатов на пользователя
   Rate limiting и управление соединениями
   Автоматическая очистка неактивных соединений
   Broadcast сообщений между участниками
2. Document Intelligence
   Автоматическое извлечение текста из различных форматов
   AI-анализ документов с извлечением метаданных
   OCR для изображений
   Структурированное хранение результатов
3. Authentication & Security
   JWT токены с ролевой моделью (user/admin)
   Bcrypt хеширование паролей
   CORS настройки
   Middleware для проверки прав доступа
4. File Management
   Персональные директории для каждого пользователя
   Поддержка множественной загрузки файлов
   Автоматическая категоризация по типам

# 🔧 Конфигурация и развертывание

    Scripts (package.json):

    {
        "server": "nodemon src/index.ts",    # Разработка
        "build": "tsc",                      # Сборка
        "start": "node dist/index.js",       # Продакшн
        "db": "mongod --dbpath=./dataBase",  # Локальная БД
        "dev": "concurrently server + db"    # Полный стек
    }

# Environment Configuration:

    Переменные окружения для API ключей
    Настройки WebSocket лимитов
    Конфигурация базы данных

# 📊 Мониторинг и тестирование

    Встроенные инструменты:

    WebSocket статистика (/api/websocket/stats)
    Скрипты нагрузочного тестирования
    Тестирование множественных соединений
