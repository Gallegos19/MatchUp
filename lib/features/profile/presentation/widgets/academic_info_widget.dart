// lib/features/profile/presentation/widgets/academic_info_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';

class AcademicInfoWidget extends StatefulWidget {
  final String? currentCareer;
  final String? currentSemester;
  final String? currentCampus;
  final Function(String? career, String? semester, String? campus) onInfoChanged;

  const AcademicInfoWidget({
    Key? key,
    this.currentCareer,
    this.currentSemester,
    this.currentCampus,
    required this.onInfoChanged,
  }) : super(key: key);

  @override
  State<AcademicInfoWidget> createState() => _AcademicInfoWidgetState();
}

class _AcademicInfoWidgetState extends State<AcademicInfoWidget> {
  final _formKey = GlobalKey<FormState>();
  final _careerController = TextEditingController();
  late String _selectedSemester;
  late String _selectedCampus;

  final List<String> _campusOptions = [
    'Tuxtla Gutiérrez',
    'Suchiapa',
    'Tapachula',
    'Comitán',
    'San Cristóbal de las Casas',
    'Palenque',
    'Tonalá',
    'Pichucalco',
    'Arriaga',
  ];

  final List<String> _semesterOptions = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
  ];

  final List<String> _careerSuggestions = [
    // Ingenierías
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería en Software',
    'Ingeniería Civil',
    'Ingeniería Industrial',
    'Ingeniería en Mecatrónica',
    'Ingeniería Química',
    'Ingeniería en Electrónica',
    'Ingeniería Ambiental',
    'Ingeniería en Gestión Empresarial',
    'Ingeniería en Logística',
    'Ingeniería Biomédica',
    'Ingeniería en Desarrollo de Software',
    
    // Licenciaturas
    'Licenciatura en Administración',
    'Licenciatura en Contaduría Pública',
    'Licenciatura en Derecho',
    'Licenciatura en Psicología',
    'Licenciatura en Medicina',
    'Licenciatura en Enfermería',
    'Licenciatura en Nutrición',
    'Licenciatura en Educación',
    'Licenciatura en Comunicación',
    'Licenciatura en Diseño Gráfico',
    'Licenciatura en Marketing',
    'Licenciatura en Turismo',
    'Licenciatura en Gastronomía',
    'Licenciatura en Arquitectura',
    'Licenciatura en Biología',
    'Licenciatura en Química',
    'Licenciatura en Física',
    'Licenciatura en Matemáticas',
    'Licenciatura en Historia',
    'Licenciatura en Filosofía',
    'Licenciatura en Literatura',
    'Licenciatura en Idiomas',
    
    // Técnico Superior Universitario
    'TSU en Desarrollo de Software',
    'TSU en Redes Digitales',
    'TSU en Mecatrónica',
    'TSU en Administración',
    'TSU en Contaduría',
    'TSU en Turismo',
    'TSU en Gastronomía',
  ];

  @override
  void initState() {
    super.initState();
    _careerController.text = widget.currentCareer ?? '';
    _selectedSemester = widget.currentSemester ?? '1';
    _selectedCampus = widget.currentCampus ?? _campusOptions.first;
  }

  @override
  void dispose() {
    _careerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(child: _buildForm()),
            _buildActionButtons(),
          ],
        ),
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
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Información Académica',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Carrera con autocompletado
          _buildCareerField(),
          
          const SizedBox(height: 20),
          
          // Semestre
          _buildSemesterDropdown(),
          
          const SizedBox(height: 20),
          
          // Campus
          _buildCampusDropdown(),
          
          const SizedBox(height: 20),
          
          // Información adicional
          _buildInfoCard(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCareerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Carrera',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: _careerController.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _careerSuggestions.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            _careerController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return CustomTextField(
              controller: controller,
              focusNode: focusNode,
              hint: 'Ej: Ingeniería en Software',
              prefixIcon: Icons.school_outlined,
              validator: Validators.validateCareer,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSemesterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semestre',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSemester,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.textHint),
            ),
            items: _semesterOptions.map((semester) {
              return DropdownMenuItem(
                value: semester,
                child: Text('$semesterº Semestre'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSemester = value ?? '1';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCampusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCampus,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.location_on, color: AppColors.textHint),
            ),
            items: _campusOptions.map((campus) {
              return DropdownMenuItem(
                value: campus,
                child: Text(campus),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCampus = value ?? _campusOptions.first;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
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
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              SizedBox(width: 8),
              Text(
                'Información importante',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Esta información ayuda a otros estudiantes a encontrarte\n'
            '• Solo se mostrará a estudiantes de tu misma universidad\n'
            '• Puedes actualizar estos datos en cualquier momento',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
              onPressed: _saveAcademicInfo,
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

  void _saveAcademicInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onInfoChanged(
        _careerController.text.trim(),
        _selectedSemester,
        _selectedCampus,
      );
      Navigator.pop(context);
    }
  }
}