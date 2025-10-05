# Deployment Checklist

Usa esta checklist antes de hacer push para asegurar que el CI/CD funcionará correctamente.

## Pre-Push Checklist

### 1. Código y Tests ✅

- [ ] Todos los tests unitarios pasan localmente
  ```powershell
  # Node.js
  cd demo-app
  npm test
  
  # Python
  cd anomaly-detector
  pytest test_*.py
  ```

- [ ] No hay errores de linting
  ```powershell
  # Node.js (si está configurado)
  npm run lint
  
  # Python
  flake8 . --count --select=E9,F63,F7,F82
  black --check .
  ```

- [ ] El código está formateado correctamente
  ```powershell
  # Python
  black .
  ```

### 2. Docker ✅

- [ ] Los Dockerfiles construyen sin errores
  ```powershell
  docker build -t demo-app:test ./demo-app
  docker build -t anomaly-detector:test ./anomaly-detector
  ```

- [ ] docker-compose.yml es válido
  ```powershell
  docker-compose config
  ```

- [ ] El stack completo se levanta correctamente
  ```powershell
  docker-compose up -d
  docker-compose ps
  ```

### 3. Smoke Tests ✅

- [ ] Todos los servicios responden a health checks
  ```powershell
  .\scripts\smoke-tests.ps1
  ```

- [ ] Las métricas se están recopilando en Prometheus
  ```powershell
  curl http://localhost:9090/api/v1/query?query=up
  ```

- [ ] Las trazas se están almacenando en Tempo
  ```powershell
  curl http://localhost:3200/ready
  ```

### 4. GitHub Configuration ✅

- [ ] El repositorio tiene permisos de packages habilitados
  - Settings > Actions > General > Workflow permissions
  - Seleccionar "Read and write permissions"

- [ ] Los GitHub Environments están configurados (para deployment)
  - Settings > Environments
  - Crear: `staging` y `production`
  - Para `production`: Agregar "Required reviewers"

- [ ] Los secrets necesarios están configurados (si aplica)
  - `GITHUB_TOKEN` se proporciona automáticamente
  - Otros secrets custom si los necesitas

### 5. Workflows ✅

- [ ] Los archivos de workflow tienen sintaxis YAML válida
  ```powershell
  # Si tienes yamllint instalado
  yamllint .github/workflows/*.yml
  ```

- [ ] Las rutas en los workflows coinciden con la estructura del proyecto
  - `demo-app/` existe
  - `anomaly-detector/` existe
  - `docker-compose.yml` existe

- [ ] Las variables de entorno en docker-compose están configuradas
  ```yaml
  demo-app:
    image: ${DEMO_APP_IMAGE:-demo-app:local}
  anomaly-detector:
    image: ${ANOMALY_DETECTOR_IMAGE:-anomaly-detector:local}
  ```

## Post-Push Checklist

### 1. CI Workflow ✅

- [ ] El workflow "CI - Build and Test" se ejecuta automáticamente
- [ ] Los tests de Node.js pasan
- [ ] Los tests de Python pasan
- [ ] Los reportes de cobertura se generan

### 2. Docker Build Workflow ✅

- [ ] El workflow "Docker Build and Push" se ejecuta
- [ ] Las imágenes se construyen correctamente
- [ ] Las imágenes se publican en GHCR
  - Verifica en: `https://github.com/<owner>/<repo>/pkgs/container/<service>`

### 3. Deployment Workflow ✅

- [ ] El workflow "Deploy to Staging" se ejecuta (solo en push a main)
- [ ] El deployment a staging es exitoso
- [ ] Los smoke tests pasan
- [ ] Las imágenes se etiquetan como `stable`

### 4. Production Deployment (Manual) ✅

- [ ] Revisar el deployment de staging
- [ ] Aprobar el deployment a production manualmente
- [ ] Verificar que production está funcionando
- [ ] Monitorear métricas y logs

## Validación Rápida

Ejecuta este script para validar todo de una vez:

```powershell
# Windows
.\scripts\validate-ci.ps1

# Linux/Mac
./scripts/validate-ci.sh
```

## Troubleshooting

### El CI falla en "Install dependencies"

**Problema:** `npm ci` o `pip install` falla

**Solución:**
```powershell
# Node.js: Regenerar package-lock.json
cd demo-app
rm package-lock.json
npm install
git add package-lock.json

# Python: Verificar requirements.txt
cd anomaly-detector
pip install -r requirements.txt
```

### El Docker build falla

**Problema:** Error al construir la imagen

**Solución:**
```powershell
# Construir localmente para ver el error completo
docker build --no-cache -t test ./demo-app

# Verificar que todos los archivos necesarios existen
ls demo-app/src/
ls demo-app/package.json
```

### Los smoke tests fallan

**Problema:** Los servicios no responden

**Solución:**
```powershell
# Verificar que todos los containers están corriendo
docker-compose ps

# Ver logs de servicios específicos
docker-compose logs demo-app
docker-compose logs prometheus

# Reiniciar el stack
docker-compose down
docker-compose up -d
```

### No se puede pushear a GHCR

**Problema:** Error de autenticación o permisos

**Solución:**
1. Verifica que el repositorio tiene permisos de packages
   - Settings > Actions > General > Workflow permissions
   - "Read and write permissions"

2. Verifica que el package es público o tienes acceso
   - Settings > Packages > Package settings
   - Change visibility si es necesario

3. El workflow usa `GITHUB_TOKEN` automáticamente, no necesitas configurar nada

## Referencias Útiles

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

## Contacto

Si encuentras problemas, revisa:
1. Los logs del workflow en GitHub Actions
2. Los logs de los containers con `docker-compose logs`
3. La documentación en `.github/workflows/README.md`
