/**
 * ============================================================================
 *              SOLUCIÓN: IMÁGENES EN APK (RECETAS Y PERFIL)
 * ============================================================================
 * 
 * PROBLEMA: Las imágenes no se cargan en APK de dispositivo físico
 * CAUSA: baseUrl hardcodeada a http://10.0.2.2:8000 (solo para emulador)
 * 
 * ============================================================================
 *                       SOLUCIÓN IMPLEMENTADA
 * ============================================================================
 * 
 * Se ha creado ImageUrlHelper (lib/utils/image_url_helper.dart) que:
 * 
 * 1. DETECTA el tipo de build:
 *    - Debug/Emulador → URL completa con baseUrl
 *    - Release/APK → URL relativa (más compatible)
 *    - Web → URL completa
 * 
 * 2. NORMALIZA paths:
 *    - Elimina barra inicial si existe
 *    - Añade timestamp para forzar recarga de caché
 * 
 * 3. ARCHIVOS MODIFICADOS:
 *    ✅ lib/screens/Profile_screen.dart → _buildRecetaImageWidget()
 *    ✅ lib/screens/home_screen.dart → RecipeButton (tarjeta de receta)
 *    ✅ lib/screens/DetalleRecetaPage.dart → Imagen de detalle
 *    ✅ lib/utils/image_url_helper.dart (NUEVO)
 * 
 * ============================================================================
 *                    CÓMO USAR SEGÚN TU ESCENARIO
 * ============================================================================
 * 
 * 📌 ESCENARIO 1: Emulador Android (Recomendado para desarrollo)
 * └─ Mantén: baseUrl = 'http://10.0.2.2:8000' en config.dart
 * └─ El helper detectará que es Debug y usará URL completa
 * └─ ✅ Las imágenes funcionarán
 * 
 * 📌 ESCENARIO 2: Dispositivo Físico (Mismo WiFi local)
 * ├─ Opción A (AUTOMÁTICA - ✅ RECOMENDADO):
 * │  └─ Compila APK en Release mode
 * │  └─ El helper usará URL relativa: /uploads/...
 * │  └─ Funciona si el backend está en http://[IP]:8000
 * │  └─ No necesitas cambiar nada en config.dart
 * │
 * ├─ Opción B (MANUAL):
 * │  └─ Cambia baseUrl en config.dart a tu IP local:
 * │     const String baseUrl = 'http://192.168.1.100:8000';
 * │  └─ Verifica tu IP con: ipconfig (Windows) o ifconfig (Mac/Linux)
 * │  └─ Recompila APK
 * │
 * └─ Opción C (NGROK - Para red diferente):
 *    └─ Expone tu servidor local: ngrok http 8000
 *    └─ Cambia baseUrl en config.dart:
 *       const String baseUrl = 'https://abc123.ngrok.io';
 *    └─ Recompila APK
 * 
 * 📌 ESCENARIO 3: App Publicada (Servidor remoto)
 * ├─ Cambia baseUrl en config.dart a URL remota:
 *    const String baseUrl = 'https://api.tudominio.com';
 * └─ Recompila APK para Play Store
 * 
 * ============================================================================
 *                      INSTRUCCIONES PASO A PASO
 * ============================================================================
 * 
 * ✅ PARA COMPILAR APK QUE FUNCIONE EN DISPOSITIVO FÍSICO:
 * 
 * 1️⃣ DESCUBRE TU IP LOCAL:
 *    Windows:
 *      Abre PowerShell y ejecuta:
 *      ipconfig
 *      Busca "IPv4 Address: 192.168.x.x"
 *    
 *    Mac/Linux:
 *      ifconfig | grep "inet " | grep -v 127.0.0.1
 * 
 * 2️⃣ ACTUALIZA config.dart (OPCIONAL - si usas Opción B):
 *    ```dart
 *    const String baseUrl = 'http://192.168.1.100:8000';
 *    ```
 *    Reemplaza XX con tu IP
 * 
 * 3️⃣ VERIFICA QUE EL BACKEND ESTÉ CORRIENDO:
 *    Terminal Backend:
 *      cd Backend
 *      node server.js
 *      Debe mostrar: "Servidor corriendo en http://localhost:8000"
 * 
 * 4️⃣ CONECTA DISPOSITIVO POR USB O WIFI
 * 
 * 5️⃣ COMPILA APK:
 *    ```bash
 *    cd remy_recipes
 *    flutter build apk --release
 *    ```
 *    Se creará en: build/app/outputs/flutter-apk/app-release.apk
 * 
 * 6️⃣ INSTALA EN DISPOSITIVO:
 *    ```bash
 *    flutter install build/app/outputs/flutter-apk/app-release.apk
 *    ```
 * 
 * 7️⃣ PRUEBA LA APP:
 *    - Ve a Home y haz scroll en el grid de recetas
 *    - Abre tu perfil
 *    - Las imágenes deben cargar correctamente
 * 
 * ============================================================================
 *                      TECNOLOGÍA DETRÁS
 * ============================================================================
 * 
 * El helper usa dos estrategias:
 * 
 * 📍 EN DEBUG (Emulador):
 *    ${ApiEndpoints.baseUrl}/uploads/recetas/xxx.jpg?t=1234567
 *    = http://10.0.2.2:8000/uploads/recetas/xxx.jpg?t=1234567
 * 
 * 📍 EN RELEASE (APK):
 *    /uploads/recetas/xxx.jpg
 *    = URL relativa (funciona si ambos (app y backend) en mismo host)
 * 
 * El timestamp (?t=1234567) fuerza a Flutter a ignorar el caché del navegador
 * y siempre descargar la última versión de la imagen.
 * 
 * ============================================================================
 *                      SOLUCIÓN DE PROBLEMAS
 * ============================================================================
 * 
 * ❌ "Las imágenes no cargan en APK":
 * ├─ Verifica que el backend esté corriendo
 * ├─ Verifica que la IP local sea correcta (ping 192.168.x.x)
 * ├─ Abre los logs de Flutter: flutter logs
 * └─ Busca mensajes de ImageUrlHelper con fecha/hora del error
 * 
 * ❌ "Error: Connection refused":
 * ├─ El backend no está corriendo o no es accesible
 * ├─ Verifica la IP local: ipconfig
 * ├─ Verifica el puerto 8000 esté abierto
 * └─ Intenta: ping -c 3 192.168.x.x (verifica conectividad)
 * 
 * ❌ "HTTPS / Certificado no válido":
 * ├─ Si usas HTTPS, necesitas certificado válido
 * ├─ Para desarrollo local, usa HTTP
 * └─ (En production, necesitas certificado SSL válido)
 * 
 * ✅ "TODO FUNCIONA":
 * └─ ¡Felicidades! Ya puedes compilar APK para producción
 * 
 * ============================================================================
 *                      NOTAS IMPORTANTES
 * ============================================================================
 * 
 * • El helper es transparente: no necesitas cambiar código en los widgets
 * • Solo usamos URL relativa en RELEASE para máxima compatibilidad
 * • El timestamp previene problemas de caché
 * • Compatible con Emulador, Dispositivo Físico, Web y Servidor Remoto
 * • Si usas Firebase Storage, descomentar code en api_service.dart
 * 
 * ============================================================================
 */
