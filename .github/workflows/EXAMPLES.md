# CI/CD Pipeline - Ejemplos Prácticos

Ejemplos reales de cómo usar el pipeline en diferentes escenarios.

---

## Escenario 1: Desarrollo de Nueva Feature

### Situación
Estás desarrollando una nueva feature en una rama separada.

### Pasos

```bash
# 1. Crear feature branch
git checkout -b feature/add-new-endpoint

# 2. Hacer cambios en el código
# ... editar archivos ...

# 3. Validar localmente ANTES de commit
cd demo-app
npm test
cd ..

# 4. Ejecutar validación completa
.\scripts\validate-ci.ps1

# 5. Si todo pasa, hacer commit
git add .
git commit -m "feat: add new endpoint for user analytics"

# 6. Push a feature branch
git push origin feature/add-new-endpoint
```

### Qué sucede en GitHub
- ✅ Se ejecuta **CI Workflow** (tests y linters)
- ✅ Se ejecuta **Docker Build** (solo build, no push)
- ❌ NO se despliega (solo en main)

### Resultado esperado
```
GitHub Actions:
✓ CI - Build and Test (2m 30s)
✓ Docker Build and Push (3m 15s) - Build only, no push
```

---

## Escenario 2: Pull Request a Main

### Situación
Tu feature está lista y quieres hacer merge a main.

### Pasos

```bash
# 1. Asegurarte de que tu branch está actualizado
git checkout feature/add-new-endpoint
git pull origin main
git push origin feature/add-new-endpoint

# 2. Crear Pull Request en GitHub
# GitHub > Pull Requests > New Pull Request
# Base: main <- Compare: feature/add-new-endpoint

# 3. Esperar que el CI pase
# GitHub ejecutará automáticamente:
# - CI tests
# - Docker build (sin push)

# 4. Revisar el código
# - Code review por el equipo
# - Verificar que todos los checks pasan

# 5. Merge PR
# Click "Merge pull request"
```

### Qué sucede en GitHub
- ✅ CI tests se ejecutan en el PR
- ✅ Docker build se ejecuta (validación)
- ✅ Después del merge, se ejecuta el pipeline completo
- ✅ Deployment automático a staging

### Resultado esperado
```
Pull Request:
✓ CI - Build and Test (2m 30s)
✓ Docker Build and Push (3m 15s)

After Merge:
✓ CI - Build and Test (2m 30s)
✓ Docker Build and Push (3m 15s) - Push to GHCR
✓ Deploy to Staging (4m 00s)
  ✓ Health checks passed
  ✓ Metrics validation passed
  ✓ Traces validation passed
  ✓ Tagged as stable
```

---

## Escenario 3: Hotfix en Producción

### Situación
Hay un bug crítico en producción que necesita arreglarse inmediatamente.

### Pasos

```bash
# 1. Crear hotfix branch desde main
git checkout main
git pull origin main
git checkout -b hotfix/fix-critical-bug

# 2. Hacer el fix
# ... editar archivos ...

# 3. Validar localmente
.\scripts\validate-ci.ps1

# 4. Commit y push
git add .
git commit -m "fix: resolve critical bug in user authentication"
git push origin hotfix/fix-critical-bug

# 5. Crear PR y merge rápidamente
# (Después de code review expedito)

# 6. Verificar staging
# Esperar que staging se despliegue automáticamente
# Verificar que el fix funciona

# 7. Aprobar deployment a production
# GitHub > Actions > Deploy to Staging
# Click "Review deployments" > Approve
```

### Timeline
```
00:00 - Push hotfix branch
00:02 - CI tests complete
00:05 - Docker build complete
00:06 - Merge to main
00:08 - CI tests complete (main)
00:11 - Docker build complete (main)
00:12 - Deploy to staging starts
00:16 - Staging deployment complete
00:17 - Manual approval for production
00:20 - Production deployment complete
```

### Resultado esperado
```
✓ Hotfix deployed to production in ~20 minutes
✓ All smoke tests passed
✓ No downtime
```

---

## Escenario 4: Rollback Automático

### Situación
Un deployment a staging falla los smoke tests.

### Qué sucede automáticamente

```
1. Deploy to Staging starts
   ├─ Pull latest images
   ├─ Deploy with docker-compose
   └─ Wait 30 seconds

2. Smoke Tests run
   ├─ Health checks: ✓ Pass
   ├─ Metrics validation: ✗ Fail (no metrics found)
   └─ Traces validation: Not executed

3. Rollback triggered automatically
   ├─ Stop current deployment
   ├─ Pull stable images
   ├─ Redeploy stable version
   └─ Verify health: ✓ Pass

4. Notification sent
   └─ GitHub Actions: ❌ Deployment failed and rolled back
```

### Logs en GitHub Actions

```
Run smoke tests - Metrics baseline
  Waiting for metrics to be collected...
  Checking if metrics are being reported...
  ❌ Metrics check failed!
  Error: No metrics found in Prometheus

Rollback on failure
  Deployment failed! Rolling back...
  Pulling stable images...
  ✓ demo-app:stable pulled
  ✓ anomaly-detector:stable pulled
  Redeploying stable version...
  ✓ Services restarted
  Rollback completed!
```

### Acción requerida
```bash
# 1. Investigar por qué fallaron las métricas
docker-compose logs demo-app
docker-compose logs prometheus

# 2. Arreglar el problema localmente
# ... hacer cambios ...

# 3. Validar localmente
docker-compose up -d
.\scripts\smoke-tests.ps1

# 4. Si pasa, hacer commit y push
git add .
git commit -m "fix: resolve metrics collection issue"
git push origin main
```

---

## Escenario 5: Deployment Manual a Production

### Situación
Quieres desplegar a production fuera del flujo normal (ej: fin de semana).

### Pasos

```bash
# 1. Ir a GitHub Actions
# GitHub > Actions > Deploy to Staging

# 2. Click "Run workflow"
# - Branch: main
# - Environment: production
# - Click "Run workflow"

# 3. Esperar aprobación
# El workflow esperará en "Manual approval required"

# 4. Revisar staging
# Verificar que staging está funcionando correctamente
# Revisar métricas en Grafana
# Revisar logs

# 5. Aprobar deployment
# GitHub > Actions > Deploy to Staging > Review deployments
# Click "Approve and deploy"

# 6. Monitorear production
# Verificar health checks
# Revisar métricas
# Monitorear logs
```

### Resultado esperado
```
Workflow Dispatch:
✓ Manual trigger initiated
✓ Staging deployment skipped (already deployed)
⏸ Waiting for manual approval
✓ Approval received
✓ Production deployment started
✓ Production smoke tests passed
✓ Deployment complete
```

---

## Escenario 6: Debugging de CI Failure

### Situación
El CI falla en GitHub pero pasa localmente.

### Pasos de debugging

```powershell
# 1. Ver logs en GitHub
# GitHub > Actions > CI - Build and Test > Failed job
# Identificar qué test falló

# 2. Reproducir localmente
cd demo-app
npm ci  # Usar ci en lugar de install
npm test

# 3. Si pasa localmente, verificar package-lock.json
git status
# Si package-lock.json tiene cambios:
git add package-lock.json
git commit -m "chore: update package-lock.json"
git push

# 4. Si sigue fallando, verificar versiones
node --version  # Debe ser 18.x
npm --version

# 5. Limpiar cache y reinstalar
rm -rf node_modules
rm package-lock.json
npm install
npm test

# 6. Si ahora pasa, commit y push
git add package-lock.json
git commit -m "fix: regenerate package-lock.json"
git push
```

### Logs útiles en GitHub Actions

```yaml
# Ver logs detallados
GitHub > Actions > Workflow run > Job > Step

# Logs de npm ci
Run npm ci
  npm WARN deprecated ...
  added 234 packages in 12s

# Logs de tests
Run npm test
  PASS src/tests/health.test.js
  FAIL src/tests/api.test.js
    ● API Tests › GET /api/users
      Expected: 200
      Received: 500
```

---

## Escenario 7: Actualizar Dependencias

### Situación
Necesitas actualizar dependencias de Node.js o Python.

### Para Node.js

```bash
# 1. Actualizar dependencias
cd demo-app
npm update

# 2. Verificar que todo funciona
npm test

# 3. Validar CI localmente
cd ..
.\scripts\validate-ci.ps1

# 4. Commit y push
git add demo-app/package.json demo-app/package-lock.json
git commit -m "chore: update Node.js dependencies"
git push origin main
```

### Para Python

```bash
# 1. Actualizar requirements.txt
cd anomaly-detector
# Editar requirements.txt manualmente

# 2. Instalar y probar
pip install -r requirements.txt
pytest test_*.py

# 3. Validar CI localmente
cd ..
.\scripts\validate-ci.ps1

# 4. Commit y push
git add anomaly-detector/requirements.txt
git commit -m "chore: update Python dependencies"
git push origin main
```

### Qué sucede
```
✓ CI tests con nuevas dependencias
✓ Docker build con nuevas dependencias
✓ Deploy a staging
✓ Smoke tests verifican que todo funciona
```

---

## Escenario 8: Monitoreo Post-Deployment

### Situación
Acabas de desplegar a production y quieres monitorear.

### Comandos útiles

```powershell
# 1. Verificar estado de containers
docker-compose ps

# 2. Ver logs en tiempo real
docker-compose logs -f demo-app

# 3. Ejecutar smoke tests
.\scripts\smoke-tests.ps1

# 4. Verificar métricas en Prometheus
# Abrir: http://localhost:9090
# Query: up
# Query: http_server_requests_total

# 5. Verificar trazas en Tempo
# Abrir Grafana: http://localhost:3001
# Explore > Tempo > Search

# 6. Verificar dashboards
# Grafana > Dashboards > SLI/SLO Dashboard

# 7. Generar tráfico de prueba
for ($i=0; $i -lt 100; $i++) {
    Invoke-WebRequest http://localhost:3000/api/users
    Start-Sleep -Milliseconds 100
}

# 8. Verificar que las métricas se actualizan
# Prometheus: http://localhost:9090
# Query: rate(http_server_requests_total[1m])
```

---

## Escenario 9: Configurar Notificaciones

### Situación
Quieres recibir notificaciones cuando el deployment falla.

### Opción 1: Email (GitHub nativo)

```
1. GitHub > Settings > Notifications
2. Enable "Actions" notifications
3. Recibirás email cuando workflows fallen
```

### Opción 2: Slack (Agregar al workflow)

```yaml
# Agregar al final de deploy.yml
- name: Notify Slack
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "❌ Deployment failed!",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Deployment Status:* Failed\n*Branch:* ${{ github.ref }}\n*Commit:* ${{ github.sha }}"
            }
          }
        ]
      }
```

### Opción 3: Discord (Agregar al workflow)

```yaml
- name: Notify Discord
  if: failure()
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    title: "Deployment Failed"
    description: "Branch: ${{ github.ref }}"
```

---

## Comandos Útiles de Referencia

```powershell
# Validación local completa
.\scripts\validate-ci.ps1

# Smoke tests
.\scripts\smoke-tests.ps1

# Ver logs de un servicio
docker-compose logs -f <servicio>

# Reiniciar un servicio
docker-compose restart <servicio>

# Ver estado de todos los servicios
docker-compose ps

# Limpiar todo y empezar de cero
docker-compose down -v
docker-compose up -d

# Ver imágenes en GHCR
# https://github.com/<owner>/<repo>/pkgs/container/<service>

# Ver workflows en GitHub
# https://github.com/<owner>/<repo>/actions
```

---

## Tips y Best Practices

### ✅ DO

- Siempre validar localmente antes de push
- Usar feature branches para desarrollo
- Escribir mensajes de commit descriptivos
- Revisar logs cuando algo falla
- Monitorear métricas después de deployment
- Mantener package-lock.json actualizado

### ❌ DON'T

- No hacer push directo a main sin PR
- No ignorar warnings del CI
- No desplegar a production sin verificar staging
- No hacer cambios grandes sin tests
- No ignorar fallos de smoke tests

---

## Referencias

- [Pipeline Diagram](PIPELINE-DIAGRAM.md)
- [Workflows README](README.md)
- [CI/CD Implementation](../../CI-CD-IMPLEMENTATION.md)
- [Quick Start](../../QUICK-START-CI-CD.md)
