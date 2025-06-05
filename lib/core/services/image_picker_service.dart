import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen de la galería
  Future<String?> pickImageFromGallery() async {
    try {
      // Verificar permisos
      final permission = await _checkGalleryPermission();
      if (!permission) {
        throw Exception('Permiso de galería denegado');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      return image?.path;
    } catch (e) {
      throw Exception('Error al seleccionar imagen de galería: $e');
    }
  }

  /// Toma una foto con la cámara
  Future<String?> takePictureWithCamera() async {
    try {
      // Verificar permisos
      final permission = await _checkCameraPermission();
      if (!permission) {
        throw Exception('Permiso de cámara denegado');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      return image?.path;
    } catch (e) {
      throw Exception('Error al tomar foto: $e');
    }
  }

  /// Selecciona múltiples imágenes de la galería
  Future<List<String>> pickMultipleImages({int maxImages = 5}) async {
    try {
      // Verificar permisos
      final permission = await _checkGalleryPermission();
      if (!permission) {
        throw Exception('Permiso de galería denegado');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      // Limitar el número de imágenes
      final limitedImages = images.take(maxImages).toList();
      
      return limitedImages.map((image) => image.path).toList();
    } catch (e) {
      throw Exception('Error al seleccionar múltiples imágenes: $e');
    }
  }

  /// Verifica y solicita permiso para la galería
  Future<bool> _checkGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      // Android 13+ usa diferentes permisos
      if (androidInfo >= 33) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      if (status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    
    return true; // Para otras plataformas
  }

  /// Verifica y solicita permiso para la cámara
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  /// Obtiene la versión de Android
  Future<int> _getAndroidVersion() async {
    try {
      final androidInfo = await Permission.camera.status;
      // Esto es una simplificación, en un caso real usarías device_info_plus
      return 33; // Asume Android 13+
    } catch (e) {
      return 30; // Fallback a Android 11
    }
  }

  /// Muestra un diálogo para seleccionar el origen de la imagen
  static Future<String?> showImageSourceDialog({
    required Function() onCamera,
    required Function() onGallery,
  }) async {
    // Este método será usado desde el widget para mostrar opciones
    return null;
  }
}