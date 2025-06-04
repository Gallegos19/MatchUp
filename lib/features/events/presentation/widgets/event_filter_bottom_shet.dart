// lib/features/events/presentation/widgets/event_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';

class EventFilterBottomSheet extends StatefulWidget {
  const EventFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<EventFilterBottomSheet> createState() => _EventFilterBottomSheetState();
}

class _EventFilterBottomSheetState extends State<EventFilterBottomSheet> {
  EventType? _selectedType;
  String? _selectedCampus;
  final List<String> _selectedTags = [];

  final List<String> _campusOptions = [
    'Tuxtla Gutiérrez',
    'Suchiapa',
    'Tapachula',
    'Comitán',
    'San Cristóbal',
  ];

  final List<String> _tagOptions = [
    'Programación',
    'Deportes',
    'Arte',
    'Música',
    'Networking',
    'Gaming',
    'Estudio',
    'Cultura',
  ];

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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  _buildCampusFilter(),
                  const SizedBox(height: 24),
                  _buildTagsFilter(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Limpiar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de evento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(_getEventTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : null;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCampusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _campusOptions.map((campus) {
            final isSelected = _selectedCampus == campus;
            return FilterChip(
              label: Text(campus),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCampus = selected ? campus : null;
                });
              },
              selectedColor: AppColors.info.withOpacity(0.2),
              checkmarkColor: AppColors.info,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etiquetas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tagOptions.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.secondary.withOpacity(0.2),
              checkmarkColor: AppColors.secondary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Aplicar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCampus = null;
      _selectedTags.clear();
    });
  }

  void _applyFilters() {
    // TODO: Apply filters through cubit
    Navigator.of(context).pop();
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.academic:
        return 'Académico';
      case EventType.sports:
        return 'Deportes';
      case EventType.cultural:
        return 'Cultural';
      case EventType.networking:
        return 'Networking';
      case EventType.social:
        return 'Social';
    }
  }
}