// lib/features/profile/presentation/widgets/photo_management_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_picker_service.dart';
import '../cubit/profile_cubit.dart';

class PhotoManagementWidget extends StatefulWidget {
  final List<String> currentPhotos;
  final Function(List<String>) onPhotosChanged;

  const PhotoManagementWidget({
    Key? key,
    required this.currentPhotos,
    required this.onPhotosChanged,
  }) : super(key: key);

  @override
  State<PhotoManagementWidget> createState() => _PhotoManagementWidgetState();
}

class _PhotoManagementWidgetState extends State<PhotoManagementWidget> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  List<String> _photos = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.currentPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          if (_isUploading) _buildUploadingIndicator(),
          Expanded(child: _buildPhotoGrid()),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gestionar fotos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${_photos.length}/5',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Subiendo fotos...'),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: 5, // Máximo 5 fotos
        itemBuilder: (context, index) {
          if (index < _photos.length) {
            return _buildPhotoItem(_photos[index], index);
          } else {
            return _buildAddPhotoItem();
          }
        },
      ),
    );
  }

  Widget _buildPhotoItem(String photoUrl, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: index == 0 ? AppColors.primary : AppColors.borderLight,
              width: index == 0 ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceColor,
                child: const Icon(
                  Icons.image,
                  color: AppColors.textHint,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceColor,
                child: const Icon(
                  Icons.broken_image,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoItem() {
    return GestureDetector(
      onTap: _photos.length < 5 ? _showAddPhotoOptions : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight,
            style: BorderStyle.solid,
          ),
          color: AppColors.surfaceColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 32,
              color: _photos.length < 5 ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              'Agregar',
              style: TextStyle(
                fontSize: 12,
                color: _photos.length < 5 ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _savePhotos,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _takePicture();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Seleccionar de galería'),
                subtitle: const Text('Elegir foto existente'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.secondary),
                title: const Text('Seleccionar múltiples'),
                subtitle: const Text('Elegir varias fotos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultipleFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePicture() async {
    try {
      final imagePath = await _imagePickerService.takePictureWithCamera();
      if (imagePath != null) {
        await _uploadAndAddPhoto(imagePath);
      }
    } catch (e) {
      _showErrorSnackBar('Error al tomar foto: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final imagePath = await _imagePickerService.pickImageFromGallery();
      if (imagePath != null) {
        await _uploadAndAddPhoto(imagePath);
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar foto: $e');
    }
  }

  Future<void> _pickMultipleFromGallery() async {
    try {
      final remainingSlots = 5 - _photos.length;
      final imagePaths = await _imagePickerService.pickMultipleImages(
        maxImages: remainingSlots,
      );
      
      if (imagePaths.isNotEmpty) {
        await _uploadAndAddMultiplePhotos(imagePaths);
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar fotos: $e');
    }
  }

  Future<void> _uploadAndAddPhoto(String imagePath) async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Aquí usarías el ProfileCubit para subir la foto
      final photoUrls = await context.read<ProfileCubit>().uploadProfilePhotos([imagePath]);
      if (photoUrls.isNotEmpty) {
        setState(() {
          _photos.add(photoUrls.first);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al subir foto: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadAndAddMultiplePhotos(List<String> imagePaths) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final photoUrls = await context.read<ProfileCubit>().uploadProfilePhotos(imagePaths);
      setState(() {
        _photos.addAll(photoUrls);
      });
    } catch (e) {
      _showErrorSnackBar('Error al subir fotos: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _savePhotos() {
    widget.onPhotosChanged(_photos);
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}