# 🗄️ Локальная база данных MongoDB

## Конфигурация

Приложение настроено для использования **локальной базы данных** из папки `dataBase`.

### Структура:
```
server/
├── dataBase/          # Локальная база данных MongoDB
│   ├── *.wt           # Файлы данных WiredTiger
│   ├── journal/       # Журнал транзакций
│   └── ...
├── docker-compose.yml # MongoDB контейнер монтирует ./dataBase
└── ...
```

### Подключение:
```
mongodb://mongodb:27017/lex-ai  # Изнутри Docker
mongodb://localhost:27017/lex-ai # Снаружи Docker
```

**Без аутентификации!** - данные хранятся локально и доступны напрямую.

---

## 🚀 Запуск

### Быстрый запуск:
```bash
cd server/
./deploy-local.sh
```

### Или через Make:
```bash
make dev
```

### Вручную:
```bash
docker-compose up -d --build
```

---

## 📊 Работа с базой данных

### Подключение к MongoDB shell:
```bash
# Из Docker контейнера
make db-shell

# Или напрямую
docker-compose exec mongodb mongosh lex-ai

# Снаружи Docker (если mongosh установлен локально)
mongosh mongodb://localhost:27017/lex-ai
```

### Основные команды в mongosh:
```javascript
// Показать коллекции
show collections

// Пользователи
db.users.find().pretty()
db.users.countDocuments()

// Чаты
db.chats.find().limit(5)
db.messages.countDocuments()

// Документы
db.documents.find().pretty()

// Статистика
db.stats()
```

---

## 💾 Backup и восстановление

### Создание backup:
```bash
make backup
# Создаст backup в папке ./backups/backup-YYYYMMDD-HHMMSS/
```

### Восстановление:
```bash
make restore BACKUP_DIR=./backups/backup-20241225-150000
```

### Ручной backup:
```bash
# Копирование всей папки dataBase
cp -r dataBase dataBase_backup_$(date +%Y%m%d_%H%M%S)

# Через mongodump
docker-compose exec mongodb mongodump --db=lex-ai --out=/tmp/backup
docker cp lex-mongodb:/tmp/backup ./manual_backup/
```

---

## 🔧 Управление

### Статус контейнеров:
```bash
docker-compose ps
```

### Логи базы данных:
```bash
docker-compose logs mongodb
docker-compose logs -f mongodb  # В реальном времени
```

### Перезапуск только базы данных:
```bash
docker-compose restart mongodb
```

### Остановка всего:
```bash
docker-compose down
```

### Полная очистка (ОСТОРОЖНО!):
```bash
docker-compose down -v  # Удалит все данные!
```

---

## 📂 Локальный доступ к файлам

### Прямой доступ к данным:
```bash
# Путь к данным
ls -la ./dataBase/

# Размер базы данных
du -sh ./dataBase/

# Права доступа
ls -la dataBase/
```

### Backup файловой системы:
```bash
# Простое копирование
tar -czf database_backup_$(date +%Y%m%d).tar.gz dataBase/

# Восстановление
tar -xzf database_backup_20241225.tar.gz
```

---

## ⚠️ Важные замечания

### ✅ Преимущества локальной базы:
- Быстрый доступ к данным
- Не требует интернета
- Простое резервное копирование
- Полный контроль над данными

### ⚠️ Ограничения:
- Данные привязаны к локальной машине
- Нет автоматического масштабирования
- Требует ручного backup для безопасности

### 📋 Рекомендации:
- Регулярно создавайте backup (`make backup`)
- Следите за размером папки `dataBase/`
- Не удаляйте файлы из `dataBase/` вручную
- Останавливайте контейнеры перед перемещением проекта

---

## 🎯 Быстрые команды

```bash
# Запуск
make dev

# Подключение к БД
make db-shell

# Backup
make backup

# Логи
make logs

# Остановка
make stop

# Очистка
make clean
```

**База данных готова к работе! 🎉** 