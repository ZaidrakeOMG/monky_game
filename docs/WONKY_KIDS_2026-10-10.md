# Wonky Kids — actualización de experiencia y rendimiento (10-10-2026)

## Resumen y base verificada

Rama `feat/wonky-kids-joy-performance-20261010` nace del `main`
`c1c5b115b666da66c87871fee873f50797e41013`. No se fusiona ni
se reescribe la rama original. El proyecto usa Godot 4.7.2 y conserva
`config/name="Wonky"`, `user://monky_save.cfg`, IDs de objetos,
inventario, récords y todas las escenas jugables.

Esta entrega **extiende, no sustituye**, la auditoría de
[9 de octubre](AUDIT_2026-10-09.md). En la versión base ya estaban:
progreso real de ResourceLoader, transacciones de compras verificadas y
con respaldo, fade de audio exclusivo, récords persistentes en los cuatro
juegos, pools de Frutas/Runner, carga diferida de modales y pruebas de CI.

## Nuevas mejoras implementadas

| Antes | Después |
|---|---|
| Reacciones artísticas guardadas sin participar en el HUD | Burbuja de Wonky reutiliza ilustraciones de `reacciones` y selecciona hambre, descanso, higiene, juego o alegría a partir del estado real; al pulsarla abre el cuarto apropiado, despierta o acaricia |
| Juegos identificados por títulos largos | Accesos grandes **Frutas, Volar, Saltar, Correr**. El trofeo dibujado muestra el mejor récord persistido sobre cada juego |
| Menú de minijuegos se abría con `change_scene_to_file` directamente | Usa `SceneRouter.go`: bloqueo de doble toque, progreso real y recuperación de errores |
| Frutas daba puntos fijos sin encadenamientos | Combo real de 2.8 s; cada quinto acierto consecutivo añade puntos, usando `brillo.png`. Perder fruta, chocar con bomba o agotarse el tiempo reinicia la racha |
| Runner formateaba etiquetas/estados de poderes a 60 Hz | HUD como máximo cada 0.1 s, con actualización directa al ganar poder; sprite por objeto reutilizado durante el paso de física |
| Wonky aplicaba `visible` a accesorios cada frame | Escrituras solo al cambiar modo normal/baño/sueño, recalculadas al equipar algo |
| En teléfono barato, capturar cosas mostraba siempre partículas y muchos textos flotantes | Con efectos reducidos se evitan textos flotantes de Frutas y partículas breves de recogida Runner |
| Tienda conservaba publicidad inactiva como tarjeta visible | Publicidad deshabilitada **y oculta**; compras reales no integradas permanecen ocultas; mensajes simplificados |
| Nivel nuevo explicado con un párrafo | Resultado corto: nivel y monedas/diamante; preserva concesión real |

### Cuidado de los recursos y personajes

Las reacciones de `imagenes/ui_polished/reacciones/` son gráficos originales, no
caracteres Unicode que dependan de una fuente específica. Se enlazan
`feliz`, `triste`, `cansado`, `sucio`, `corazon` y el efecto `brillo`.
Los antiguos `check`/`alerta` siguen usados en el feedback de pociones.
`limpio` y `lleno` continúan como candidatos para animaciones contextuales;
no se borró ninguna ilustración que pudiera cargarse por catálogo.

La burbuja no modifica monedas/estadísticas al decidir una emoción; un clic solo
accede a funciones ya existentes. El combo suma puntos del juego y utiliza la
liquidación segura de `GameManager.settle_run` para récords/recompensas.
No afecta reglas de compras ni pagos y no introduce anuncios reales.

### Rendimiento, comprobaciones y riesgos

El HUD de Runner pasa de hasta 60 actualizaciones por segundo a unas
10 por segundo durante juego; esto es **límite de llamadas en código**,
no una medición de FPS. Los botones siguen siendo grandes dentro del lienzo
lógico 1080×1920 con escalado `keep` en otros formatos; no hay un diseño
separado probado para tabletas ni notch.

Los tests nuevos verifican selección de emoción, navegación al pulsar
el acceso real a juegos, reglas de combo y que anuncios inoperantes
no se presenten al niño. El workflow de PR usa Godot 4.7.2 de forma
aislada. No ejecutarlo sobre datos reales de usuario.

**Pendientes conocidos**: restaurar los PNG dañados de Héroe Nocturno
(archivos preservados e inactivos), perfilar advertencias de
`ObjectDB` al salir, probar durante 20–30 min en móviles modestos,
táctil simultáneo, audio, pausa/reinicio, guardado/recuperación con falta de
espacio, tamaños de pantalla y posición/tamaño de burbuja en notches.
No se afirma una mejora de FPS o consumo sin mediciones físicas; tampoco
se afirma que todos los flujos táctiles se validaron manualmente.

## Reproducir pruebas

```bash
python tools/audit_assets.py
python tools/run_checks.py --godot /ruta/a/Godot_v4.7.2-stable_linux.x86_64
```

Consulta el resultado del check **Godot quality checks** en el PR:
el documento registra cambios del código, no atribuye a ejecución local
ningún test que no se haya corrido.
