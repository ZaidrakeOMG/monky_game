# Wonky: corregir la descarga e instalar fondos originales

## Por qué no se veían el menú ni los tubos
En la consola mostrada, `git switch feat/wonky-arcade-20261013` se canceló porque `project.godot` tenía cambios locales. Por tanto, `git pull --ff-only origin feat/wonky-arcade-20261013` se ejecutó desde **la rama anterior**, que había divergido. **La rama nueva nunca se activó**.

## Cambiar de rama sin perder modificaciones
Desde la carpeta local del repositorio, con Godot cerrado:

```bat
cd /d "%USERPROFILE%\Desktop\wonky"
git status
git stash push -u -m "Wonky-respaldo-antes-del-arcade"
git fetch origin
git switch feat/wonky-arcade-20261013
```

Si `git switch` dice que la rama local no existe, ejecutar **en lugar del último comando**:

```bat
git switch --track origin/feat/wonky-arcade-20261013
```

Después de comprobar que se ha cambiado de rama:

```bat
git pull --ff-only origin feat/wonky-arcade-20261013
git branch --show-current
git log -1 --oneline
git stash list
```

No restaurar automáticamente `project.godot` desde `stash`: revisar diferencias antes para no anular la configuración de la nueva rama. No ejecutar `reset --hard`.

## Fondos enviados por el propietario
Se recuperaron los originales del chat:
* Paisaje mágico horizontal de fantasía (Flappy).
* Huerto vertical de frutas (Fruit Catcher).
* Lámina de tubos verdes; los tubos nuevos ya forman parte de esta rama en `assets/ui/wonder/pipe_green.png`.

Los dos fondos **no se subieron a GitHub en este commit de documentación**: sus archivos binarios se entregaron en el ZIP `WONKY_INSTALADOR_FONDOS_GIT.zip` del chat. El instalador del ZIP se ejecuta desde fuera del repositorio, guarda cambios locales en `git stash`, cambia a esta rama, copia los PNG al sitio esperado, crea commit de esos dos PNG y ejecuta `git push` desde el equipo del propietario con su autenticación local.

Rutas consumidas por el proyecto:

* `assets/backgrounds/wonder_flappy.png`: montaje vertical a partir del paisaje original, sin distorsión; el ZIP también contiene la imagen horizontal intacta.
* `assets/backgrounds/wonder_fruit.png`: huerto original intacto.

`scripts/ui/wonder_assets.gd` ya detecta ambas rutas, con fallback cuando todavía no se copiaron. Reiniciar Godot para importar recursos después de la copia.

## Comprobación
Confirmar que los archivos existen y no están vacíos, abrir Flappy y Frutas, y verificar que los tubos con brillo y boca verde se dibujan. Las pruebas automatizadas existentes validaron la lógica y el renderizado **antes** de añadir los fondos externos. Aún hace falta validación en un Android físico.
