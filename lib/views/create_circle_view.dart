import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/circle_view_model.dart';
import '../l10n/app_localizations.dart';

class CreateCircleView extends StatefulWidget {
  final String? circleId;
  final String? circleName;
  final Color? circleColor;
  final String? description;
  final String? privacy;

  // Constructor para crear nuevo círculo
  const CreateCircleView({super.key})
    : circleId = null,
      circleName = null,
      circleColor = null,
      description = null,
      privacy = null;

  // Constructor para editar círculo existente
  const CreateCircleView.edit({
    super.key,
    required this.circleId,
    required this.circleName,
    required this.circleColor,
    this.description,
    this.privacy,
  });

  @override
  State<CreateCircleView> createState() => _CreateCircleViewState();
}

class _CreateCircleViewState extends State<CreateCircleView> {
  final _circleNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final AppLocalizations l10n;
  bool _isLoading = false;
  late bool _isEditMode;

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

    // Determinar si estamos en modo edición
    _isEditMode = widget.circleId != null;

    // Si estamos editando, precarga los datos
    if (_isEditMode) {
      print('🔄 [INIT STATE] Loading edit mode with data:');
      print('   - Name: ${widget.circleName}');
      print('   - Description: ${widget.description}');
      print('   - Privacy: ${widget.privacy}');
      print('   - Color: ${widget.circleColor}');

      _circleNameController.text = widget.circleName ?? '';
      _descriptionController.text = widget.description ?? '';
      _selectedColor = widget.circleColor ?? AppColors.circlePurple;
      _selectedPrivacy = widget.privacy ?? 'invite-only';

      print('✅ [INIT STATE] Data loaded into form fields');
    }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        title: Text(
          _isEditMode
              ? l10n.tr('circle.create.dialog.title_edit')
              : l10n.tr('circle.create.dialog.title_create'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.tr('circle.create.dialog.cancel'),
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

            // Botones de acción
            if (_isEditMode)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.tr('circle.create.dialog.delete'),
                      type: AppButtonType.secondary,
                      onPressed: _isLoading ? null : _handleDeleteCircle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: l10n.tr('circle.create.button.save'),
                      type: AppButtonType.primary,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleSaveCircle,
                    ),
                  ),
                ],
              )
            else
              AppButton(
                text: l10n.tr('circle.create.button.create'),
                type: AppButtonType.primary,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleSaveCircle,
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleNameField() {
    final l10n = AppLocalizations.instance;
    return AppTextField(
      label: l10n.tr('circle.create.label.name'),
      hintText: l10n.tr('circle.create.hint.name'),
      controller: _circleNameController,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildCircleColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tr('circle.create.label.color'),
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: 12),
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
                        ? Icon(Icons.check, color: Colors.white, size: 24)
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
    final l10n = AppLocalizations.instance;
    return AppTextField(
      label: l10n.tr('circle.create.label.description'),
      hintText: l10n.tr('circle.create.hint.description'),
      controller: _descriptionController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
    );
  }

  Widget _buildPrivacySection() {
    final l10n = AppLocalizations.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tr('circle.create.label.privacy'),
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: 16),

        // Opción: Solo invitaciones
        _buildPrivacyOption(
          value: 'invite-only',
          title: l10n.tr('circle.create.privacy.invite_only'),
          description: l10n.tr('circle.create.privacy.invite_only_desc'),
          isSelected: _selectedPrivacy == 'invite-only',
        ),

        const SizedBox(height: 16),

        // Opción: Público
        _buildPrivacyOption(
          value: 'public',
          title: l10n.tr('circle.create.privacy.public'),
          description: l10n.tr('circle.create.privacy.public_desc'),
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline,
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
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outline,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  void _handleSaveCircle() async {
    if (_isEditMode) {
      _handleUpdateCircle();
    } else {
      _handleCreateCircle();
    }
  }

  void _handleCreateCircle() async {
    print('🔵 [CREATE CIRCLE] Starting circle creation process');

    if (_circleNameController.text.isEmpty) {
      print('❌ [CREATE CIRCLE] Validation failed: Circle name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('circle.error.CIRCLE_NAME_REQUIRED')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print('✅ [CREATE CIRCLE] Validation passed');
    print('   - Circle Name: ${_circleNameController.text}');
    print('   - Description: ${_descriptionController.text}');
    print('   - Privacy: $_selectedPrivacy');

    setState(() {
      _isLoading = true;
    });

    final circleViewModel = context.read<CircleViewModel>();

    // Convert color to hex format
    String colorHex = _colorToHex(_selectedColor);

    print('   - Color: $colorHex');
    print('📤 [CREATE CIRCLE] Calling circleViewModel.createCircle()...');

    final success = await circleViewModel.createCircle(
      name: _circleNameController.text,
      description: _descriptionController.text,
      color: colorHex,
      privacy: _selectedPrivacy,
    );

    print(
      '📥 [CREATE CIRCLE] API response received: ${success ? "SUCCESS" : "FAILED"}',
    );
    if (!success) {
      print('   Error message: ${circleViewModel.errorMessage}');
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      print('✅ [CREATE CIRCLE] Circle created successfully!');
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .tr('circle.create.success')
                .replaceAll('{name}', _circleNameController.text),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Regresar a la vista anterior
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('🔙 [CREATE CIRCLE] Navigating back to dashboard');
          Navigator.pop(context, true);
        }
      });
    } else {
      print('❌ [CREATE CIRCLE] Circle creation failed');
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

  void _handleUpdateCircle() async {
    print('🔵 [UPDATE CIRCLE] Starting circle update process');

    if (_circleNameController.text.isEmpty) {
      print('❌ [UPDATE CIRCLE] Validation failed: Circle name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('circle.error.CIRCLE_NAME_REQUIRED')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print('✅ [UPDATE CIRCLE] Validation passed');
    print('   - Circle ID: ${widget.circleId}');
    print('   - Circle Name: ${_circleNameController.text}');
    print('   - Description: ${_descriptionController.text}');
    print('   - Privacy: $_selectedPrivacy');

    setState(() {
      _isLoading = true;
    });

    final circleViewModel = context.read<CircleViewModel>();

    // Convert color to hex format
    String colorHex = _colorToHex(_selectedColor);

    print('   - Color: $colorHex');
    print('📤 [UPDATE CIRCLE] Calling circleViewModel.updateCircle()...');

    final success = await circleViewModel.updateCircle(
      circleId: widget.circleId!,
      name: _circleNameController.text,
      description: _descriptionController.text,
      color: colorHex,
      privacy: _selectedPrivacy,
    );

    print(
      '📥 [UPDATE CIRCLE] API response received: ${success ? "SUCCESS" : "FAILED"}',
    );
    if (!success) {
      print('   Error message: ${circleViewModel.errorMessage}');
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      print('✅ [UPDATE CIRCLE] Circle updated successfully!');
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('circle.create.update_success')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Regresar a la vista anterior (CircleDetailView se refrescará automáticamente)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('🔙 [UPDATE CIRCLE] Navigating back to circle detail');
          Navigator.pop(context, true);
        }
      });
    } else {
      print('❌ [UPDATE CIRCLE] Circle update failed');
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            circleViewModel.errorMessage ??
                l10n.tr('circle.message.update_failed'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDeleteCircle() async {
    print('🔵 [DELETE CIRCLE] Starting circle deletion confirmation');

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        title: Text(l10n.tr('circle.create.dialog.delete_title')),
        content: Text(
          l10n.tr('circle.create.dialog.delete_message'),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.tr('circle.create.dialog.cancel'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedWithDelete();
            },
            child: Text(
              l10n.tr('circle.create.dialog.delete'),
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedWithDelete() async {
    print('✅ [DELETE CIRCLE] User confirmed deletion');
    print('   - Circle ID: ${widget.circleId}');

    setState(() {
      _isLoading = true;
    });

    final circleViewModel = context.read<CircleViewModel>();

    print('📤 [DELETE CIRCLE] Calling circleViewModel.deleteCircle()...');

    final success = await circleViewModel.deleteCircle(widget.circleId!);

    print(
      '📥 [DELETE CIRCLE] API response received: ${success ? "SUCCESS" : "FAILED"}',
    );
    if (!success) {
      print('   Error message: ${circleViewModel.errorMessage}');
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      print('✅ [DELETE CIRCLE] Circle deleted successfully!');
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('circle.detail.delete_success')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Regresar dos veces (cerrar edit y luego circle detail)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('🔙 [DELETE CIRCLE] Navigating back to my circles');
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      });
    } else {
      print('❌ [DELETE CIRCLE] Circle deletion failed');
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            circleViewModel.errorMessage ??
                l10n.tr('circle.message.delete_failed'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper para convertir Color a hex format
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
