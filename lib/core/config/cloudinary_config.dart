// lib/core/config/cloudinary_config.dart
class CloudinaryConfig {
  // IMPORTANTE: Reemplaza estos valores con los de tu cuenta de Cloudinary
  static const String cloudName = 'MatchUp'; // Reemplaza con tu Cloud Name
  static const String apiKey = '113663299157765';
  static const String apiSecret = '7ThtjKxpF4MS0KPHPW1SZ_EtKx8';
  
  // Para unsigned uploads (más fácil de configurar)
  static const String uploadPreset = 'your_upload_preset';
  
  // Configuraciones de carpetas
  static const String profilePhotosFolder = 'matchup/profiles';
  static const String eventPhotosFolder = 'matchup/events';
  
  // Configuraciones de transformación
  static const int defaultMaxWidth = 800;
  static const int defaultMaxHeight = 800;
  static const int defaultQuality = 85;
  
  // URLs base
  static String get uploadUrl => 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  static String get deleteUrl => 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';
  
  /// Genera una URL optimizada para mostrar imágenes
  static String getOptimizedUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    transformations.add('c_fill'); // Crop to fill maintaining aspect ratio
    
    final transformationString = transformations.join(',');
    
    return 'https://res.cloudinary.com/$cloudName/image/upload/$transformationString/$publicId';
  }
}

/*
INSTRUCCIONES PARA CONFIGURAR CLOUDINARY:

1. Crea una cuenta gratuita en https://cloudinary.com
2. Ve a tu Dashboard y copia:
   - Cloud Name
   - API Key  
   - API Secret

3. Para unsigned uploads (recomendado para desarrollo):
   - Ve a Settings > Upload
   - Crea un nuevo Upload Preset
   - Configúralo como "Unsigned"
   - Copia el nombre del preset

4. Reemplaza los valores en esta clase con los tuyos

5. Configuración de seguridad para producción:
   - Usa variables de entorno
   - Configura restricciones de upload
   - Implementa signed uploads para mayor seguridad

EJEMPLO de .env (no incluir en git):
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
*/