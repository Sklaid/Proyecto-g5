# 🚀 Instrucciones Rápidas - Dashboards Actualizados

## ⚡ Aplicar Cambios (3 pasos)

### 1️⃣ Reiniciar Grafana
```bash
.\restart-grafana.bat
```

### 2️⃣ Abrir Grafana
- URL: http://localhost:3001
- Usuario: `admin`
- Password: `admin`

### 3️⃣ Verificar Dashboards
- Application Performance Dashboard ✅
- Distributed Tracing Dashboard ✅
- SLI/SLO Dashboard ✅

## 🔍 Verificar Métricas

```powershell
.\verify-error-rate.ps1
```

## 📊 Generar Tráfico

```bash
.\generate-traffic.bat
```

## ❓ FAQ Rápido

### ¿Por qué Error Rate no muestra datos?

**Es CORRECTO** si no hay errores en la aplicación.

### ¿Cómo probar el Error Rate?

```bash
curl http://localhost:3000/error
```

### ¿Qué cambió?

- ✅ Métrica correcta: `http_server_duration_milliseconds`
- ✅ Labels corregidos: `http_status_code`
- ✅ Queries optimizadas

## 📚 Documentación Completa

- `RESUMEN_ACTUALIZACION_DASHBOARDS.md` - Resumen en español
- `DASHBOARD_UPDATES.md` - Documentación técnica
- `DASHBOARD_FIX_SUMMARY.md` - Resumen en inglés

---

**¿Listo?** Ejecuta: `.\restart-grafana.bat`
