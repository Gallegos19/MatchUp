// lib/core/services/cloudinary_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import '../config/cloudinary_config.dart';

class CloudinaryService {
  final Dio _dio;

  CloudinaryService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Sube una imagen a Cloudinary y retorna la URL
  Future<String> uploadImage(
    String imagePath, {
    String folder = 'matchup/profiles',
    int? maxWidth = 800,
    int? maxHeight = 800,
    int quality = 85,
  }) async {
    try {
      // Comprimir imagen antes de subir
      final compressedImagePath = await _compressImage(
        imagePath,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );

      // Preparar datos para la subida
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(compressedImagePath),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'folder': folder,
        'resource_type': 'image',
      });

      // URL para unsigned upload (más fácil para desarrollo)
      final uploadUrl = CloudinaryConfig.uploadUrl;

      final response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['secure_url'] as String;
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen a Cloudinary: $e');
    }
  }

  /// Sube múltiples imágenes de forma paralela
  Future<List<String>> uploadMultipleImages(
    List<String> imagePaths, {
    String folder = 'matchup/profiles',
    int? maxWidth = 800,
    int? maxHeight = 800,
    int quality = 85,
  }) async {
    try {
      final futures = imagePaths.map((imagePath) => uploadImage(
        imagePath,
        folder: folder,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      ));

      return await Future.wait(futures);
    } catch (e) {
      throw Exception('Error al subir múltiples imágenes: $e');
    }
  }

  /// Elimina una imagen de Cloudinary usando su public_id
  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature({
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      });

      final formData = FormData.fromMap({
        'public_id': publicId,
        'api_key': CloudinaryConfig.apiKey,
        'timestamp': timestamp,
        'signature': signature,
      });

      final deleteUrl = CloudinaryConfig.deleteUrl;

      final response = await _dio.post(deleteUrl, data: formData);

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar imagen de Cloudinary: $e');
    }
  }

  /// Comprime una imagen para optimizar la subida
  Future<String> _compressImage(
    String imagePath, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      final originalFile = File(imagePath);
      final image = img.decodeImage(await originalFile.readAsBytes());

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es necesario
      img.Image resizedImage = image;
      if (maxWidth != null || maxHeight != null) {
        resizedImage = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          maintainAspect: true,
        );
      }

      // Comprimir y guardar
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      final tempDir = Directory.systemTemp;
      final fileName = 'compressed_${path.basename(imagePath)}';
      final compressedFile = File('${tempDir.path}/$fileName');
      
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile.path;
    } catch (e) {
      // Si falla la compresión, devolver la imagen original
      return imagePath;
    }
  }

  /// Genera firma para operaciones autenticadas
  String _generateSignature(Map<String, String> params) {
    // Ordenar parámetros alfabéticamente
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Crear string de parámetros
    final paramString = sortedParams.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    // Agregar API secret al final
    final stringToSign = '$paramString${CloudinaryConfig.apiSecret}';

    // Generar hash SHA1
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  /// Extrae el public_id de una URL de Cloudinary
  String extractPublicIdFromUrl(String url) {
    // Ejemplo: https://res.cloudinary.com/demo/image/upload/v1234567890/folder/image.jpg
    // Public ID sería: folder/image
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    // Buscar el índice después de 'upload'
    final uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
      // Saltar 'upload' y version (v1234567890)
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final fullPath = publicIdParts.join('/');
      
      // Remover extensión del archivo
      return fullPath.replaceAll(RegExp(r'\.[^.]+$'), '');
    }
    
    throw Exception('No se pudo extraer public_id de la URL');
  }
}