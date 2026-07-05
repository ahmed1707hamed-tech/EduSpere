.PHONY: up down build logs ps test validate clean

up:
	docker compose up --build -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps

test:
	python scripts/run_tests.py

validate:
	docker compose config
	cd frontend/student-ui && npm run build

clean:
	docker compose down --remove-orphans
