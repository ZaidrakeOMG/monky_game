# Wonky V8 — corrección de interfaz y baño

## Interfaz
- Ajustes reconstruido para usar el marco ilustrado sin barras/letreros atravesados.
- Título de Ajustes integrado en la placa de madera superior.
- Sonido, Música y Vibración alineados en una sola fila con estados simples ACTIVO/APAGADO.
- Reiniciar y Salir separados y centrados.
- Tienda rediseñada: ya no repite puestos completos de diamantes/monedas en cada producto.
- Productos de la tienda usan cajones ilustrados con icono + nombre + precio.
- Portada de tienda reducida para no comerse toda la pantalla.
- Mercado de comida pasa a 2 columnas grandes para que los alimentos se lean mejor.
- Títulos de Tienda y Mercado usan la placa superior del marco ilustrado.

## Baño
- Cepillo, jabón y ducha sólo funcionan cuando el cuarto actual es Baño.
- Si sales del baño con una herramienta activa, la herramienta desaparece.
- La lógica también se valida en GameManager para evitar uso accidental fuera del baño.

## Popó
- Ya no se elimina tocándola.
- Al tocarla sólo muestra el aviso de que debes bañar a Wonky.
- Toda la popó pendiente desaparece únicamente al enjuagar/bañar a Wonky dentro del baño.
- El contador guardado de popó se pone en cero únicamente después del baño.
