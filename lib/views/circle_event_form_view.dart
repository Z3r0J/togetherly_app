import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_models.dart';
import '../models/circle_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/widgets.dart';
import '../viewmodels/circle_event_view_model.dart';
import '../viewmodels/circle_view_model.dart';
import 'location_picker_view.dart';

class CircleEventFormView extends StatefulWidget {
  final String? circleId;
  final VoidCallback onSuccess;

  const CircleEventFormView({
    super.key,
    this.circleId,
    required this.onSuccess,
  });

  @override
  State<CircleEventFormView> createState() => _CircleEventFormViewState();
}

class _CircleEventFormViewState extends State<CircleEventFormView> {
  final _eventTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().toLocal();
  TimeOfDay _startTime = TimeOfDay.fromDateTime(
    DateTime.now().toLocal().add(const Duration(hours: 1)),
  );
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().toLocal().add(const Duration(hours: 2)),
  );
  bool _enableTimePoll = false;
  Color _selectedColorTag = AppColors.primary;
  LocationModel? _selectedLocation;
  String? _selectedCircleId;

  final List<_TimeOption> _timeOptions = [
    _TimeOption(
      start: const TimeOfDay(hour: 19, minute: 0),
      end: const TimeOfDay(hour: 21, minute: 0),
    ),
  ];

  @override
  void dispose() {
    _eventTitleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CircleEventViewModel>();
    final circleVm = context.watch<CircleViewModel>();
    _selectedCircleId ??=
        widget.circleId ?? (circleVm.circles.isNotEmpty ? circleVm.circles.first.id : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Título del evento',
          hintText: 'Ej: Reunión de equipo',
          controller: _eventTitleController,
        ),
        const SizedBox(height: 20),
        _buildCircleSelector(circleVm),
        const SizedBox(height: 20),
        _buildDateTimeField(
          title: 'Fecha',
          value: _formatDate(_selectedDate),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildDateTimeField(
          title: 'Hora de inicio',
          value: _formatTime(_startTime),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _startTime,
            );
            if (picked != null) {
              setState(() => _startTime = picked);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildDateTimeField(
          title: 'Hora de fin',
          value: _formatTime(_endTime),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _endTime,
            );
            if (picked != null) {
              setState(() => _endTime = picked);
            }
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (context) => const LocationPickerView(),
              ),
            );
            if (result != null) {
              setState(() {
                _selectedLocation = LocationModel(
                  name: result['name'] as String,
                  latitude: result['latitude'] as double?,
                  longitude: result['longitude'] as double?,
                );
                _locationController.text = result['name'] as String;
              });
            }
          },
          child: AbsorbPointer(
            child: AppTextField(
              label: 'Ubicación',
              hintText: 'Ej: Sala de conferencias',
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
              suffixIcon: Icons.map,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Notas',
          hintText: 'Agrega más detalles...',
          controller: _notesController,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _buildTimePollSection(),
        const SizedBox(height: 24),
        _buildColorTagSection(),
        const SizedBox(height: 32),
        AppButton(
          text: 'Crear Evento de Círculo',
          type: AppButtonType.primary,
          fullWidth: true,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : _submitCircleEvent,
        ),
      ],
    );
  }

  Widget _buildCircleSelector(CircleViewModel circleVm) {
    final circles = circleVm.circles;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Círculo',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (circleVm.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton(
                  onPressed: () => circleVm.fetchCircles(),
                  child: const Text('Actualizar'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (circles.isEmpty)
            Text(
              'No tienes círculos disponibles',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedCircleId,
              items: circles
                  .map(
                    (Circle c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCircleId = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitCircleEvent() async {
    if (_eventTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un título para el evento'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final payload = <String, dynamic>{
      'circleId': _selectedCircleId,
      'title': _eventTitleController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'location': _selectedLocation?.toJson(),
      'color': _colorToHex(_selectedColorTag),
    };

    if (_enableTimePoll) {
      payload['timeOptions'] = _timeOptions
          .map(
            (o) => {
              'startTime': _combineDateAndTime(_selectedDate, o.start)
                  .toUtc()
                  .toIso8601String(),
              'endTime': _combineDateAndTime(_selectedDate, o.end)
                  .toUtc()
                  .toIso8601String(),
            },
          )
          .toList();
    } else {
      payload['startsAt'] =
          _combineDateAndTime(_selectedDate, _startTime)
              .toUtc()
              .toIso8601String();
      payload['endsAt'] = _combineDateAndTime(_selectedDate, _endTime)
          .toUtc()
          .toIso8601String();
    }

    try {
      await context.read<CircleEventViewModel>().create(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento creado con éxito'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear evento: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTimePollSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Encuesta de horarios',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _enableTimePoll,
                onChanged: (value) => setState(() => _enableTimePoll = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_enableTimePoll)
          Column(
            children: [
              ..._timeOptions.asMap().entries.map((entry) {
                final idx = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Opción ${idx + 1}',
                              style: AppTextStyles.labelMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _timeOptions.length > 1
                                  ? () {
                                      setState(() {
                                        _timeOptions.removeAt(idx);
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDateTimeField(
                          title: 'Inicio',
                          value: _formatTime(option.start),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: option.start,
                            );
                            if (picked != null) {
                              setState(() {
                                _timeOptions[idx] =
                                    option.copyWith(start: picked);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildDateTimeField(
                          title: 'Fin',
                          value: _formatTime(option.end),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: option.end,
                            );
                            if (picked != null) {
                              setState(() {
                                _timeOptions[idx] = option.copyWith(end: picked);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _timeOptions.add(
                      _TimeOption(
                        start: _startTime,
                        end: _endTime,
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar horario'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildColorTagSection() {
    final colors = [
      AppColors.circleRed,
      AppColors.circleGreen,
      AppColors.circleBlue,
      AppColors.circleYellow,
      AppColors.circlePurple,
      AppColors.circleOrange,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = _selectedColorTag == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorTag = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: AppColors.textPrimary, width: 2)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}

class _TimeOption {
  final TimeOfDay start;
  final TimeOfDay end;

  _TimeOption({required this.start, required this.end});

  _TimeOption copyWith({TimeOfDay? start, TimeOfDay? end}) {
    return _TimeOption(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
