# V10 — Wonky Run rehecho

Esta versión corrige los fallos visuales mostrados en el video:

- Eliminada la moneda gigante que podía cubrir la pantalla.
- Moneda de HUD y moneda de pista usan archivos pequeños independientes.
- Wonky y el enemigo usan frames normalizados a un mismo lienzo para evitar que se inflen/encojan al correr.
- Wonky tiene más presencia visual y queda proporcionado al escenario.
- Objetos y obstáculos crecen con una curva de perspectiva y llegan alineados al carril del jugador.
- Carriles reajustados al nuevo escenario.
- El enemigo sale de pantalla durante la carrera normal y se acerca al primer choque; un segundo choque durante la ventana de peligro termina la partida.
- Fondo con micro movimiento y polvo más visible.
- Game Over oscurece más el mundo para separar correctamente la interfaz del juego.
- Se mantuvieron monedas, imán, escudo, x2, salto, deslizamiento, pausa, récord, revivir y recompensas.

La escena sigue siendo `res://scenes/minigames/wonky_runner.tscn`.
