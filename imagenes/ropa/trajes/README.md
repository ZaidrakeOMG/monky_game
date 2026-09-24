# Trajes de Wonky por piezas

El sistema ya NO usa AutoFit sobre un traje completo. Cada traje debe ir en su propia carpeta y puede tener varias piezas PNG.

## Estructura

Ejemplo:

imagenes/ropa/trajes/heroe_nocturno/
- cuerpo.png
- mascara.png
- capa.png
- brazos.png
- pies.png
- sombrero.png
- preview.png
- traje.json

No todas las piezas son obligatorias. Puedes usar solo las que necesite el traje.

## Nombres aceptados

- cuerpo.png o body.png
- mascara.png o mask.png
- capa.png o cape.png
- brazos.png o arms.png
- pies.png, botas.png, feet.png o boots.png
- sombrero.png, casco.png, hat.png o helmet.png
- preview.png, vista_previa.png, icon.png o icono.png

## Regla más importante

Cada PNG debe crearse usando como plantilla el Wonky frontal del proyecto. La pieza debe conservar el mismo lienzo y coordenadas de Wonky. No dibujes un cuerpo nuevo.

La ropa debe verse como una capa parcial encima del personaje:
- cuerpo.png: solo tela que cubre el torso
- mascara.png: solo la máscara, alineada con los ojos
- brazos.png: solo mangas/guantes
- pies.png: solo calzado
- capa.png: solo la capa
- sombrero.png: solo sombrero/casco

Fondo con transparencia alfa real.

## Tienda automática

Cada carpeta válida aparece automáticamente en Armario > Ropa.

Para pruebas, si no existe traje.json:
- precio = 0
- desbloqueado = true
- el nombre sale del nombre de la carpeta

## traje.json opcional

Ejemplo:

{
  "nombre": "Héroe Nocturno",
  "monedas": 0,
  "diamantes": 0,
  "desbloqueado": true
}

