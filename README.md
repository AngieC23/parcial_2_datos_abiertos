# parcial_2_datos_abiertos

Aplicacion Flutter para consultar Datos Abiertos de Colombia consumiendo 4 endpoints oficiales de la API publica.

## API usada

- Base: https://api-colombia.com/api/v1
- Swagger: https://api-colombia.com/swagger/index.html

### Endpoints seleccionados

1. `Department`
2. `President`
3. `Region`
4. `TouristicAttraction`

## Paquetes implementados

- `http`: consumo de API REST.
- `go_router`: navegacion declarativa y rutas con parametros.
- `flutter_dotenv`: manejo de variable de entorno para URL base.

## Estructura del proyecto

```text
lib/
	config/          // configuraciones y metadatos de endpoints
	models/          // modelos con fromJson/toJson
	routes/          // configuracion de go_router
	services/        // consumo HTTP y transformacion de datos
	themes/          // tema global
	views/           // pantallas Dashboard, Listado y Detalle
	widgets/         // componentes reutilizables
main.dart
```

## Arquitectura aplicada

1. Capa `models`: clases tipadas por endpoint (`department`, `president`, `region`, `touristic_attraction`).
2. Capa `services`: `ApiColombiaService` concentra peticiones GET y manejo de errores HTTP.
3. Capa `views`: pantallas separadas por responsabilidad.
4. Capa `routes`: rutas maestro-detalle con parametros.

## Flujo funcional

1. Dashboard (`/`): muestra cards para los 4 endpoints.
2. Listado (`/list/:endpoint`): consulta datos y renderiza `ListView.builder`.
3. Detalle (`/detail/:endpoint/:id`): consulta/arma detalle completo del elemento seleccionado.

## Manejo de estados

Cada pantalla de consumo usa estados:

- `cargando`: `CircularProgressIndicator`.
- `exito`: render de lista o detalle.
- `error`: mensaje y boton `Reintentar`.

## Rutas implementadas con go_router

1. `/` -> Dashboard principal.
2. `/list/:endpoint` -> Listado dinamico por endpoint.
3. `/detail/:endpoint/:id` -> Detalle del elemento seleccionado.

### Parametros enviados

- `endpoint`: identificador logico (`departments`, `presidents`, `regions`, `touristic-attractions`).
- `id`: identificador del registro en API Colombia.

## Variables de entorno

Archivo `.env`:

```env
API_BASE_URL=https://api-colombia.com/api/v1
```

## Ejemplo de respuesta JSON

Ejemplo para `Department`:

```json
{
	"id": 1,
	"name": "Amazonas",
	"description": "Departamento al sur del pais",
	"cityCapital": "Leticia",
	"surface": "109665"
}
```

## Ejecucion local

```bash
flutter pub get
flutter run
```

## Evidencias para entrega

Incluir capturas de:

1. Dashboard con cards de endpoints.
2. Listado de un endpoint cargado desde API.
3. Detalle de un elemento.
4. Estado de error (simulable cambiando temporalmente la URL base).

## Flujo Git solicitado

1. Crear rama `dev` desde `main`.
2. Crear rama `feature/parcial_api_colombia` desde `dev`.
3. Trabajar con commits atomicos y convencion:
	 - `feat:` nueva funcionalidad.
	 - `fix:` correccion.
	 - `docs:` documentacion.
4. Abrir Pull Request `feature/parcial_api_colombia -> dev` con descripcion y evidencias.
5. Merge de `dev -> main` al finalizar revision.

## Entregables finales

1. PDF con enlace al repositorio publico, ramas (`main`, `dev`, `feature/parcial_api_colombia`) y resumen tecnico.
2. Video mostrando:
	 - funcionamiento Dashboard/Listado/Detalle,
	 - manejo de estados,
	 - explicacion breve del desarrollo.
