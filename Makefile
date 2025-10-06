.PHONY: help build up down ps logs status clean smoke-test traffic traffic-normal traffic-errors traffic-mixed demo quick-start

COMPOSE=docker-compose
SHELL=cmd

help:
	@echo Comandos disponibles:
	@echo   help           - Mostrar ayuda
	@echo   build          - Construir imagenes
	@echo   up             - Iniciar servicios  
	@echo   down           - Detener servicios
	@echo   ps             - Ver estado
	@echo   logs           - Ver logs
	@echo   status         - Ver estado detallado
	@echo   clean          - Limpiar todo
	@echo   smoke-test     - Ejecutar tests de validacion
	@echo   traffic        - Generar trafico normal (60s)
	@echo   traffic-normal - Generar trafico normal (60s)
	@echo   traffic-errors - Generar solo errores (20 errores)
	@echo   traffic-mixed  - Generar trafico mixto 15%% errores (120s)
	@echo   demo           - Demo completa
	@echo   quick-start    - Setup completo

build:
	@echo Construyendo imagenes...
	@$(COMPOSE) build

up:
	@echo Iniciando servicios...
	@$(COMPOSE) up -d
	@echo Servicios iniciados

down:
	@echo Deteniendo servicios...
	@$(COMPOSE) down

ps:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f

status:
	@echo Estado de contenedores:
	@$(COMPOSE) ps

clean:
	@echo Limpiando todo...
	@$(COMPOSE) down -v --rmi all

smoke-test:
	@echo Ejecutando smoke tests...
	@powershell -File scripts\smoke-tests.ps1

traffic:
	@echo Generando trafico normal (60 segundos)...
	@powershell -File scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

traffic-normal:
	@echo Generando trafico normal (60 segundos)...
	@powershell -File scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5

traffic-errors:
	@echo Generando errores de prueba (20 errores)...
	@powershell -File scripts\traffic-generation\generate-test-errors.ps1 -ErrorCount 20 -DelaySeconds 1

traffic-mixed:
	@echo Generando trafico mixto con 15%% de errores (120 segundos)...
	@powershell -File scripts\traffic-generation\generate-mixed-traffic.ps1 -DurationSeconds 120 -ErrorRatePercent 15

demo: up
	@echo Generando trafico de prueba...
	@powershell -File scripts\traffic-generation\generate-continuous-traffic.ps1 -DurationSeconds 60 -RequestsPerSecond 5
	@echo Abriendo Grafana...
	@powershell -Command "Start-Process http://localhost:3001"

quick-start: build up
	@echo Sistema listo para usar
	@echo Accede a Grafana: http://localhost:3001
	@echo Usuario: admin / Contraseña: grupo5_devops
