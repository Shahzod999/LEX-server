.PHONY: build run stop logs clean dev prod

# Development with local database
dev:
	./deploy-local.sh

# Development (old method)
dev-docker:
	docker-compose up -d --build
	@echo "Development server started at http://localhost:3000"

# Production
prod:
	docker-compose --profile with-nginx up -d --build
	@echo "Production server started at http://localhost"

# Build image
build:
	docker-compose build

# Start services
run:
	docker-compose up -d

# Stop services
stop:
	docker-compose down

# View logs
logs:
	docker-compose logs -f

# Clean up
clean:
	docker-compose down -v --rmi all
	docker system prune -f

# Shell into app container
shell:
	docker-compose exec app sh

# Database shell (local database, no auth)
db-shell:
	docker-compose exec mongodb mongosh lex-ai

# Backup database (local)
backup:
	mkdir -p backups
	docker-compose exec mongodb mongodump --db=lex-ai --out=/tmp/backup
	docker cp $(shell docker-compose ps -q mongodb):/tmp/backup ./backups/backup-$(shell date +%Y%m%d-%H%M%S)

# Restore database (local)
restore:
	@echo "Usage: make restore BACKUP_DIR=./backups/backup-YYYYMMDD-HHMMSS"
	@if [ -z "$(BACKUP_DIR)" ]; then echo "Please specify BACKUP_DIR"; exit 1; fi
	docker cp $(BACKUP_DIR) $(shell docker-compose ps -q mongodb):/tmp/restore
	docker-compose exec mongodb mongorestore --db=lex-ai /tmp/restore/lex-ai