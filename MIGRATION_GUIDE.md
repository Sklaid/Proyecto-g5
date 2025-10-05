# Guía de Migración - Nueva Estructura de Documentación

## 📋 Resumen

Este documento proporciona información sobre cómo actualizar referencias a archivos que han sido movidos durante la reorganización.

## 🔄 Cambios de Ubicación

### Reportes de Validación

| Ubicación Anterior | Nueva Ubicación |
|-------------------|------------------|
| `VALIDATION_INDEX.md` | `docs/validation-reports/VALIDATION_INDEX.md` |
| `TASK_11.1_VALIDATION_REPORT.md` | `docs/validation-reports/TASK_11.1_VALIDATION_REPORT.md` |
| `TASK_11.2_VALIDATION_REPORT.md` | `docs/validation-reports/TASK_11.2_VALIDATION_REPORT.md` |
| `TASK_11.3_VALIDATION_REPORT.md` | `docs/validation-reports/TASK_11.3_VALIDATION_REPORT.md` |
| `TASK_11.4_VALIDATION_REPORT.md` | `docs/validation-reports/TASK_11.4_VALIDATION_REPORT.md` |
| `TASK_11.5_VALIDATION_REPORT.md` | `docs/validation-reports/TASK_11.5_VALIDATION_REPORT.md` |
| `TASK_11.6_VALIDATION_REPORT.md` | `docs/validation-reports/TASK_11.6_VALIDATION_REPORT.md` |
| `VALIDATION_GUIDE.md` | `docs/validation-reports/VALIDATION_GUIDE.md` |

### Scripts de Validación

| Ubicación Anterior | Nueva Ubicación |
|-------------------|------------------|
| `scripts/validate-stack.ps1` | `scripts/validation/validate-stack.ps1` |
| `scripts/validate-stack.bat` | `scripts/validation/validate-stack.bat` |
| `scripts/validate-telemetry.ps1` | `scripts/validation/validate-telemetry.ps1` |
| `scripts/validate-telemetry.bat` | `scripts/validation/validate-telemetry.bat` |
| `scripts/validate-dashboards.ps1` | `scripts/validation/validate-dashboards.ps1` |
| `scripts/validate-dashboards.bat` | `scripts/validation/validate-dashboards.bat` |
| `scripts/test-anomaly-detection.ps1` | `scripts/validation/test-anomaly-detection.ps1` |
| `scripts/test-anomaly-detection.bat` | `scripts/validation/test-anomaly-detection.bat` |
| `scripts/test-alerting.ps1` | `scripts/validation/test-alerting.ps1` |
| `scripts/test-alerting.bat` | `scripts/validation/test-alerting.bat` |

### Scripts de Generación de Tráfico

| Ubicación Anterior | Nueva Ubicación |
|-------------------|------------------|
| `generate-continuous-traffic.ps1` | `scripts/traffic-generation/generate-continuous-traffic.ps1` |
| `generate-mixed-traffic.ps1` | `scripts/traffic-generation/generate-mixed-traffic.ps1` |
| `generate-test-errors.ps1` | `scripts/traffic-generation/generate-test-errors.ps1` |
| `generate-test-errors.bat` | `scripts/traffic-generation/generate-test-errors.bat` |
| `generate-traffic.bat` | `scripts/traffic-generation/generate-traffic.bat` |

### Scripts de Utilidades

| Ubicación Anterior | Nueva Ubicación |
|-------------------|------------------|
| `check-metrics.bat` | `scripts/utilities/check-metrics.bat` |
| `check-otel-metrics.ps1` | `scripts/utilities/check-otel-metrics.ps1` |
| `diagnose-telemetry.bat` | `scripts/utilities/diagnose-telemetry.bat` |
| `list-available-metrics.ps1` | `scripts/utilities/list-available-metrics.ps1` |
| `verify-dashboards.ps1` | `scripts/utilities/verify-dashboards.ps1` |
| `verify-error-rate.ps1` | `scripts/utilities/verify-error-rate.ps1` |
| `apply-metrics-changes.bat` | `scripts/utilities/apply-metrics-changes.bat` |
| `open-all-dashboards.bat` | `scripts/utilities/open-all-dashboards.bat` |
| `open-grafana.bat` | `scripts/utilities/open-grafana.bat` |
| `open-tempo-explore.bat` | `scripts/utilities/open-tempo-explore.bat` |
| `restart-grafana.bat` | `scripts/utilities/restart-grafana.bat` |
| `start-platform.bat` | `scripts/utilities/start-platform.bat` |

## 🔧 Actualizar Referencias en Scripts

### Ejemplo: Actualizar llamadas a scripts

**Antes:**
```powershell
.\scripts\validate-stack.ps1
```

**Después:**
```powershell
.\scripts\validation\validate-stack.ps1
```

### Ejemplo: Actualizar referencias a documentación

**Antes:**
```markdown
Ver [VALIDATION_INDEX.md](VALIDATION_INDEX.md)
```

**Después:**
```markdown
Ver [VALIDATION_INDEX.md](docs/validation-reports/VALIDATION_INDEX.md)
```

## 📝 Comandos de Uso Actualizados

### Validación

```powershell
# Validar stack
.\scripts\validation\validate-stack.ps1

# Validar telemetría
.\scripts\validation\validate-telemetry.ps1

# Validar dashboards
.\scripts\validation\validate-dashboards.ps1

# Probar detección de anomalías
.\scripts\validation\test-anomaly-detection.ps1

# Probar alertas
.\scripts\validation\test-alerting.ps1
```

### Generación de Tráfico

```powershell
# Generar tráfico continuo
.\scripts\traffic-generation\generate-continuous-traffic.ps1

# Generar tráfico mixto
.\scripts\traffic-generation\generate-mixed-traffic.ps1

# Generar errores de prueba
.\scripts\traffic-generation\generate-test-errors.ps1
```

### Utilidades

```powershell
# Iniciar plataforma
.\scripts\utilities\start-platform.bat

# Abrir Grafana
.\scripts\utilities\open-grafana.bat

# Verificar dashboards
.\scripts\utilities\verify-dashboards.ps1

# Listar métricas disponibles
.\scripts\utilities\list-available-metrics.ps1
```

## 🔍 Buscar y Reemplazar

Si necesitas actualizar referencias en tus propios scripts o documentos:

### PowerShell
```powershell
# Buscar referencias antiguas
Get-ChildItem -Recurse -Include *.ps1,*.bat,*.md | Select-String "scripts/validate-stack"

# Reemplazar en un archivo específico
(Get-Content archivo.ps1) -replace 'scripts/validate-stack', 'scripts/validation/validate-stack' | Set-Content archivo.ps1
```

### Bash/Linux
```bash
# Buscar referencias antiguas
grep -r "scripts/validate-stack" .

# Reemplazar en todos los archivos
find . -type f -name "*.md" -exec sed -i 's|scripts/validate-stack|scripts/validation/validate-stack|g' {} +
```

## ✅ Verificación

Para verificar que todo funciona correctamente:

1. **Probar scripts de validación:**
   ```powershell
   .\scripts\validation\validate-stack.ps1
   ```

2. **Verificar documentación:**
   - Abrir [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
   - Verificar que todos los enlaces funcionan

3. **Probar utilidades:**
   ```powershell
   .\scripts\utilities\start-platform.bat
   ```

## 🆘 Solución de Problemas

### Problema: Script no encontrado

**Error:**
```
The term 'validate-stack.ps1' is not recognized...
```

**Solución:**
Actualizar la ruta al script:
```powershell
# Incorrecto
.\scripts\validate-stack.ps1

# Correcto
.\scripts\validation\validate-stack.ps1
```

### Problema: Documento no encontrado

**Error:**
```
404 - File not found
```

**Solución:**
Consultar [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) para la ubicación correcta.

## 📚 Recursos

- **Índice de Documentación:** [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
- **Resumen de Reorganización:** [REORGANIZATION_SUMMARY.md](REORGANIZATION_SUMMARY.md)
- **README Principal:** [README.md](README.md)

## 🎯 Checklist de Migración

Si estás actualizando tus propios scripts o documentos:

- [ ] Actualizar rutas a scripts de validación
- [ ] Actualizar rutas a scripts de tráfico
- [ ] Actualizar rutas a scripts de utilidades
- [ ] Actualizar enlaces a documentación
- [ ] Probar que todos los scripts funcionan
- [ ] Verificar que todos los enlaces funcionan
- [ ] Actualizar documentación interna si es necesario

## 📞 Soporte

Si encuentras problemas durante la migración:
1. Consulta [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
2. Revisa [REORGANIZATION_SUMMARY.md](REORGANIZATION_SUMMARY.md)
3. Verifica la estructura de carpetas actual

---

**Última actualización:** 2025-10-05
**Versión:** 1.0.0
