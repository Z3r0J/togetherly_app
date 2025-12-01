import 'package:flutter/material.dart';
import '../models/circle_models.dart';
import '../models/api_error.dart';
import '../services/circle_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/widgets.dart';

class JoinCircleView extends StatefulWidget {
  final String shareToken;

  const JoinCircleView({super.key, required this.shareToken});

  @override
  State<JoinCircleView> createState() => _JoinCircleViewState();
}

class _JoinCircleViewState extends State<JoinCircleView> {
  final CircleService _circleService = CircleService();
  CircleSharePreview? _circlePreview;
  bool _isLoading = true;
  bool _isJoining = false;
  ApiError? _error;

  @override
  void initState() {
    super.initState();
    _loadCircleDetails();
  }

  Future<void> _loadCircleDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final preview = await _circleService.getCircleByShareToken(
        widget.shareToken,
      );
      setState(() {
        _circlePreview = preview;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiError ? e : ApiError.unknownError(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _handleJoinCircle() async {
    if (_isJoining) return;

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final result = await _circleService.joinCircleViaShareLink(
        widget.shareToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back and refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e is ApiError ? e : ApiError.unknownError(e.toString());
        _isJoining = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error?.message ?? 'Error al unirse al círculo'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getCircleColor() {
    final colorStr = _circlePreview?.color;
    if (colorStr != null) {
      return AppColors.hexToColor(colorStr);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Unirse a círculo', style: AppTextStyles.headlineMedium),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _error != null
          ? _buildErrorState()
          : _buildCirclePreview(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Reintentar',
              type: AppButtonType.primary,
              onPressed: _loadCircleDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCirclePreview() {
    if (_circlePreview == null) return const SizedBox.shrink();

    final circleColor = _getCircleColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Circle Icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: circleColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: circleColor, width: 3),
              ),
              child: Icon(Icons.group, size: 60, color: circleColor),
            ),
          ),
          const SizedBox(height: 24),

          // Circle Name
          Text(
            _circlePreview!.name,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Owner Name
          Text(
            'Creado por ${_circlePreview!.ownerName}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Description
          if (_circlePreview!.description != null &&
              _circlePreview!.description!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descripción',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _circlePreview!.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Al unirte, podrás ver y participar en todos los eventos del círculo.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Join Button
          AppButton(
            text: _isJoining ? 'Uniéndose...' : 'Unirse al círculo',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: _isJoining ? null : _handleJoinCircle,
            icon: _isJoining ? null : Icons.group_add,
          ),
          const SizedBox(height: 12),

          // Cancel Button
          AppButton(
            text: 'Cancelar',
            type: AppButtonType.outline,
            fullWidth: true,
            onPressed: _isJoining
                ? null
                : () {
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
    );
  }
}
