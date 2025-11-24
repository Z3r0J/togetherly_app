import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/circle_view_model.dart';
import '../l10n/app_localizations.dart';

class CreateCircleView extends StatefulWidget {
  const CreateCircleView({super.key});

  @override
  State<CreateCircleView> createState() => _CreateCircleViewState();
}

class _CreateCircleViewState extends State<CreateCircleView> {
  final _circleNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final AppLocalizations l10n;
  bool _isLoading = false;

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
  String _selectedPrivacy = 'invite-only'; // 'invite-only' o 'public'

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.instance;
  }

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
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleCreateCircle,
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
          value: 'invite-only',
          title: 'Solo Invitaciones',
          description:
              'Los miembros solo pueden unirse mediante invitación directa.',
          isSelected: _selectedPrivacy == 'invite-only',
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

  void _handleCreateCircle() async {
    if (_circleNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('circle.error.CIRCLE_NAME_REQUIRED')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final circleViewModel = context.read<CircleViewModel>();

    // Map color to string name
    String colorName = 'purple';
    if (_selectedColor == AppColors.circleBlue) {
      colorName = 'blue';
    } else if (_selectedColor == AppColors.circleGreen) {
      colorName = 'green';
    } else if (_selectedColor == AppColors.circleOrange) {
      colorName = 'orange';
    } else if (_selectedColor == AppColors.circlePink) {
      colorName = 'pink';
    } else if (_selectedColor == AppColors.circleTeal) {
      colorName = 'teal';
    }

    final success = await circleViewModel.createCircle(
      name: _circleNameController.text,
      description: _descriptionController.text,
      color: colorName,
      privacy: _selectedPrivacy,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
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

      // Regresar a la vista anterior
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            circleViewModel.errorMessage ??
                l10n.tr('circle.message.create_failed'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
