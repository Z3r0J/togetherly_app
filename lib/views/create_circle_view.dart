import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class CreateCircleView extends StatefulWidget {
  const CreateCircleView({super.key});

  @override
  State<CreateCircleView> createState() => _CreateCircleViewState();
}

class _CreateCircleViewState extends State<CreateCircleView> {
  final _circleNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Colores disponibles para el círculo
  final List<Color> _availableColors = [
    AppColors.circlePurple,
    AppColors.circleBlue,
    AppColors.circleGreen,
    AppColors.circleOrange,
    AppColors.circlePink,
    AppColors.circleTeal,
  ];

  Color _selectedColor = AppColors.circlePurple;
  String _selectedPrivacy = 'inviteOnly'; // 'inviteOnly' o 'public'

  @override
  void dispose() {
    _circleNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Crear Círculo',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        leadingWidth: 100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del Círculo
            _buildCircleNameField(),

            const SizedBox(height: 32),

            // Color del Círculo
            _buildCircleColorSection(),

            const SizedBox(height: 32),

            // Descripción
            _buildDescriptionField(),

            const SizedBox(height: 32),

            // Privacidad
            _buildPrivacySection(),

            const SizedBox(height: 48),

            // Botón Crear Círculo
            AppButton(
              text: 'Crear Círculo',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _handleCreateCircle,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleNameField() {
    return AppTextField(
      label: 'Nombre del Círculo',
      hintText: 'Ingresa un nombre para tu círculo',
      controller: _circleNameController,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildCircleColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color del Círculo', style: AppTextStyles.titleSmall),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return AppTextField(
      label: 'Descripción (opcional)',
      hintText: '¿Para qué es este círculo?...',
      controller: _descriptionController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacidad', style: AppTextStyles.titleSmall),
        const SizedBox(height: 16),

        // Opción: Solo invitaciones
        _buildPrivacyOption(
          value: 'inviteOnly',
          title: 'Solo Invitaciones',
          description:
              'Los miembros solo pueden unirse mediante invitación directa.',
          isSelected: _selectedPrivacy == 'inviteOnly',
        ),

        const SizedBox(height: 16),

        // Opción: Público
        _buildPrivacyOption(
          value: 'public',
          title: 'Público',
          description: 'Cualquier persona con el enlace puede unirse.',
          isSelected: _selectedPrivacy == 'public',
        ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required String value,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrivacy = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateCircle() {
    if (_circleNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para el círculo'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Círculo "${_circleNameController.text}" creado exitosamente!',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Regresar a la vista anterior después de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
