# Quick Start - CI/CD Pipeline

Guía rápida para empezar a usar el pipeline de CI/CD.

## ⚡ Setup Rápido (5 minutos)

### 1. Configurar GitHub (Una sola vez)

```bash
# 1. Habilitar permisos de workflow
# GitHub > Settings > Actions > General > Workflow permissions
# ✅ Seleccionar: "Read and write permissions"

# 2. Crear environments
# GitHub > Settings > Environments
# ✅ Crear: "staging" (sin aprobación)
# ✅ Crear: "production" (con aprobación manual)
```

### 2. Validar Localmente

```powershell
# Ejecutar validación completa
.\scripts\validate-ci.ps1

# Si todo pasa, estás listo para push!
```

### 3. Hacer Push

```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

### 4. Verificar en GitHub

```bash
# Ir a: GitHub > Actions
# Deberías ver 3 workflows ejecutándose:
# ✅ CI - Build and Test
# ✅ Docker Build and Push
# ✅ Deploy to Staging
```

---

## 🔄 Workflow Diario

### Desarrollo en Feature Branch

```bash
# 1. Crear feature branch
git checkout -b feature/mi-feature

# 2. Hacer cambios y validar
.\scripts\validate-ci.ps1

# 3. Push (solo ejecuta CI, no deployment)
git push origin feature/mi-feature

# 4. Crear Pull Request
# GitHub ejecutará CI automáticamente
```

### Merge a Main (Deployment Automático)

```bash
# 1. Merge PR a main
git checkout main
git merge feature/mi-feature
git push origin main

# 2. GitHub automáticamente:
# ✅ Ejecuta CI
# ✅ Construye imágenes Docker
# ✅ Despliega a staging
# ✅ Ejecuta smoke tests

# 3. Si staging pasa, aprobar production manualmente
# GitHub > Actions > Deploy to Staging > Review deployments
```

---

## 🧪 Testing Local

### Antes de Push

```powershell
# Validación completa (recomendado)
.\scripts\validate-ci.ps1
```

### Después de Levantar el Stack

```powershell
# Levantar servicios
docker-compose up -d

# Esperar 30 segundos
Start-Sleep -Seconds 30

# Ejecutar smoke tests
.\scripts\smoke-tests.ps1
```

---

## 🚨 Troubleshooting Rápido

### CI falla

```powershell
# Ejecutar localmente para ver el error
cd demo-app
npm test

cd ../anomaly-detector
pytest test_*.py
```

### Docker build falla

```powershell
# Construir localmente
docker build -t test ./demo-app
docker build -t test ./anomaly-detector
```

### Smoke tests fallan

```powershell
# Ver logs
docker-compose logs demo-app
docker-compose logs prometheus

# Reiniciar
docker-compose down
docker-compose up -d
```

---

## 📋 Comandos Útiles

```powershell
# Validar CI localmente
.\scripts\validate-ci.ps1

# Ejecutar smoke tests
.\scripts\smoke-tests.ps1

# Ver logs de servicios
docker-compose logs -f demo-app

# Reiniciar stack
docker-compose restart

# Ver estado de containers
docker-compose ps

# Limpiar todo
docker-compose down -v
```

---

## 🎯 Checklist Rápido

Antes de hacer push:

- [ ] `.\scripts\validate-ci.ps1` pasa ✅
- [ ] Tests locales pasan ✅
- [ ] Docker builds funcionan ✅
- [ ] Commit message es descriptivo ✅

Después de push a main:

- [ ] CI pasa en GitHub ✅
- [ ] Docker images se publican ✅
- [ ] Staging deployment exitoso ✅
- [ ] Smoke tests pasan ✅

Para production:

- [ ] Staging verificado ✅
- [ ] Métricas revisadas ✅
- [ ] Aprobación manual dada ✅
- [ ] Production deployment exitoso ✅

---

## 📚 Más Información

- **Documentación completa:** [CI-CD-IMPLEMENTATION.md](CI-CD-IMPLEMENTATION.md)
- **Workflows README:** [.github/workflows/README.md](.github/workflows/README.md)
- **Deployment Checklist:** [.github/DEPLOYMENT_CHECKLIST.md](.github/DEPLOYMENT_CHECKLIST.md)

---

## 💡 Tips

1. **Siempre valida localmente antes de push:**
   ```powershell
   .\scripts\validate-ci.ps1
   ```

2. **Usa feature branches para desarrollo:**
   ```bash
   git checkout -b feature/nombre
   ```

3. **Revisa los logs si algo falla:**
   ```bash
   # En GitHub
   Actions > Workflow run > Job > Step logs
   
   # Localmente
   docker-compose logs servicio
   ```

4. **Los smoke tests son tu amigo:**
   ```powershell
   .\scripts\smoke-tests.ps1
   ```

---

¡Listo! 🚀 Ahora tienes un pipeline de CI/CD completamente funcional.
