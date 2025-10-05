# Cómo Ejecutar los Smoke Tests

## 🎯 Problema Común

Si al ejecutar `.\scripts\smoke-tests.ps1` se abre el Bloc de Notas, es porque estás en **CMD** en lugar de **PowerShell**.

---

## ✅ Solución 1: Usar PowerShell (Recomendado)

### Paso 1: Abrir PowerShell

**Opción A: Desde el menú de Windows**
1. Presiona `Win + X`
2. Selecciona "Windows PowerShell" o "Terminal"

**Opción B: Desde el explorador**
1. Abre el explorador de archivos
2. Navega a la carpeta del proyecto
3. Shift + Click derecho en la carpeta
4. Selecciona "Abrir ventana de PowerShell aquí"

**Opción C: Desde CMD**
```cmd
powershell
```

### Paso 2: Navegar al Proyecto

```powershell
cd "C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5"
```

### Paso 3: Ejecutar el Script

```powershell
.\scripts\smoke-tests.ps1
```

**Si aparece error de ejecución de scripts:**
```powershell
# Permitir ejecución de scripts (una sola vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Luego ejecutar
.\scripts\smoke-tests.ps1
```

---

## ✅ Solución 2: Usar el Wrapper .bat (Desde CMD)

He creado un archivo `.bat` que puedes ejecutar desde CMD:

### Desde CMD:

```cmd
cd C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5
scripts\smoke-tests.bat
```

### Doble Click:

También puedes hacer doble click en:
```
scripts\smoke-tests.bat
```

---

## ✅ Solución 3: Ejecutar Directamente con PowerShell

Desde CMD, puedes ejecutar:

```cmd
powershell -ExecutionPolicy Bypass -File scripts\smoke-tests.ps1
```

---

## 📋 Resumen de Comandos

### PowerShell (Recomendado)
```powershell
# Abrir PowerShell y ejecutar:
cd "C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5"
.\scripts\smoke-tests.ps1
```

### CMD (Usando wrapper)
```cmd
cd C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5
scripts\smoke-tests.bat
```

### CMD (Directo)
```cmd
powershell -ExecutionPolicy Bypass -File scripts\smoke-tests.ps1
```

---

## 🔍 Identificar si estás en CMD o PowerShell

### CMD:
```
C:\Users\sklai\...>
```
Prompt termina en `>`

### PowerShell:
```
PS C:\Users\sklai\...>
```
Prompt empieza con `PS`

---

## 🚀 Flujo Completo Recomendado

### 1. Abrir PowerShell
```
Win + X → Windows PowerShell
```

### 2. Navegar al proyecto
```powershell
cd "C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5"
```

### 3. Verificar que estás en el directorio correcto
```powershell
ls
# Deberías ver: docker-compose.yml, scripts/, etc.
```

### 4. Ejecutar smoke tests
```powershell
.\scripts\smoke-tests.ps1
```

---

## 🐛 Troubleshooting

### Error: "No se puede cargar el archivo porque la ejecución de scripts está deshabilitada"

**Solución:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "El término '.\scripts\smoke-tests.ps1' no se reconoce"

**Causa:** Estás en CMD, no en PowerShell

**Solución:**
```cmd
# Desde CMD, ejecuta:
powershell
# Ahora estás en PowerShell, ejecuta:
.\scripts\smoke-tests.ps1
```

### Se abre el Bloc de Notas

**Causa:** Estás en CMD y Windows asocia `.ps1` con el editor de texto

**Solución:** Usa una de las 3 soluciones arriba

---

## 📚 Archivos Disponibles

| Archivo | Uso | Desde |
|---------|-----|-------|
| `scripts/smoke-tests.ps1` | Script principal | PowerShell |
| `scripts/smoke-tests.bat` | Wrapper | CMD |
| `scripts/smoke-tests.sh` | Para Linux/Mac | Bash |

---

## 💡 Recomendación

**Usa PowerShell** para todos los scripts de este proyecto:
- ✅ Mejor soporte para scripts `.ps1`
- ✅ Más funcionalidades
- ✅ Colores y formato mejorado
- ✅ Mejor manejo de errores

---

## 🎯 Quick Start

**La forma más rápida:**

1. Presiona `Win + X`
2. Click en "Windows PowerShell"
3. Ejecuta:
```powershell
cd "C:\Users\sklai\OneDrive\Documentos\UNI\2025-2\DEvops\Proyecto-g5"
.\scripts\smoke-tests.ps1
```

**¡Listo!** 🎉

---

## 📞 Ayuda Adicional

Si sigues teniendo problemas:

1. Verifica que PowerShell esté instalado:
   ```cmd
   powershell -version
   ```

2. Verifica que el archivo existe:
   ```cmd
   dir scripts\smoke-tests.ps1
   ```

3. Usa el wrapper .bat:
   ```cmd
   scripts\smoke-tests.bat
   ```

---

**Última actualización:** 2025-10-04  
**Probado en:** Windows 10/11
