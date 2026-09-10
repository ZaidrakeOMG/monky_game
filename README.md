# Wonky — proyecto base Godot 4

Este proyecto deja funcionando la primera pantalla del juego:

- Fondo: `cuarto-principal.png`
- Wonky: animación `pensando` en loop
- Resolución base vertical: 941 × 1672, pensada para móvil
- Renderer: Compatibility, práctico para Android/iOS

## Qué hice con `pensando.mp4`

El video original tenía fondo negro y estaba en MP4. En vez de reproducirlo como video, se convirtió a 60 frames PNG transparentes a 12 FPS y se usa `AnimatedSprite2D`. Esto permite poner a Wonky encima de cualquier habitación y evita que aparezca el rectángulo negro del MP4.

El MP4 original sigue guardado en `source_video/pensando_original.mp4`. Esa carpeta tiene `.gdignore` para que Godot no intente importarlo.

## Abrir

1. Abre Godot 4.
2. Pulsa **Import**.
3. Selecciona `project.godot`.
4. Abre el proyecto y ejecuta con F6/F5.

La escena principal está en `scenes/main.tscn`.

## Para agregar otra animación

Conviene repetir el mismo flujo:

1. Exportar/generar el video.
2. Convertirlo a frames PNG transparentes.
3. Añadir esos frames a un recurso `SpriteFrames`.
4. Reproducir la animación desde `AnimatedSprite2D`.

Más adelante se pueden añadir `comer`, `dormir`, `feliz`, `triste`, `bañarse`, etc., y controlarlas desde un script de estado de Wonky.
