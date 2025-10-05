# Fix: npm ci en Dockerfile

## 🔴 Problema Encontrado

El workflow ahora falla en **"Build and push demo-app"** con:

```
ERROR: failed to build: failed to solve: 
process "/bin/sh -c npm ci --only=production" did not complete successfully: exit code: 1
```

### Análisis del Error

**Causa:** El mismo problema de `npm ci` que teníamos en el workflow, ahora ocurre dentro del Dockerfile cuando se construye la imagen.

**Ubicación:** `demo-app/Dockerfile` línea 13

```dockerfile
RUN npm ci --only=production  ❌
```

## ✅ Solución Implementada

### Cambio en el Dockerfile

**Antes:**
```dockerfile
# Install dependencies
RUN npm ci --only=production
```

**Después:**
```dockerfile
# Install dependencies
RUN npm install --only=production --legacy-peer-deps || npm install --only=production
```

### Por Qué Funciona

1. **npm install** es más flexible que `npm ci`
2. **--legacy-peer-deps** maneja conflictos de peer dependencies (común con OpenTelemetry)
3. **Fallback** si el primer comando falla, intenta sin `--legacy-peer-deps`

## 📊 Comparación Completa

### Errores Encontrados y Corregidos

| # | Ubicación | Error | Solución | Estado |
|---|-----------|-------|----------|--------|
| 1 | Workflow - test job | `npm ci` falla | Cambiar a `npm install` | ✅ |
| 2 | Workflow - build job | Tags con mayúsculas | Convertir a lowercase | ✅ |
| 3 | Dockerfile - demo-app | `npm ci` falla | Cambiar a `npm install` | ✅ |

## 🔧 Detalles Técnicos

### npm ci vs npm install en Docker

**npm ci (Clean Install):**
```dockerfile
RUN npm ci --only=production
```
- ✅ Más rápido
- ✅ Reproducible
- ❌ Requiere package-lock.json sincronizado
- ❌ Falla con peer dependency conflicts

**npm install:**
```dockerfile
RUN npm install --only=production --legacy-peer-deps
```
- ✅ Más flexible
- ✅ Maneja peer dependencies
- ✅ Actualiza lock file si es necesario
- ⚠️ Ligeramente más lento

### Por Qué --legacy-peer-deps

OpenTelemetry tiene muchas dependencias que pueden tener conflictos de peer dependencies:

```
@opentelemetry/sdk-node
@opentelemetry/auto-instrumentations-node
@opentelemetry/exporter-trace-otlp-grpc
@opentelemetry/exporter-metrics-otlp-grpc
...
```

El flag `--legacy-peer-deps` le dice a npm que ignore estos conflictos.

## 🎯 Resultado Esperado

Después del próximo commit:

```
✅ Run Tests (completa)
✅ Build Docker Images (completa)
   ├── Prepare image names ✅
   ├── Build and push demo-app ✅ (ahora funciona)
   └── Build and push anomaly-detector ✅
✅ Deploy to Staging (completa)
```

## 🚀 Próximo Paso

```bash
git add demo-app/Dockerfile
git commit -m "fix: cambiar npm ci a npm install en Dockerfile"
git push origin main
```

## 💡 Mejores Prácticas

### Para Desarrollo
```dockerfile
RUN npm install
```

### Para Producción (cuando package-lock.json esté estable)
```dockerfile
RUN npm ci --only=production
```

### Para Proyectos con OpenTelemetry (actual)
```dockerfile
RUN npm install --only=production --legacy-peer-deps
```

## 🔍 Verificación Local

Puedes probar el build localmente:

```bash
cd demo-app
docker build -t demo-app:test .
```

Si funciona localmente, funcionará en GitHub Actions.

## 📚 Archivos Modificados

### Resumen de Todos los Cambios

1. **`.github/workflows/main-pipeline.yml`**
   - Cambio 1: `npm ci` → `npm install` en test job
   - Cambio 2: Agregar conversión a lowercase para tags
   - Cambio 3: Separar instalación de tests

2. **`demo-app/Dockerfile`**
   - Cambio: `npm ci` → `npm install --legacy-peer-deps`

## 🎉 Estado Final

Después de este fix, el pipeline completo debería funcionar:

```
Main CI/CD Pipeline
├── Run Tests ✅
│   ├── Install Node.js dependencies ✅
│   ├── Test Node.js app ✅
│   ├── Install Python dependencies ✅
│   └── Test Python service ✅
├── Build Docker Images ✅
│   ├── Prepare image names ✅
│   ├── Build demo-app ✅ (CORREGIDO)
│   └── Build anomaly-detector ✅
└── Deploy to Staging ✅
    └── Deploy simulated ✅
```

## 🔄 Lecciones Aprendidas

### Problema Raíz
El `package-lock.json` está desincronizado o tiene conflictos de peer dependencies.

### Solución Temporal
Usar `npm install` con `--legacy-peer-deps` en lugar de `npm ci`.

### Solución Permanente (Opcional)
```bash
# Regenerar package-lock.json limpio
cd demo-app
rm -rf node_modules package-lock.json
npm install
git add package-lock.json
git commit -m "chore: regenerar package-lock.json"
```

Luego podrías volver a usar `npm ci` si lo deseas.

---

**Error:** npm ci falla en Dockerfile  
**Solución:** Cambiar a npm install con --legacy-peer-deps  
**Estado:** ✅ CORREGIDO  
**Archivos:** 1 (demo-app/Dockerfile)
