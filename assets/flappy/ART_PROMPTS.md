# FLAPPY WONKY — Encargo para el creador de imágenes

Los siguientes archivos están conectados a Godot mediante rutas opcionales.
Se pueden subir por separado, sin romper el juego. En caso de faltar una pieza
el código usa el arte original como respaldo.

**En todas las imágenes:** videojuego móvil infantil 2D, calidad profesional,
formas redondeadas, colores alegres, contorno ilustrado nítido, luz suave,
coherencia con el universo original de Wonky. No fotorealismo, no horror,
no marcas, no marcas de agua, **no texto incorporado**, sin fondos falsamente
transparentes. Exportar PNG con las dimensiones EXACTAS indicadas. Cuando
se dibuje a Wonky, adjuntar como referencia la imagen de Wonky original:
mantener exactamente silueta, ojos, colores, tamaño relativo de brazos y pies.
No convertirlo en pájaro, humano, mono realista ni otra mascota.

## 1. `sky_background.png` — 1080×1920, PNG sin transparencia

«Crea un fondo vertical premium para un minijuego de volar protagonizado por
Wonky, una aventura de cielo tropical mágico, azul turquesa y celeste con
rayos suaves de luz dorada, nubes crema, islas lejanas entre bruma, bosque
esmeralda muy lejos en la zona inferior. Composición 9:16. La zona central
debe ser visualmente despejada para ver claramente al personaje, monedas y
obstáculos. Capas profundas de perspectiva y estilo cartoon 2D pulido,
colores armoniosos y alegres, sin tubos, sin personajes, sin HUD,
sin letras, sin números, sin logos. PNG 1080×1920.»

## 2. `cloud_overlay.png` — 1080×540, PNG RGBA transparente

«Crea UNA CAPA separada de nubes suaves y redondeadas, blancas, coral pálido
y lavanda muy clara, para moverse lentamente por encima de un fondo de cielo
turquesa. Distribución horizontal, varias nubes a distintas alturas con
bordes suaves y gran parte del espacio totalmente transparente. Estilo
cartoon de videojuego 2D infantil profesional, sin cielo pintado, sin
montañas, sin texto, sin personajes, alpha real. PNG RGBA 1080×540.»

## 3. `vine_top.png` — 256×768, PNG RGBA transparente

«Diseña un obstáculo vertical colgante para minijuego 2D infantil,
visto frontalmente: tronco-liana fantástico de madera cálida, enredaderas
turquesa, dos hojas y pequeños detalles dorados. Cuerpo largo y estrecho
CENTRADO, anchura uniforme de arriba abajo. El extremo INFERIOR tiene
un bonito remate redondeado claramente visible en los últimos 125 píxeles,
porque apunta hacia el hueco por donde volará Wonky. El centro del tronco
debe ser estirable verticalmente sin perder continuidad. Silueta limpia,
nada sobresale mucho hacia los lados, sin sombra exterior exagerada ni
texto. PNG RGBA 256×768, margen lateral transparente mínimo.»

## 4. `vine_bottom.png` — 256×768, PNG RGBA transparente

«La pareja del obstáculo colgante: árbol/liana fantástico que CRECE
hacia arriba desde la parte inferior de la pantalla. EXACTAMENTE igual
de ancho, color, textura y estilo que vine_top. El extremo SUPERIOR,
en los primeros 125 píxeles, tiene el remate redondeado ilustrado
orientado hacia el hueco central. El tramo medio es recto y
estirable verticalmente. Fondo transparente verdadero, no texturas
detrás, ningún elemento que cambie el ancho de la colisión.
PNG RGBA 256×768.»

## 5. `wonky_fly_01.png` a `wonky_fly_06.png` — SEIS archivos separados de 384×384 RGBA

«Adjunto una imagen del WONKY ORIGINAL. Necesito una secuencia de seis
cuadros para animación de vuelo 2D, NO una mascota distinta. Conserva
exactamente la cabeza/cuerpo original, ojos, boca, proporciones, colores,
brazos cortos y pies. Añade dos pequeñas alitas fantásticas coherentes
con su anatomía, sin manos humanas ni cuerpo de pájaro. Rostro feliz,
mirando levemente a la derecha, pose aérea. Seis imágenes SEPARADAS,
siempre el cuerpo en la misma posición y tamaño, mismo centro,
misma iluminación, los pies a la misma altura, sin fondos.
El único cambio es el aleteo:
01 alitas arriba, 02 tres cuartos arriba, 03 alitas horizontales,
04 alitas abajo, 05 alitas horizontales, 06 tres cuartos arriba.
Cada archivo 384×384 píxeles, PNG transparente con idéntico encuadre.
Ni secuencia cinematográfica, ni collage ni sprites de tamaños diferentes.»

**Ojo:** Si tu creador no mantiene consistencia en los seis archivos,
genera primero `wonky_fly_01.png` y pide editar ESA MISMA imagen
para las otras poses sin alterar ninguna otra cosa.

## 6. `tap_hand.png` — 256×256 RGBA

«Icono sin palabras para enseñar a niños a tocar la pantalla:
una mano caricaturesca redondeada de guante crema apuntando y una
pequeña estrellita dorada donde pulsa, con dos ondas de toque, estilo
sticker 2D brillante y limpio, claro a tamaño pequeño, colores acordes
con Wonky, contorno grueso, fondo realmente transparente, sin pantalla
de teléfono, sin letras. PNG RGBA 256×256.»

## 7. `menu_cover.png` — 512×512 PNG

«Portada cuadrada para elegir el minijuego de volar en la aplicación
infantil Wonky. Usar la referencia original del personaje para que
sea IDENTICO, ahora con alitas cortas y cara alegre; vuela por el cielo
tropical mágico entre dos lianas redondeadas, una moneda pequeña y
una estela de brillos. Composición muy clara en miniatura, protagonista
en el centro, colores turquesa, verde, coral y amarillo dorado.
Ilustración 2D premium, NO texto, no logos, no controles,
no manos humanas, sin alterar el diseño de Wonky. PNG 512×512.»

## 8. `gameover_wonky.png` — 512×512 RGBA

«Wonky original en una pose tierna de celebración tras terminar una
partida, contento, alitas pequeñas, brazos cortos levantados,
brillos, confeti moderado y dos estrellitas; exactamente la misma
anatomía y cara de la referencia. Imagen tipo sticker con contorno
nítido, iluminación alegre y colores consistentes con la selva
celestial. Una ilustración aislada, nada de panel, nada de números,
nada de letras ni botones; fondo transparente real. PNG 512×512.»

## Carpeta de entrega

```
assets/flappy/
  sky_background.png
  cloud_overlay.png
  vine_top.png
  vine_bottom.png
  wonky_fly_01.png
  wonky_fly_02.png
  wonky_fly_03.png
  wonky_fly_04.png
  wonky_fly_05.png
  wonky_fly_06.png
  tap_hand.png
  menu_cover.png
  gameover_wonky.png
```

Para equipos de bajos recursos, exportar sin bordes innecesarios, evitar
PNG enormes, y después comprimir sin pérdida; los PNG de Wonky no
deben tener cuadros de animación movidos respecto a los demás.
Con los archivos ausentes el juego mantiene las imágenes existentes.
