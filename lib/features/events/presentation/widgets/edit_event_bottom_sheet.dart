// lib/features/events/presentation/widgets/edit_event_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/event.dart';
import '../cubit/events_cubit.dart';

class EditEventBottomSheet extends StatefulWidget {
  final Event event;

  const EditEventBottomSheet({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EditEventBottomSheet> createState() => _EditEventBottomSheetState();
}

class _EditEventBottomSheetState extends State<EditEventBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _maxParticipantsController = TextEditingController(text: widget.event.maxParticipants.toString());
    _tagsController = TextEditingController(text: widget.event.tags.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocListener<EventsCubit, EventsState>(
        listener: (context, state) {
          if (state is EventUpdated) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Evento actualizado exitosamente'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is EventsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventInfo(),
                      const SizedBox(height: 24),
                      _buildEditableFields(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getEventTypeColor(widget.event.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getEventTypeIcon(widget.event.type),
              color: _getEventTypeColor(widget.event.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar evento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getEventTypeLabel(widget.event.type),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Información del evento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Creado', _formatDate(widget.event.createdAt)),
          const SizedBox(height: 8),
          _buildInfoRow('Inicio', _formatDate(widget.event.startDate)),
          const SizedBox(height: 8),
          _buildInfoRow('Fin', _formatDate(widget.event.endDate)),
          const SizedBox(height: 8),
          _buildInfoRow('Campus', widget.event.campus),
          const SizedBox(height: 8),
          _buildInfoRow('Participantes actuales', '${widget.event.currentParticipants}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campos editables',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Título del evento',
          controller: _titleController,
          prefixIcon: Icons.event,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El título es requerido';
            }
            if (value.trim().length < 5) {
              return 'El título debe tener al menos 5 caracteres';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Descripción',
          controller: _descriptionController,
          prefixIcon: Icons.description,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es requerida';
            }
            if (value.trim().length < 20) {
              return 'La descripción debe tener al menos 20 caracteres';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Ubicación',
          controller: _locationController,
          prefixIcon: Icons.location_on,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La ubicación es requerida';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Máximo de participantes',
          controller: _maxParticipantsController,
          prefixIcon: Icons.people,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El número máximo de participantes es requerido';
            }
            final number = int.tryParse(value);
            if (number == null || number < 1) {
              return 'Debe ser un número mayor a 0';
            }
            if (number < widget.event.currentParticipants) {
              return 'No puede ser menor a los participantes actuales (${widget.event.currentParticipants})';
            }
            if (number > 500) {
              return 'El máximo permitido es 500 participantes';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Etiquetas',
          hint: 'Separa las etiquetas con comas',
          controller: _tagsController,
          prefixIcon: Icons.tag,
          maxLines: 2,
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nota: Las fechas, tipo de evento y campus no se pueden modificar después de la creación.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final isLoading = state is EventsLoading;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancelar',
                  type: ButtonType.outline,
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Guardar cambios',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _updateEvent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateEvent() {
    if (!_formKey.currentState!.validate()) return;

    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final maxParticipants = int.parse(_maxParticipantsController.text);

    context.read<EventsCubit>().updateEventById(
      eventId: widget.event.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      maxParticipants: maxParticipants,
      tags: tags,
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
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

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.academic:
        return AppColors.info;
      case EventType.sports:
        return AppColors.warning;
      case EventType.cultural:
        return AppColors.secondary;
      case EventType.networking:
        return AppColors.success;
      case EventType.social:
        return AppColors.primary;
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