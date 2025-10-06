# 📖 Metodología y Procedimiento - Proyecto AIOps Platform

> **Guía completa paso a paso para ejecutar, probar y validar el proyecto**

---

## 📋 Índice

1. [Prerrequisitos](#1-prerrequisitos)
2. [Configuración Inicial](#2-configuración-inicial)
3. [Ejecución Local con Docker Compose](#3-ejecución-local-con-docker-compose)
4. [Validación del Sistema](#4-validación-del-sistema)
5. [Generación de Datos de Prueba](#5-generación-de-datos-de-prueba)
6. [Comandos Útiles](#6-comandos-útiles)
7. [Makefile (Automatización)](#7-makefile-automatización)
8. [Variables de Entorno](#8-variables-de-entorno)

---

## 1. Prerrequisitos

### 🖥️ Software Requerido

| Software | Versión Mínima | Comando de Verificación |
|----------|----------------|------------------------|
| **Docker** | 20.10+ | `docker --version` |
| **Docker Compose** | 2.0+ | `docker-compose --version` |
| **Git** | 2.0+ | `git --version` |

### 💻 Requisitos del Sistema

```
Mínimos:
- CPU: 2 cores
- RAM: 4 GB disponible
- Disco: 10 GB libres

Recomendados:
- CPU: 4 cores
- RAM: 8 GB disponible
- Disco: 20 GB libres
```

### 🔌 Puertos Requeridos

| Puerto | Servicio | Propósito |
|--------|----------|-----------|
| 3000 | Demo App | Aplicación de demostración |
| 3001 | Grafana | Dashboards y visualización |
| 4317 | OTel Collector | OTLP gRPC receiver |
| 4318 | OTel Collector | OTLP HTTP receiver |
| 8889 | OTel Collector | Prometheus metrics exporter |
| 9090 | Prometheus | Métricas y consultas |
| 3200 | Tempo | Trazas distribuidas |

---

## 2. Configuración Inicial

### 📥 Paso 1: Clonar el Repositorio

```bash
# Clonar el repositorio
git clone https://github.com/Sklaid/Proyecto-g5.git

# Navegar al directorio
cd Proyecto-g5

# Verificar la estructura
ls -la
```

### 🔧 Paso 2: Crear Archivo de Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```bash
# .env - Variables de entorno para el proyecto

# CONFIGURACIÓN DE IMÁGENES DOCKER
DEMO_APP_IMAGE=demo-app:local
ANOMALY_DETECTOR_IMAGE=anomaly-detector:local

# CONFIGURACIÓN DE GRAFANA
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=grupo5_devops
GF_USERS_ALLOW_SIGN_UP=false
GF_UNIFIED_ALERTING_ENABLED=true
GF_ALERTING_ENABLED=false

# CONFIGURACIÓN DE PROMETHEUS
PROMETHEUS_RETENTION_TIME=15d
PROMETHEUS_STORAGE_PATH=/prometheus

# CONFIGURACIÓN DE OPENTELEMETRY COLLECTOR
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
OTEL_SERVICE_NAME=demo-app

# CONFIGURACIÓN DE ANOMALY DETECTOR
PROMETHEUS_URL=http://prometheus:9090
CHECK_INTERVAL_MINUTES=5
HISTORICAL_DAYS=7
ANOMALY_THRESHOLD=2.5
ALERT_WEBHOOK_URL=http://grafana:3000/api/alerts
LOG_LEVEL=INFO

# CONFIGURACIÓN DE RECURSOS
PROMETHEUS_CPU_LIMIT=2.0
PROMETHEUS_MEMORY_LIMIT=4G
PROMETHEUS_CPU_RESERVATION=0.5
PROMETHEUS_MEMORY_RESERVATION=2G
```

---

## 3. Ejecución Local con Docker Compose

### 🚀 Inicio Rápido (Quick Start)

```bash
# Paso 1: Construir las imágenes Docker
docker-compose build

# Paso 2: Iniciar todos los servicios
docker-compose up -d

# Paso 3: Verificar que los servicios están corriendo
docker-compose ps

# Paso 4: Ver logs en tiempo real
docker-compose logs -f
```

### 📝 Procedimiento Detallado

#### Paso 1: Construir Imágenes Docker

```bash
# Construir todas las imágenes
docker-compose build

# O construir servicios específicos
docker-compose build demo-app
docker-compose build anomaly-detector
```

#### Paso 2: Iniciar Servicios

```bash
# Iniciar todos los servicios en modo detached (background)
docker-compose up -d
```

**Salida esperada:**
```
[+] Running 7/7
 ✔ Network observability-network    Created
 ✔ Volume prometheus-data           Created
 ✔ Volume tempo-data                Created
 ✔ Volume grafana-data              Created
 ✔ Container otel-collector         Started
 ✔ Container demo-app               Started
 ✔ Container prometheus             Started
 ✔ Container tempo                  Started
 ✔ Container grafana                Started
 ✔ Container anomaly-detector       Started
```

#### Paso 3: Verificar Estado de Servicios

```bash
# Ver estado de todos los servicios
docker-compose ps
```

**Salida esperada:**
```
NAME                IMAGE                                      STATUS
anomaly-detector    anomaly-detector:local                     Up (healthy)
demo-app            demo-app:local                             Up (healthy)
grafana             grafana/grafana:latest                     Up (healthy)
otel-collector      otel/opentelemetry-collector-contrib:latest Up (healthy)
prometheus          prom/prometheus:latest                     Up (healthy)
tempo               grafana/tempo:latest                       Up (healthy)
```

#### Paso 4: Esperar a que los Servicios Estén Listos

```bash
# Esperar 30 segundos para que todos los servicios inicien
echo "Esperando a que los servicios estén listos..."
sleep 30

# Verificar health checks
docker-compose ps | grep "healthy"
```

---

## 4. Validación del Sistema

### ✅ Paso 1: Ejecutar Smoke Tests

```bash
# Windows PowerShell
.\scripts\smoke-tests.ps1

# Linux/Mac
chmod +x scripts/smoke-tests.sh
./scripts/smoke-tests.sh
```

### 🔍 Paso 2: Verificar Endpoints Manualmente

```bash
# 1. Demo App Health
curl http://localhost:3000/health

# 2. Demo App Ready
curl http://localhost:3000/ready

# 3. Prometheus Health
curl http://localhost:9090/-/healthy

# 4. Grafana Health
curl http://localhost:3001/api/health

# 5. Tempo Ready
curl http://localhost:3200/ready
```

### 📊 Paso 3: Acceder a las Interfaces Web

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **Grafana** | http://localhost:3001 | admin / grupo5_devops |
| **Prometheus** | http://localhost:9090 | - |
| **Demo App** | http://localhost:3000 | - |

---

## 5. Generación de Datos de Prueba

### 🎯 Opción 1: Tráfico Continuo

```powershell
# Windows PowerShell
.\scripts\traffic-generation\generate-continuous-traffic.ps1 `
    -DurationSeconds 60 `
    -RequestsPerSecond 5
```

```bash
# Linux/Mac
for i in {1..60}; do
    curl -s http://localhost:3000/api/users > /dev/null
    curl -s http://localhost:3000/api/products > /dev/null
    sleep 1
done
```

### 🎯 Opción 2: Tráfico Mixto (Normal + Errores)

```powershell
# Windows PowerShell
.\scripts\traffic-generation\generate-mixed-traffic.ps1 `
    -DurationSeconds 120 `
    -ErrorRatePercent 15
```

### 🎯 Opción 3: Comandos cURL Manuales

```bash
# Endpoints disponibles
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products
curl http://localhost:3000/api/orders

# Generar error 404
curl http://localhost:3000/api/nonexistent

# Generar error 500
curl http://localhost:3000/api/error
```

---

## 6. Comandos Útiles

### 🐳 Docker Compose

```bash
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Detener y eliminar contenedores + volúmenes
docker-compose down -v

# Reiniciar un servicio específico
docker-compose restart demo-app

# Ver logs
docker-compose logs -f
docker-compose logs -f demo-app

# Ver estado
docker-compose ps

# Reconstruir imágenes
docker-compose build
docker-compose build --no-cache
```

### 📊 Prometheus

```bash
# Consultar métricas
curl "http://localhost:9090/api/v1/query?query=up"

# Consultar métricas de la demo app
curl "http://localhost:9090/api/v1/query?query=http_server_requests_total"

# Ver targets
curl "http://localhost:9090/api/v1/targets"
```

### 📈 Grafana

```bash
# Health check
curl http://localhost:3001/api/health

# Listar datasources
curl -u admin:grupo5_devops http://localhost:3001/api/datasources

# Listar dashboards
curl -u admin:grupo5_devops http://localhost:3001/api/search?type=dash-db
```

---

## 7. Makefile (Automatización)

Crea un archivo `Makefile` en la raíz del proyecto:

```makefile
# Makefile para Proyecto AIOps Platform

.PHONY: help build up down restart logs ps clean test smoke-test traffic

# Variables
COMPOSE=docker-compose
SCRIPTS_DIR=scripts

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Construir todas las imágenes Docker
	$(COMPOSE) build

up: ## Iniciar todos los servicios
	$(COMPOSE) up -d
	@echo "Esperando a que los servicios estén listos..."
	@sleep 30
	@$(COMPOSE) ps

down: ## Detener y eliminar todos los contenedores
	$(COMPOSE) down

down-volumes: ## Detener y eliminar contenedores + volúmenes
	$(COMPOSE) down -v

restart: ## Reiniciar todos los servicios
	$(COMPOSE) restart

logs: ## Ver logs de todos los servicios
	$(COMPOSE) logs -f

ps: ## Ver estado de los servicios
	$(COMPOSE) ps

clean: ## Limpiar todo (contenedores, volúmenes, imágenes)
	$(COMPOSE) down -v --rmi all
	docker system prune -f

smoke-test: ## Ejecutar smoke tests
	@echo "Ejecutando smoke tests..."
	@bash $(SCRIPTS_DIR)/smoke-tests.sh

traffic: ## Generar tráfico de prueba (60 segundos)
	@echo "Generando tráfico de prueba..."
	@for i in {1..60}; do \
		curl -s http://localhost:3000/api/users > /dev/null; \
		curl -s http://localhost:3000/api/products > /dev/null; \
		sleep 1; \
	done
	@echo "Tráfico generado completado"

demo: up ## Iniciar sistema y generar demo completa
	@echo "Esperando a que los servicios estén listos..."
	@sleep 30
	@echo "Generando tráfico de prueba..."
	@make traffic
	@echo "Abriendo dashboards..."
	@open http://localhost:3001 || xdg-open http://localhost:3001 || start http://localhost:3001

install: ## Instalar dependencias (Node.js y Python)
	@echo "Instalando dependencias de Node.js..."
	cd demo-app && npm install
	@echo "Instalando dependencias de Python..."
	cd anomaly-detector && pip install -r requirements.txt

test-node: ## Ejecutar tests de Node.js
	cd demo-app && npm test

test-python: ## Ejecutar tests de Python
	cd anomaly-detector && python -m pytest

test: test-node test-python ## Ejecutar todos los tests

dev: ## Modo desarrollo (logs visibles)
	$(COMPOSE) up

status: ## Ver estado detallado del sistema
	@echo "=== Estado de Contenedores ==="
	@$(COMPOSE) ps
	@echo ""
	@echo "=== Health Checks ==="
	@curl -s http://localhost:3000/health | jq . || echo "Demo App: No disponible"
	@curl -s http://localhost:9090/-/healthy || echo "Prometheus: No disponible"
	@curl -s http://localhost:3001/api/health | jq . || echo "Grafana: No disponible"
	@curl -s http://localhost:3200/ready || echo "Tempo: No disponible"
```

### 📝 Uso del Makefile

```bash
# Ver ayuda
make help

# Construir imágenes
make build

# Iniciar servicios
make up

# Ver logs
make logs

# Ejecutar smoke tests
make smoke-test

# Generar tráfico
make traffic

# Demo completa
make demo

# Detener servicios
make down

# Limpiar todo
make clean
```

---

## 8. Variables de Entorno

### 📄 Archivo .env.example

Crea un archivo `.env.example` para documentación:

```bash
# .env.example - Plantilla de variables de entorno

# ============================================
# CONFIGURACIÓN DE IMÁGENES DOCKER
# ============================================
DEMO_APP_IMAGE=demo-app:local
ANOMALY_DETECTOR_IMAGE=anomaly-detector:local

# ============================================
# CONFIGURACIÓN DE GRAFANA
# ============================================
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=your_password_here
GF_USERS_ALLOW_SIGN_UP=false
GF_UNIFIED_ALERTING_ENABLED=true
GF_ALERTING_ENABLED=false

# ============================================
# CONFIGURACIÓN DE PROMETHEUS
# ============================================
PROMETHEUS_RETENTION_TIME=15d
PROMETHEUS_STORAGE_PATH=/prometheus

# ============================================
# CONFIGURACIÓN DE OPENTELEMETRY COLLECTOR
# ============================================
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
OTEL_SERVICE_NAME=demo-app

# ============================================
# CONFIGURACIÓN DE ANOMALY DETECTOR
# ============================================
PROMETHEUS_URL=http://prometheus:9090
CHECK_INTERVAL_MINUTES=5
HISTORICAL_DAYS=7
ANOMALY_THRESHOLD=2.5
ALERT_WEBHOOK_URL=http://grafana:3000/api/alerts
LOG_LEVEL=INFO

# ============================================
# CONFIGURACIÓN DE RECURSOS
# ============================================
PROMETHEUS_CPU_LIMIT=2.0
PROMETHEUS_MEMORY_LIMIT=4G
PROMETHEUS_CPU_RESERVATION=0.5
PROMETHEUS_MEMORY_RESERVATION=2G
```

### 📋 Descripción de Variables

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `DEMO_APP_IMAGE` | Nombre de la imagen Docker de la demo app | `demo-app:local` |
| `ANOMALY_DETECTOR_IMAGE` | Nombre de la imagen del detector de anomalías | `anomaly-detector:local` |
| `GF_SECURITY_ADMIN_USER` | Usuario admin de Grafana | `admin` |
| `GF_SECURITY_ADMIN_PASSWORD` | Contraseña admin de Grafana | `grupo5_devops` |
| `PROMETHEUS_RETENTION_TIME` | Tiempo de retención de métricas | `15d` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Endpoint del OTel Collector | `http://otel-collector:4318` |
| `CHECK_INTERVAL_MINUTES` | Intervalo de detección de anomalías | `5` |
| `HISTORICAL_DAYS` | Días de datos históricos para ML | `7` |
| `ANOMALY_THRESHOLD` | Umbral de detección (desviaciones estándar) | `2.5` |
| `LOG_LEVEL` | Nivel de logging | `INFO` |

---

## 📝 Resumen de Comandos Rápidos

```bash
# Setup inicial
git clone https://github.com/Sklaid/Proyecto-g5.git
cd Proyecto-g5
cp .env.example .env

# Iniciar sistema
docker-compose build
docker-compose up -d

# Validar
./scripts/smoke-tests.sh

# Generar tráfico
curl http://localhost:3000/api/users
curl http://localhost:3000/api/products

# Acceder a Grafana
open http://localhost:3001
# Login: admin / grupo5_devops

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

---

**Fecha de Documentación:** Octubre 2025  
**Versión:** 1.0.0  
**Autor:** DevOps Team
