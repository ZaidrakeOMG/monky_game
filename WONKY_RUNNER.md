# Wonky Run - Minijuego endless runner

Integrado al proyecto Wonky como cuarto minijuego dentro del menú **MINIJUEGOS**.

## Escena
- `res://scenes/minigames/wonky_runner.tscn`
- Script: `res://scripts/minigames/wonky_runner.gd`
- Recursos: `res://imagenes/runner/`

## Controles
- Móvil: deslizar izquierda/derecha para cambiar de carril, arriba para saltar y abajo para deslizarse.
- PC: flechas o WASD; espacio también salta.

## Jugabilidad
- 3 carriles con perspectiva.
- Wonky animado corriendo de espaldas.
- Enemigo morado perseguidor.
- Primera colisión: el enemigo se acerca durante unos segundos.
- Segunda colisión antes de recuperarse: Game Over.
- Caja y bola con picos: se pueden saltar o esquivar cambiando de carril.
- Barrera alta: se pasa deslizando o cambiando de carril.
- Monedas.
- Power-ups: imán, escudo y x2.
- Velocidad y frecuencia de obstáculos aumentan progresivamente.
- Pausa, récord local, reintentar, revivir una vez y volver al menú.
- Las monedas obtenidas se suman al GameManager al terminar la partida.

## Ajustes rápidos
En `wonky_runner.gd`:
- `scroll_speed`: velocidad inicial/progresiva.
- `LANE_X`: posición inferior de los 3 carriles.
- `PLAYER_Y`: altura de Wonky.
- `_final_scale_for()`: tamaño de obstáculos y power-ups.
- `_spawn_pattern()`: probabilidades de monedas/obstáculos/power-ups.
