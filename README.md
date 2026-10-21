# Rick & Morty · Portal

Aplicación multiplataforma en Flutter para explorar y administrar un catálogo de personajes de Rick and Morty.

## Funcionalidades

- Inicio de sesión y registro de demostración, con validación de campos vacíos.
- Catálogo cargado desde `https://rickandmortyapi.com/api/character`, incluyendo todas las páginas de la API.
- Búsqueda por nombre, especie u origen y filtro por estado.
- Tarjetas responsivas y una pantalla de detalle con imagen, especie, género, estado y origen.
- Alta, edición y eliminación de personajes desde la interfaz.

La API pública es de solo lectura: las altas, ediciones y eliminaciones modifican el catálogo en memoria de la sesión actual. Al actualizar el catálogo o cerrar la aplicación, vuelve a cargarse la información original de la API.

## Acceso de demostración

- Usuario: `admin`
- Contraseña: `1234`

El registro y las credenciales se guardan solo en memoria y no constituyen autenticación segura para producción. Para un despliegue real se necesita un servicio de autenticación y almacenamiento en servidor.

## Ejecutar

```sh
flutter pub get
flutter run
```

La aplicación necesita conexión a internet para consultar la API. El permiso de internet de Android ya está habilitado.

## Validación

```sh
flutter analyze
flutter test
```
