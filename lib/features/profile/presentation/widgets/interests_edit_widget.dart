// lib/features/profile/presentation/widgets/interests_edit_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InterestsEditWidget extends StatefulWidget {
  final List<String> currentInterests;
  final Function(List<String>) onInterestsChanged;

  const InterestsEditWidget({
    Key? key,
    required this.currentInterests,
    required this.onInterestsChanged,
  }) : super(key: key);

  @override
  State<InterestsEditWidget> createState() => _InterestsEditWidgetState();
}

class _InterestsEditWidgetState extends State<InterestsEditWidget> {
  late List<String> _selectedInterests;
  final TextEditingController _customInterestController = TextEditingController();

  // Lista de intereses predefinidos
  final List<String> _availableInterests = [
    // Académicos
    'Programación', 'Matemáticas', 'Física', 'Química', 'Biología',
    'Historia', 'Literatura', 'Filosofía', 'Arte', 'Música',
    'Idiomas', 'Ingeniería', 'Medicina', 'Derecho', 'Economía',
    
    // Deportes
    'Fútbol', 'Basquetbol', 'Tenis', 'Natación', 'Correr',
    'Ciclismo', 'Yoga', 'Gimnasio', 'Volleyball', 'Béisbol',
    
    // Entretenimiento
    'Cine', 'Series', 'Videojuegos', 'Anime', 'Lectura',
    'Fotografía', 'Baile', 'Teatro', 'Podcasts', 'YouTube',
    
    // Tecnología
    'Inteligencia Artificial', 'Desarrollo Web', 'Aplicaciones Móviles',
    'Robótica', 'Ciberseguridad', 'Blockchain', 'Data Science',
    
    // Hobbies
    'Cocinar', 'Jardinería', 'Manualidades', 'Coleccionar',
    'Viajar', 'Camping', 'Senderismo', 'Pesca', 'Pintura',
    
    // Sociales
    'Voluntariado', 'Networking', 'Emprendimiento', 'Debate',
    'Clubs estudiantiles', 'Organizaciones', 'Eventos',
  ];

  @override
  void initState() {
    super.initState();
    _selectedInterests = List.from(widget.currentInterests);
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildSelectedInterests(),
          _buildCustomInterestInput(),
          Expanded(child: _buildAvailableInterests()),
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
            'Mis Intereses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${_selectedInterests.length}/10',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedInterests() {
    if (_selectedInterests.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textHint),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selecciona al menos 3 intereses para ayudar a otros a conocerte mejor',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionados:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedInterests.map((interest) {
              return Chip(
                label: Text(interest),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeInterest(interest),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                deleteIconColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInterestInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customInterestController,
              decoration: InputDecoration(
                hintText: 'Agregar interés personalizado...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  onPressed: _addCustomInterest,
                  icon: const Icon(Icons.add, color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => _addCustomInterest(),
              maxLength: 25,
              textCapitalization: TextCapitalization.words,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableInterests() {
    final groupedInterests = _groupInterestsByCategory();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedInterests.length,
      itemBuilder: (context, index) {
        final category = groupedInterests.keys.elementAt(index);
        final interests = groupedInterests[category]!;
        
        return _buildInterestCategory(category, interests);
      },
    );
  }

  Map<String, List<String>> _groupInterestsByCategory() {
    return {
      'Académicos': _availableInterests.sublist(0, 15),
      'Deportes': _availableInterests.sublist(15, 25),
      'Entretenimiento': _availableInterests.sublist(25, 35),
      'Tecnología': _availableInterests.sublist(35, 42),
      'Hobbies': _availableInterests.sublist(42, 51),
      'Sociales': _availableInterests.sublist(51),
    };
  }

  Widget _buildInterestCategory(String category, List<String> interests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _addInterest(interest);
                } else {
                  _removeInterest(interest);
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons() {
    final canSave = _selectedInterests.length >= 3;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!canSave)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecciona al menos 3 intereses',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
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
                  onPressed: canSave ? _saveInterests : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textHint,
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addInterest(String interest) {
    if (_selectedInterests.length < 10 && !_selectedInterests.contains(interest)) {
      setState(() {
        _selectedInterests.add(interest);
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _selectedInterests.remove(interest);
    });
  }

  void _addCustomInterest() {
    final customInterest = _customInterestController.text.trim();
    if (customInterest.isNotEmpty && !_selectedInterests.contains(customInterest)) {
      _addInterest(customInterest);
      _customInterestController.clear();
    }
  }

  void _saveInterests() {
    widget.onInterestsChanged(_selectedInterests);
    Navigator.pop(context);
  }
}