# WONKY RUN V11 — escenario con movimiento real

Esta versión reemplaza el fondo único del runner por un escenario por capas:

- `fondo_lejano.png`: cielo, montañas, pueblo y cascada. Casi fijo.
- `camino_loop.png`: tres carriles; se desplaza de forma infinita y se proyecta hacia un punto de fuga.
- `laterales_loop.png`: vegetación, cercas y piedras; parallax más lento que el camino.
- `foreground_speed_sheet.png`: hoja original de efectos de velocidad.
- `fx/*`: recortes usados durante la carrera para polvo, hojas, pétalos y trazos de velocidad.

## Cambios de gameplay/visual

- El camino y los objetos usan la misma fórmula de perspectiva.
- Las monedas y obstáculos se dimensionan según el ancho real del carril en su profundidad.
- Wonky ocupa aproximadamente el ancho de un carril cerca de la cámara.
- El enemigo mantiene una escala compatible con Wonky y solo se aproxima al cometer errores.
- El piso se mueve continuamente; los laterales se desplazan más lento y el fondo apenas se balancea.
- Partículas rápidas pasan por los costados para aumentar la sensación de velocidad.
- La moneda del HUD sigue separada de la moneda de pista; no puede aparecer a tamaño de pantalla.

## Archivo principal

`scripts/minigames/wonky_runner.gd`

## Resolución de diseño

1080 x 1920 (9:16), con `canvas_items` y `expand` como en el proyecto base.
