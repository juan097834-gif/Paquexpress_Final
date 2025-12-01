Sistema de Logística Paquexpress - Proyecto Unidad 3

Sistema integral para gestión de entregas de última milla. Incluye trazado de rutas, evidencia fotográfica y seguridad encriptada.

## Estructura del Repositorio
* **/App_Movil**: Código fuente de la aplicación Flutter.
* **/Backend_API**: API REST desarrollada en FastAPI (Python).
* **/Base_de_Datos**: Script SQL para importar en MySQL.

## Tecnologías
* **Frontend:** Flutter (Dart) con mapas OpenStreetMap.
* **Backend:** Python (FastAPI) con seguridad Bcrypt.
* **BD:** MySQL.

## Cómo ejecutar

1. **Base de Datos:** Importar `script.sql` en XAMPP/phpMyAdmin.
2. **Backend:**
   `pip install -r requirements.txt`
   `uvicorn main:app --reload`
3. **App:**
   `flutter pub get`
   `flutter run`

##  Alumno
Juan Antonio Nuñez Ortiz
