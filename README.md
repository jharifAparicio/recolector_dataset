# 📸 Recolector de Dataset en Flutter

Aplicación Flutter para capturar, organizar y subir imágenes a Google Drive, utilizando **Google Drive API** y Google Cloud para la autenticación y acceso a las carpetas.

---

## 🚀 Requisitos previos

- Flutter instalado (versión estable)
- Cuenta de Google Cloud
- Acceso a Google Drive
- Archivo `classes.json` con las clases e IDs de carpetas

---

## 1️⃣ Habilitar Google Drive API y obtener credenciales

1. Ingresa a la [Consola de Google Cloud](https://console.cloud.google.com/).
2. Crea un proyecto nuevo o selecciona uno existente.
3. Habilita la **Google Drive API**:
   - Menú → **API y servicios** → **Biblioteca**
   - Busca **Google Drive API**
   - Haz clic en **Habilitar**
4. Crea credenciales:
   - Menú → **API y servicios** → **Credenciales**
   - **Crear credenciales** → **ID de cliente de OAuth 2.0**
5. Configura la pantalla de consentimiento OAuth:
   - Menú → **Pantalla de consentimiento OAuth**
   - Tipo de usuario: **Externa**
   - Ingresa nombre de la app, correo de soporte y logo opcional.
   - En **Usuarios de prueba**, añade los correos que podrán usar la app.
6. Descarga el archivo `credentials.json` y colócalo en la carpeta del proyecto donde el código lo espere (ej: `assets/` o `lib/config/`).

---

## 2️⃣ Crear el asset `classes.json`

Este archivo contendrá el **ID** de la carpeta de Google Drive y el nombre de la clase, en formato clave-valor:

```json
{
  "1AbCdEfGhIjKlMnOp": "nombreClase1",
  "2QwErTyUiOpAsDfGh": "nombreClase2",
  "3ZxCvBnMmLoKjHgFd": "nombreClase3"
}
```

📂 **Ubicación:**  
Coloca `classes.json` dentro de `assets/` y decláralo en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/classes.json
```

---

## 3️⃣ Obtener IDs de las carpetas en Google Drive

1. Abre Google Drive.
2. Crea una carpeta para cada clase.
3. Haz clic derecho → **Obtener enlace**.
4. Copia **solo el ID de la carpeta** (no toda la URL).

Ejemplo de URL:  
```
https://drive.google.com/drive/folders/1AbCdEfGhIjKlMnOp
```
En este caso, el ID es:  
```
1AbCdEfGhIjKlMnOp
```

---

## 4️⃣ Dar permisos de acceso a los correos

Para que la app pueda subir imágenes:

1. En cada carpeta de Google Drive, clic derecho → **Compartir**.
2. Añade el correo del usuario o el **correo del cliente de servicio** que aparece en Google Cloud.
3. Asigna permiso **Editor**.

---

## 5️⃣ Dar consentimiento a usuarios en Google Cloud

Si la app usa OAuth:

1. Ve a **Pantalla de consentimiento OAuth** en Google Cloud.
2. En la sección **Usuarios de prueba**, añade los correos autorizados.
3. Guarda cambios.

---

## 6️⃣ Ejecución de la app

1. Clona el repositorio.
2. Instala dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta:
   ```bash
   flutter run
   ```

---

## 📌 Notas

- Si modificas `classes.json`, no es necesario recompilar la app, solo reiniciarla.
- Mantén tus credenciales seguras y **no las subas a un repositorio público**.
- Para producción, considera usar un backend intermedio para manejar la autenticación y subida de archivos a Google Drive.

---
