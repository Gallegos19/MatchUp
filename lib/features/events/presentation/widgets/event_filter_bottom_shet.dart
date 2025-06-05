// lib/features/events/presentation/widgets/event_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';
import '../cubit/events_cubit.dart';

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
    'Hackathon',
    'Competencia',
    'Social',
    'Workshop',
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
          _buildDragIndicator(),
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
                  const SizedBox(height: 24),
                  _buildQuickFilters(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildDragIndicator() {
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
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
              'Limpiar todo',
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
        Row(
          children: [
            const Icon(Icons.category, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Tipo de evento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_selectedType != null) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1 seleccionado',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getEventTypeIcon(type),
                    size: 16,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(_getEventTypeLabel(type)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : null;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
              ),
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
        Row(
          children: [
            const Icon(Icons.school, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Campus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_selectedCampus != null) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1 seleccionado',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
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
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.info : AppColors.borderLight,
              ),
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
        Row(
          children: [
            const Icon(Icons.tag, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Etiquetas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_selectedTags.isNotEmpty) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedTags.length} seleccionadas',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tagOptions.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text('#$tag'),
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
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.secondary : AppColors.borderLight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Filtros rápidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip(
              'Eventos de hoy',
              Icons.today,
              () => _applyQuickFilter('today'),
            ),
            _buildQuickFilterChip(
              'Esta semana',
              Icons.date_range,
              () => _applyQuickFilter('week'),
            ),
            _buildQuickFilterChip(
              'Disponibles',
              Icons.event_available,
              () => _applyQuickFilter('available'),
            ),
            _buildQuickFilterChip(
              'Mi campus',
              Icons.location_on,
              () => _applyQuickFilter('my_campus'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.warning),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final isLoading = state is EventsLoading;
        final hasFilters = _selectedType != null || 
                          _selectedCampus != null || 
                          _selectedTags.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              if (hasFilters) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filtros activos: ${_getActiveFiltersCount()}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderMedium),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Text(
                            'Aplicar filtros',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCampus = null;
      _selectedTags.clear();
    });
  }

  void _applyFilters() {
    context.read<EventsCubit>().applyFilters(
      campus: _selectedCampus,
      type: _selectedType,
      tags: _selectedTags.isNotEmpty ? _selectedTags : null,
    );
    Navigator.of(context).pop();
  }

  void _applyQuickFilter(String filterType) {
    switch (filterType) {
      case 'today':
        // Apply filter for today's events
        _showSnackBar('Filtro aplicado: Eventos de hoy');
        break;
      case 'week':
        // Apply filter for this week's events
        _showSnackBar('Filtro aplicado: Eventos de esta semana');
        break;
      case 'available':
        // Apply filter for available events
        _showSnackBar('Filtro aplicado: Solo eventos disponibles');
        break;
      case 'my_campus':
        setState(() {
          _selectedCampus = 'Suchiapa'; // Default campus
        });
        _showSnackBar('Filtro aplicado: Campus Suchiapa');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedType != null) count++;
    if (_selectedCampus != null) count++;
    if (_selectedTags.isNotEmpty) count += _selectedTags.length;
    return count;
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

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.academic:
        return Icons.school;
      case EventType.sports:
        return Icons.sports_soccer;
      case EventType.cultural:
        return Icons.palette;
      case EventType.networking:
        return Icons.people;
      case EventType.social:
        return Icons.celebration;
    }
  }
}