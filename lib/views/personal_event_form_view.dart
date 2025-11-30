import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/widgets.dart';
import '../viewmodels/personal_event_view_model.dart';
import 'location_picker_view.dart';

class PersonalEventFormView extends StatefulWidget {
  final VoidCallback onSuccess;

  const PersonalEventFormView({super.key, required this.onSuccess});

  @override
  State<PersonalEventFormView> createState() => _PersonalEventFormViewState();
}

class _PersonalEventFormViewState extends State<PersonalEventFormView> {
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
  bool _isAllDay = false;
  String _selectedReminder = 'Ninguno';
  Color _selectedColorTag = AppColors.primary;
  LocationModel? _selectedLocation;

  @override
  void dispose() {
    _eventTitleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PersonalEventViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Título del evento',
          hintText: 'Ej: Reunión de equipo',
          controller: _eventTitleController,
        ),
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
        if (!_isAllDay)
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
        if (!_isAllDay) const SizedBox(height: 12),
        if (!_isAllDay)
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
                'Todo el día',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _isAllDay,
                onChanged: (value) => setState(() => _isAllDay = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 24),
        _buildColorTagSection(),
        const SizedBox(height: 24),
        _buildDateTimeField(
          title: 'Recordatorio',
          value: _selectedReminder,
          onTap: _showReminderPicker,
        ),
        const SizedBox(height: 32),
        AppButton(
          text: 'Crear Evento Personal',
          type: AppButtonType.primary,
          fullWidth: true,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : _submitPersonal,
        ),
      ],
    );
  }

  Future<void> _submitPersonal() async {
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

    final vm = context.read<PersonalEventViewModel>();

    final startDateTime = _isAllDay
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : _combineDateAndTime(_selectedDate, _startTime);
    final endDateTime = _isAllDay
        ? DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            23,
            59,
          )
        : _combineDateAndTime(_selectedDate, _endTime);

    if (!_isAllDay && endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser posterior a la de inicio'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await vm.create(
        title: _eventTitleController.text.trim(),
        date: _selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        allDay: _isAllDay,
        location: _selectedLocation,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        reminderMinutes: _reminderStringToMinutes(_selectedReminder),
        color: _colorToHex(_selectedColorTag),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Evento "${_eventTitleController.text}" creado exitosamente',
          ),
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
          duration: const Duration(seconds: 4),
        ),
      );
    }
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

  void _showReminderPicker() {
    final reminders = ['Ninguno', '5 minutos', '10 minutos', '30 minutos'];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: AppColors.background,
          child: ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(reminders[index]),
                onTap: () {
                  setState(() {
                    _selectedReminder = reminders[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
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

  int? _reminderStringToMinutes(String value) {
    if (value == 'Ninguno') return null;
    return int.tryParse(value.replaceAll(' minutos', ''));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}
