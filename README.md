# Monky / Wonky

Mascota virtual y cuatro minijuegos hechos con Godot 4.7: Fruta, Flappy, Jump y Runner.

## Abrir

Importa `project.godot` con Godot 4.7.2. Se conserva `config/name="Wonky"` para mantener las partidas locales existentes. La escena inicial es `scenes/loading/loading_screen.tscn`.

## Calidad y actualización

La auditoría, cambios, límites y pruebas manuales pendientes están en [docs/AUDIT_2026-10-09.md](docs/AUDIT_2026-10-09.md).

```bash
python tools/audit_assets.py
python tools/run_checks.py --godot /ruta/al/ejecutable/godot
```

Las pruebas usan un directorio de usuario temporal y generan `reports/`. No abren ni sustituyen una partida real.
No existen anuncios ni compras con dinero real integrados: esos controles se muestran deshabilitados, nunca conceden premios simulados.
El Héroe Nocturno espera la recuperación de sus PNG originales; el catálogo conserva la propiedad y utiliza Wonky base mientras tanto.

## Arquitectura

`GameManager` mantiene el progreso y valida transacciones; `SafeSave` realiza persistencia verificable con respaldo.
`SceneRouter` controla la carga asíncrona y `AudioManager` los canales/fades. `UIEffects` limita animaciones por nodo/canal.
Cada minijuego conserva su escena y reglas, pero liquida recompensas y récords a través del gestor central.

## Controles

Runner: flechas/WASD para carril, arriba/espacio para saltar, abajo para deslizar; gestos en móvil. Flappy: tocar/clic o aceptar para saltar. Fruta y Jump conservan controles táctiles y de teclado.
El perfil gráfico conserva Compatibility y un lienzo vertical 1080×1920 sin deformación; otras proporciones pueden mostrar bandas.
