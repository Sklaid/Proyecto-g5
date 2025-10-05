# Fix: Docker Tag Lowercase Error

## 🔴 Problema Encontrado

Después de corregir el error de `npm ci`, el workflow ahora falla en **Build Docker Images** con:

```
ERROR: failed to build: invalid tag "ghcr.io/Sklaid/Proyecto-g5/demo-app:latest": 
repository name must be lowercase
```

### Análisis del Error

**Causa:** Docker requiere que los nombres de repositorio y tags sean en minúsculas, pero GitHub usa el nombre del repositorio tal como fue creado (con mayúsculas/minúsculas).

```
❌ ghcr.io/Sklaid/Proyecto-g5/demo-app:latest  (tiene mayúsculas)
✅ ghcr.io/sklaid/proyecto-g5/demo-app:latest  (todo minúsculas)
```

## ✅ Solución Implementada

### Cambio en el Workflow

Agregué un step que convierte el nombre del repositorio a minúsculas antes de construir las imágenes:

```yaml
- name: Prepare image names
  id: image-names
  run: |
    # Convert repository name to lowercase for Docker compatibility
    REPO_LOWER=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
    echo "repo_lower=$REPO_LOWER" >> $GITHUB_OUTPUT
    echo "Image prefix will be: $REPO_LOWER"
```

### Uso en Build Steps

**Antes:**
```yaml
tags: |
  ${{ env.REGISTRY }}/${{ env.IMAGE_PREFIX }}/demo-app:latest
```

**Después:**
```yaml
tags: |
  ${{ env.REGISTRY }}/${{ steps.image-names.outputs.repo_lower }}/demo-app:latest
```

## 🔧 Cómo Funciona

1. **Step "Prepare image names":**
   - Toma el nombre del repositorio: `Sklaid/Proyecto-g5`
   - Lo convierte a minúsculas: `sklaid/proyecto-g5`
   - Lo guarda en output: `repo_lower`

2. **Steps de Build:**
   - Usan el output: `${{ steps.image-names.outputs.repo_lower }}`
   - Resultado: `ghcr.io/sklaid/proyecto-g5/demo-app:latest` ✅

## 📊 Comparación

### Antes (❌ Fallaba)
```
github.repository = "Sklaid/Proyecto-g5"
                    ↓
ghcr.io/Sklaid/Proyecto-g5/demo-app:latest
        ^^^^^^ ^^^^^^^^^^
        Mayúsculas → ERROR
```

### Después (✅ Funciona)
```
github.repository = "Sklaid/Proyecto-g5"
                    ↓
tr '[:upper:]' '[:lower:]'
                    ↓
"sklaid/proyecto-g5"
                    ↓
ghcr.io/sklaid/proyecto-g5/demo-app:latest
        Todo minúsculas → OK
```

## 🎯 Resultado Esperado

Después del próximo commit, el workflow debería:

```
✅ Run Tests (completa)
✅ Build Docker Images (completa)
   ├── Prepare image names ✅
   ├── Build and push demo-app ✅
   └── Build and push anomaly-detector ✅
✅ Deploy to Staging (completa)
```

## 🚀 Próximo Paso

```bash
git add .github/workflows/main-pipeline.yml
git commit -m "fix: convertir nombres de repositorio a minúsculas para Docker tags"
git push origin main
```

## 💡 Por Qué Este Error Es Común

Docker Hub y GitHub Container Registry (GHCR) requieren nombres en minúsculas por:

1. **Compatibilidad:** URLs y DNS son case-insensitive
2. **Estándar:** Docker sigue la convención de nombres en minúsculas
3. **Prevención de conflictos:** Evita confusión entre `MyRepo` y `myrepo`

## 🔍 Verificación

Después del push, en GitHub Actions verás:

```
Prepare image names
  Image prefix will be: sklaid/proyecto-g5
```

Y las imágenes se subirán como:
```
ghcr.io/sklaid/proyecto-g5/demo-app:latest
ghcr.io/sklaid/proyecto-g5/demo-app:<commit-sha>
ghcr.io/sklaid/proyecto-g5/anomaly-detector:latest
ghcr.io/sklaid/proyecto-g5/anomaly-detector:<commit-sha>
```

## 📚 Referencia

- [Docker tag naming conventions](https://docs.docker.com/engine/reference/commandline/tag/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

**Error:** Invalid tag - repository name must be lowercase  
**Solución:** Convertir `github.repository` a minúsculas con `tr`  
**Estado:** ✅ CORREGIDO
