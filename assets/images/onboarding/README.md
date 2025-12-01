# Imágenes del Onboarding

Este directorio contiene las imágenes para el tutorial de bienvenida de Togetherly.

## Imágenes Requeridas

Por favor, coloca las siguientes imágenes (screenshots de la app) en este directorio:

1. **onboarding_welcome.png** - Imagen de bienvenida a Togetherly
   - Puede ser el logo, pantalla principal, o una vista general de la app

2. **onboarding_circles.png** - Explicación de los círculos
   - Screenshot mostrando la vista de círculos o cómo crear un círculo
   - Ilustra la funcionalidad de grupos de personas

3. **onboarding_events.png** - Eventos compartidos
   - Screenshot mostrando eventos en un círculo
   - Ilustra cómo se organizan eventos entre amigos/familia

4. **onboarding_calendar.png** - Calendario unificado
   - Screenshot del calendario mostrando eventos personales y de círculos
   - Ilustra la vista principal del calendario

5. **onboarding_start.png** - Pantalla final motivacional
   - Puede ser una vista del dashboard o una imagen inspiracional
   - Anima al usuario a comenzar a usar la app

## Especificaciones Recomendadas

- **Formato**: PNG (con transparencia si es necesario)
- **Dimensiones**: 
  - Ancho: 1080px - 1440px
  - Alto: 1200px - 1600px (formato vertical/retrato)
- **Tamaño del archivo**: Optimizado, preferiblemente < 500KB por imagen
- **Contenido**: Screenshots reales de la app funcionando o ilustraciones simples y claras

## Notas

- Las imágenes se mostrarán en un contenedor de 300px de alto con esquinas redondeadas
- El diseño es responsive, así que las imágenes se adaptarán automáticamente
- Si falta alguna imagen, se mostrará un placeholder con el emoji correspondiente y el nombre del archivo esperado
- Puedes usar herramientas como TinyPNG para optimizar el tamaño de los archivos sin perder calidad

## Ruta en el código

Estas imágenes están referenciadas en:
- `lib/models/onboarding_model.dart` - Define las rutas
- `lib/views/onboarding_view.dart` - Muestra las imágenes

Si cambias los nombres de archivo, asegúrate de actualizar también `onboarding_model.dart`.
