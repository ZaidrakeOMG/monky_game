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

**Ya están subidos a esta misma rama de GitHub** y se descargan con `git pull` sin descargar ZIP adicional. Se guardaron en WebP de calidad alta para reducir peso y mantener la resolución:

* `assets/backgrounds/wonder_flappy.webp`: adaptación vertical 1080 × 1920 del arte horizontal suministrado.
* `assets/backgrounds/wonder_fruit.webp`: huerto original en sus proporciones 941 × 1672, convertido a WebP de calidad alta.

El ZIP `WONKY_INSTALADOR_FONDOS_GIT.zip` del chat es **opcional**: incluye PNG y referencias originales sin comprimir, además de un instalador que respalda cambios locales, cambia de rama y puede publicar PNG en GitHub. Para la mayoría de los usuarios, los WebP incluidos en Git son suficientes.

Rutas opcionales en PNG si se usa el instalador:

* `assets/backgrounds/wonder_flappy.png`
* `assets/backgrounds/wonder_fruit.png`

`scripts/ui/wonder_assets.gd` ya detecta PNG, JPG y WebP automáticamente, con fallback si faltara alguno. Reiniciar Godot para importar recursos después de la copia.

## Comprobación
Confirmar que los archivos existen y no están vacíos, abrir Flappy y Frutas, y verificar que los tubos con brillo y boca verde se dibujan. Las pruebas automatizadas existentes validaron la lógica y el renderizado **antes** de añadir los fondos externos. Aún hace falta validación en un Android físico.
