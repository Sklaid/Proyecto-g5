# AIOps & SRE Observability Platform - Índice de Documentación

## 📋 Índice General

Este documento proporciona un índice completo de toda la documentación y scripts del proyecto, organizados por categorías.

**Última actualización:** 2025-10-05
**Estado del proyecto:** ✅ PRODUCCIÓN

---

## 📁 Estructura de Carpetas

```
Proyecto-g5/
├── docs/
│   ├── validation-reports/    # Reportes de validación Task 11
│   ├── guides/                 # Guías de usuario y configuración
│   ├── summaries/              # Resúmenes de tareas y correcciones
│   └── ci-cd/                  # Documentación CI/CD
├── scripts/
│   ├── validation/             # Scripts de validación
│   ├── traffic-generation/     # Scripts de generación de tráfico
│   └── utilities/              # Scripts de utilidades
└── [componentes del sistema]
```

---

## 📊 Reportes de Validación (Task 11)

**Ubicación:** `docs/validation-reports/`

| Documento | Descripción |
|-----------|-------------|
| [VALIDATION_INDEX.md](docs/validation-reports/VALIDATION_INDEX.md) | Índice maestro de validaciones |
| [TASK_11.1_VALIDATION_REPORT.md](docs/validation-reports/TASK_11.1_VALIDATION_REPORT.md) | Validación: Stack Docker Compose |
| [TASK_11.2_VALIDATION_REPORT.md](docs/validation-reports/TASK_11.2_VALIDATION_REPORT.md) | Validación: Pipeline de telemetría |
| [TASK_11.3_VALIDATION_REPORT.md](docs/validation-reports/TASK_11.3_VALIDATION_REPORT.md) | Validación: Dashboards y visualizaciones |
| [TASK_11.4_VALIDATION_REPORT.md](docs/validation-reports/TASK_11.4_VALIDATION_REPORT.md) | Validación: Detección de anomalías |
| [TASK_11.5_VALIDATION_REPORT.md](docs/validation-reports/TASK_11.5_VALIDATION_REPORT.md) | Validación: Reglas de alertas |
| [TASK_11.6_VALIDATION_REPORT.md](docs/validation-reports/TASK_11.6_VALIDATION_REPORT.md) | Validación: Pipeline CI/CD |
| [VALIDATION_GUIDE.md](docs/validation-reports/VALIDATION_GUIDE.md) | Guía general de validación |

---

## 📖 Guías de Usuario

**Ubicación:** `docs/guides/`

### Inicio Rápido
| Documento | Descripción |
|-----------|-------------|
| [QUICK_START.md](docs/guides/QUICK_START.md) | Guía de inicio rápido general |
| [INSTRUCCIONES_RAPIDAS.md](docs/guides/INSTRUCCIONES_RAPIDAS.md) | Instrucciones rápidas en español |
| [GRAFANA_QUICK_START.md](docs/guides/GRAFANA_QUICK_START.md) | Inicio rápido de Grafana |

### Guías de Configuración
| Documento | Descripción |
|-----------|-------------|
| [SLI_SLO_CONFIGURATION_GUIDE.md](docs/guides/SLI_SLO_CONFIGURATION_GUIDE.md) | Configuración de SLI/SLO |
| [USAGE_EXAMPLES.md](docs/guides/USAGE_EXAMPLES.md) | Ejemplos de uso |
| [HOW_TO_RUN_TESTS.md](docs/guides/HOW_TO_RUN_TESTS.md) | Cómo ejecutar tests |

### Guías de Funcionalidades
| Documento | Descripción |
|-----------|-------------|
| [TEMPO_TRACING_GUIDE.md](docs/guides/TEMPO_TRACING_GUIDE.md) | Guía de tracing con Tempo |
| [TRACE_SEARCH_EXPLICACION.md](docs/guides/TRACE_SEARCH_EXPLICACION.md) | Explicación de búsqueda de trazas |
| [DASHBOARD_INTERPRETATION_GUIDE.md](docs/guides/DASHBOARD_INTERPRETATION_GUIDE.md) | Interpretación de dashboards |
| [GENERADOR_ERRORES_GUIA.md](docs/guides/GENERADOR_ERRORES_GUIA.md) | Guía del generador de errores |

---

## 📝 Resúmenes y Documentación Técnica

**Ubicación:** `docs/summaries/`

### Resúmenes de Tareas
| Documento | Descripción |
|-----------|-------------|
| [TASK_11_COMPLETE_SUMMARY.md](docs/summaries/TASK_11_COMPLETE_SUMMARY.md) | Resumen completo Task 11 |
| [TASK_10.3_COMPLETION_SUMMARY.md](docs/summaries/TASK_10.3_COMPLETION_SUMMARY.md) | Resumen Task 10.3 |
| [TASK-8-SUMMARY.md](docs/summaries/TASK-8-SUMMARY.md) | Resumen Task 8 |
| [TASK-8.4-SMOKE-TESTS-SUMMARY.md](docs/summaries/TASK-8.4-SMOKE-TESTS-SUMMARY.md) | Resumen Task 8.4 |

### Resúmenes del Proyecto
| Documento | Descripción |
|-----------|-------------|
| [PROYECTO_COMPLETO_RESUMEN.md](docs/summaries/PROYECTO_COMPLETO_RESUMEN.md) | Resumen completo del proyecto |
| [EXECUTION_SUMMARY.md](docs/summaries/EXECUTION_SUMMARY.md) | Resumen de ejecución |
| [DEPLOYMENT_STATUS.md](docs/summaries/DEPLOYMENT_STATUS.md) | Estado del despliegue |
| [K8S_DEPLOYMENT_SUMMARY.md](docs/summaries/K8S_DEPLOYMENT_SUMMARY.md) | Resumen despliegue Kubernetes |

### Documentos de Entrega
| Documento | Descripción |
|-----------|-------------|
| [ENTREGA_FINAL_PROYECTO.md](docs/summaries/ENTREGA_FINAL_PROYECTO.md) | Entrega final del proyecto |
| [CUMPLIMIENTO_OBJETIVOS_TEMA05.md](docs/summaries/CUMPLIMIENTO_OBJETIVOS_TEMA05.md) | Cumplimiento objetivos Tema 5 |
| [Cumplmiento-del-proyecto.md](docs/summaries/Cumplmiento-del-proyecto.md) | Cumplimiento del proyecto |

### Correcciones y Mejoras
| Documento | Descripción |
|-----------|-------------|
| [DASHBOARD_FIX_SUMMARY.md](docs/summaries/DASHBOARD_FIX_SUMMARY.md) | Correcciones de dashboards |
| [DASHBOARDS_LISTOS.md](docs/summaries/DASHBOARDS_LISTOS.md) | Dashboards completados |
| [DISTRIBUTED_TRACING_SOLUCION.md](docs/summaries/DISTRIBUTED_TRACING_SOLUCION.md) | Solución tracing distribuido |
| [DOCKER_TAG_LOWERCASE_FIX.md](docs/summaries/DOCKER_TAG_LOWERCASE_FIX.md) | Fix tags Docker lowercase |
| [DOCKERFILE_NPM_CI_FIX.md](docs/summaries/DOCKERFILE_NPM_CI_FIX.md) | Fix npm ci en Dockerfile |
| [METRICAS_CORREGIDAS_FINAL.md](docs/summaries/METRICAS_CORREGIDAS_FINAL.md) | Métricas corregidas final |
| [METRICAS_NODEJS_IMPLEMENTADAS.md](docs/summaries/METRICAS_NODEJS_IMPLEMENTADAS.md) | Métricas Node.js implementadas |
| [METRICAS_RECURSOS_EXPLICACION.md](docs/summaries/METRICAS_RECURSOS_EXPLICACION.md) | Explicación métricas de recursos |
| [PANELES_ERRORES_CORREGIDOS.md](docs/summaries/PANELES_ERRORES_CORREGIDOS.md) | Paneles de errores corregidos |
| [RESUMEN_ACTUALIZACION_DASHBOARDS.md](docs/summaries/RESUMEN_ACTUALIZACION_DASHBOARDS.md) | Actualización de dashboards |
| [RESUMEN_GENERADOR_ERRORES.md](docs/summaries/RESUMEN_GENERADOR_ERRORES.md) | Resumen generador de errores |
| [SOLUCION_DASHBOARDS_FINAL.md](docs/summaries/SOLUCION_DASHBOARDS_FINAL.md) | Solución final dashboards |

---

## 🔄 Documentación CI/CD

**Ubicación:** `docs/ci-cd/`

| Documento | Descripción |
|-----------|-------------|
| [CI-CD-DOCS-INDEX.md](docs/ci-cd/CI-CD-DOCS-INDEX.md) | Índice documentación CI/CD |
| [CI-CD-IMPLEMENTATION.md](docs/ci-cd/CI-CD-IMPLEMENTATION.md) | Implementación CI/CD |
| [QUICK-START-CI-CD.md](docs/ci-cd/QUICK-START-CI-CD.md) | Inicio rápido CI/CD |
| [README-CI-CD.md](docs/ci-cd/README-CI-CD.md) | README CI/CD |
| [GITHUB_ACTIONS_FIX_SUMMARY.md](docs/ci-cd/GITHUB_ACTIONS_FIX_SUMMARY.md) | Correcciones GitHub Actions |
| [SMOKE_TESTS_IMPROVEMENTS.md](docs/ci-cd/SMOKE_TESTS_IMPROVEMENTS.md) | Mejoras smoke tests |

---

## 🔧 Scripts de Validación

**Ubicación:** `scripts/validation/`

| Script | Descripción | Uso |
|--------|-------------|-----|
| validate-stack.ps1 | Valida stack Docker Compose | `.\scripts\validation\validate-stack.ps1` |
| validate-stack.bat | Wrapper Windows para validate-stack | `.\scripts\validation\validate-stack.bat` |
| validate-telemetry.ps1 | Valida pipeline de telemetría | `.\scripts\validation\validate-telemetry.ps1` |
| validate-telemetry.bat | Wrapper Windows para validate-telemetry | `.\scripts\validation\validate-telemetry.bat` |
| validate-dashboards.ps1 | Valida dashboards de Grafana | `.\scripts\validation\validate-dashboards.ps1` |
| validate-dashboards.bat | Wrapper Windows para validate-dashboards | `.\scripts\validation\validate-dashboards.bat` |
| test-anomaly-detection.ps1 | Prueba detección de anomalías | `.\scripts\validation\test-anomaly-detection.ps1` |
| test-anomaly-detection.bat | Wrapper Windows para test-anomaly | `.\scripts\validation\test-anomaly-detection.bat` |
| test-alerting.ps1 | Prueba reglas de alertas | `.\scripts\validation\test-alerting.ps1` |
| test-alerting.bat | Wrapper Windows para test-alerting | `.\scripts\validation\test-alerting.bat` |

---

## 🚦 Scripts de Generación de Tráfico

**Ubicación:** `scripts/traffic-generation/`

| Script | Descripción | Uso |
|--------|-------------|-----|
| generate-continuous-traffic.ps1 | Genera tráfico continuo | `.\scripts\traffic-generation\generate-continuous-traffic.ps1` |
| generate-mixed-traffic.ps1 | Genera tráfico mixto | `.\scripts\traffic-generation\generate-mixed-traffic.ps1` |
| generate-test-errors.ps1 | Genera errores de prueba | `.\scripts\traffic-generation\generate-test-errors.ps1` |
| generate-test-errors.bat | Wrapper Windows para generate-test-errors | `.\scripts\traffic-generation\generate-test-errors.bat` |
| generate-traffic.bat | Generador de tráfico básico | `.\scripts\traffic-generation\generate-traffic.bat` |

---

## 🛠️ Scripts de Utilidades

**Ubicación:** `scripts/utilities/`

### Verificación y Diagnóstico
| Script | Descripción | Uso |
|--------|-------------|-----|
| check-metrics.bat | Verifica métricas | `.\scripts\utilities\check-metrics.bat` |
| check-otel-metrics.ps1 | Verifica métricas OTel | `.\scripts\utilities\check-otel-metrics.ps1` |
| diagnose-telemetry.bat | Diagnostica telemetría | `.\scripts\utilities\diagnose-telemetry.bat` |
| list-available-metrics.ps1 | Lista métricas disponibles | `.\scripts\utilities\list-available-metrics.ps1` |
| verify-dashboards.ps1 | Verifica dashboards | `.\scripts\utilities\verify-dashboards.ps1` |
| verify-error-rate.ps1 | Verifica tasa de errores | `.\scripts\utilities\verify-error-rate.ps1` |

### Gestión de Plataforma
| Script | Descripción | Uso |
|--------|-------------|-----|
| start-platform.bat | Inicia la plataforma | `.\scripts\utilities\start-platform.bat` |
| restart-grafana.bat | Reinicia Grafana | `.\scripts\utilities\restart-grafana.bat` |
| apply-metrics-changes.bat | Aplica cambios de métricas | `.\scripts\utilities\apply-metrics-changes.bat` |

### Acceso Rápido
| Script | Descripción | Uso |
|--------|-------------|-----|
| open-grafana.bat | Abre Grafana en navegador | `.\scripts\utilities\open-grafana.bat` |
| open-all-dashboards.bat | Abre todos los dashboards | `.\scripts\utilities\open-all-dashboards.bat` |
| open-tempo-explore.bat | Abre explorador de Tempo | `.\scripts\utilities\open-tempo-explore.bat` |

---

## 📚 Documentos Principales en Raíz

| Documento | Descripción |
|-----------|-------------|
| [README.md](README.md) | README principal del proyecto |
| [docker-compose.yml](docker-compose.yml) | Configuración Docker Compose |
| [.gitignore](.gitignore) | Archivos ignorados por Git |

---

## 🔗 Enlaces Rápidos

### Acceso a Servicios
- **Demo App:** http://localhost:3000
- **Grafana:** http://localhost:3001 (admin/admin)
- **Prometheus:** http://localhost:9090
- **Tempo:** http://localhost:3200

### Dashboards de Grafana
- **SLI/SLO Dashboard:** http://localhost:3001/d/sli-slo-dashboard
- **Application Performance:** http://localhost:3001/d/app-performance-dashboard
- **Distributed Tracing:** http://localhost:3001/d/distributed-tracing-dashboard

### Documentación Clave
- [Índice de Validación](docs/validation-reports/VALIDATION_INDEX.md)
- [Resumen Completo Task 11](docs/summaries/TASK_11_COMPLETE_SUMMARY.md)
- [Guía de Inicio Rápido](docs/guides/QUICK_START.md)
- [Documentación CI/CD](docs/ci-cd/CI-CD-DOCS-INDEX.md)

---

## 🚀 Inicio Rápido

### 1. Iniciar la Plataforma
```bash
docker-compose up -d
```

### 2. Validar el Stack
```powershell
.\scripts\validation\validate-stack.ps1
```

### 3. Validar Telemetría
```powershell
.\scripts\validation\validate-telemetry.ps1
```

### 4. Acceder a Grafana
```bash
.\scripts\utilities\open-grafana.bat
```

---

## 📊 Estado del Proyecto

| Componente | Estado | Documentación |
|------------|--------|---------------|
| Stack Docker | ✅ Operacional | [Task 11.1](docs/validation-reports/TASK_11.1_VALIDATION_REPORT.md) |
| Pipeline Telemetría | ✅ Operacional | [Task 11.2](docs/validation-reports/TASK_11.2_VALIDATION_REPORT.md) |
| Dashboards | ✅ Operacional | [Task 11.3](docs/validation-reports/TASK_11.3_VALIDATION_REPORT.md) |
| Detección Anomalías | ✅ Operacional | [Task 11.4](docs/validation-reports/TASK_11.4_VALIDATION_REPORT.md) |
| Alertas | ✅ Operacional | [Task 11.5](docs/validation-reports/TASK_11.5_VALIDATION_REPORT.md) |
| CI/CD Pipeline | ✅ Operacional | [Task 11.6](docs/validation-reports/TASK_11.6_VALIDATION_REPORT.md) |

**Estado General:** ✅ PRODUCCIÓN - Todos los componentes validados y operacionales

---

## 📞 Soporte

Para preguntas o problemas:
1. Consulta los reportes de validación en `docs/validation-reports/`
2. Revisa las guías en `docs/guides/`
3. Ejecuta los scripts de diagnóstico en `scripts/utilities/`
4. Consulta los resúmenes técnicos en `docs/summaries/`

---

**Última actualización:** 2025-10-05
**Versión:** 1.0.0
**Estado:** Producción
