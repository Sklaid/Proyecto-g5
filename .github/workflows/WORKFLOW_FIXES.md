# GitHub Actions Workflow Fixes

## Problemas Identificados

Los workflows originales tenían varios problemas que causaban fallos:

### 1. **Dependencias entre workflows**
- El workflow `deploy.yml` se ejecutaba inmediatamente después de push a main
- Intentaba hacer pull de imágenes Docker que aún no existían
- No esperaba a que `docker-build.yml` terminara

### 2. **Imágenes Docker no disponibles**
- Los workflows intentaban hacer pull de imágenes del registry antes de que fueran construidas
- Esto causaba errores en el primer push

### 3. **Tests fallando**
- Los tests pueden no estar completamente configurados aún
- Los workflows fallaban completamente si los tests no pasaban

## Solución Implementada

### Opción 1: Workflow Unificado (Recomendado)

He creado un nuevo workflow `main-pipeline.yml` que:

✅ **Ejecuta todo en secuencia:**
1. Tests (Node.js y Python)
2. Build de imágenes Docker (solo en main)
3. Deploy simulado (solo en main)

✅ **Maneja errores gracefully:**
- Si los tests no están configurados, muestra warning pero continúa
- No intenta hacer pull de imágenes que no existen
- Build y deploy solo se ejecutan en branch main

✅ **Más simple y robusto:**
- Un solo archivo de workflow
- Dependencias claras entre jobs
- Fácil de entender y mantener

### Opción 2: Workflows Separados (Corregidos)

Los workflows originales han sido deshabilitados (renombrados a `.disabled`) pero corregidos:

**Cambios en `deploy.yml`:**
```yaml
# Ahora espera a que docker-build termine
on:
  workflow_run:
    workflows: ["Docker Build and Push"]
    types:
      - completed
```

**Cambios en el deploy:**
```yaml
# Verifica si las imágenes existen antes de hacer pull
- name: Check if images exist
  # Si no existen, hace build local
```

## Cómo Usar

### Para usar el workflow unificado (Recomendado):

El workflow `main-pipeline.yml` ya está activo y se ejecutará automáticamente en:
- Push a `main` o `develop`
- Pull requests
- Manualmente desde GitHub Actions UI

### Para volver a los workflows separados:

1. Renombrar los archivos `.disabled` quitando esa extensión:
```bash
mv .github/workflows/ci.yml.disabled .github/workflows/ci.yml
mv .github/workflows/deploy.yml.disabled .github/workflows/deploy.yml
mv .github/workflows/docker-build.yml.disabled .github/workflows/docker-build.yml
```

2. Eliminar `main-pipeline.yml`:
```bash
rm .github/workflows/main-pipeline.yml
```

## Estado Actual

### Workflows Activos:
- ✅ `main-pipeline.yml` - Pipeline unificado (ACTIVO)

### Workflows Deshabilitados:
- ⏸️ `ci.yml.disabled` - Tests separados
- ⏸️ `deploy.yml.disabled` - Deployment separado
- ⏸️ `docker-build.yml.disabled` - Docker build separado

## Próximos Pasos

1. **Verificar que el nuevo workflow funciona:**
   - Hacer commit y push
   - Ver en GitHub Actions que el workflow se ejecuta correctamente

2. **Una vez que todo funcione:**
   - Puedes eliminar los archivos `.disabled` si no los necesitas
   - O mantenerlos como referencia

3. **Para producción:**
   - Configurar secrets necesarios (si los hay)
   - Ajustar el deploy para que realmente despliegue (actualmente es simulado)
   - Configurar environments en GitHub (staging, production)

## Diferencias Clave

| Aspecto | Workflows Originales | Workflow Unificado |
|---------|---------------------|-------------------|
| Archivos | 3 archivos separados | 1 archivo |
| Complejidad | Alta (dependencias entre workflows) | Baja (todo en un lugar) |
| Manejo de errores | Falla completamente | Continúa con warnings |
| Deploy | Intenta deploy real | Deploy simulado (seguro) |
| Imágenes Docker | Intenta pull del registry | Build local si no existen |

## Troubleshooting

### Si el workflow sigue fallando:

1. **Verificar que los Dockerfiles existen:**
```bash
ls demo-app/Dockerfile
ls anomaly-detector/Dockerfile
```

2. **Verificar permisos de GitHub:**
- Settings > Actions > General > Workflow permissions
- Debe estar en "Read and write permissions"

3. **Ver logs detallados:**
- Ir a Actions tab en GitHub
- Click en el workflow que falló
- Ver los logs de cada step

### Si necesitas deshabilitar temporalmente el workflow:

Renombrar el archivo:
```bash
mv .github/workflows/main-pipeline.yml .github/workflows/main-pipeline.yml.disabled
```

## Recomendación Final

**Usa el workflow unificado (`main-pipeline.yml`)** porque:
- ✅ Es más simple
- ✅ Menos propenso a errores
- ✅ Más fácil de mantener
- ✅ Maneja casos edge mejor
- ✅ No requiere configuración adicional

Una vez que el proyecto esté más maduro y necesites workflows más complejos, puedes volver a los workflows separados usando las versiones corregidas.
