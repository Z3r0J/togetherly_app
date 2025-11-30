import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../services/personal_event_service.dart';
import '../models/personal_event_models.dart';
import '../models/location_models.dart';
import 'location_picker_view.dart';

class CreateEventView extends StatefulWidget {
  final String? circleName;
  final Color? circleColor;

  const CreateEventView({super.key, this.circleName, this.circleColor});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  late int _selectedTabIndex;
  final _eventTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  bool _isAllDay = false;
  String _selectedReminder = 'Ninguno';
  Color _selectedColorTag = AppColors.primary;

  // New state variables for API integration
  bool _isLoading = false;
  LocationModel? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.circleName != null ? 1 : 0;
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 100,
        title: Text(
          'Crear Evento',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            _buildTabSelector(),

            const SizedBox(height: 24),

            // Event title
            AppTextField(
              label: 'Título del evento',
              hintText: 'Ej: Reunión de equipo',
              controller: _eventTitleController,
            ),

            const SizedBox(height: 20),

            // Circle selector (only for circle events)
            if (_selectedTabIndex == 1) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Seleccionar Círculo',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.circleColor != null)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: widget.circleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (widget.circleName != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.circleName!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
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
              const SizedBox(height: 20),
            ],

            // Date
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
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Start time
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
                    setState(() {
                      _startTime = picked;
                    });
                  }
                },
              ),

            if (!_isAllDay) const SizedBox(height: 12),

            // End time
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
                    setState(() {
                      _endTime = picked;
                    });
                  }
                },
              ),

            const SizedBox(height: 16),

            // All-day toggle
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
                    onChanged: (value) {
                      setState(() {
                        _isAllDay = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Location (with location picker integration)
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
                    // Convert Map to LocationModel
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

            // Notes
            AppTextField(
              label: 'Notas',
              hintText: 'Agrega más detalles...',
              controller: _notesController,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Color tag selector
            _buildColorTagSection(),

            const SizedBox(height: 24),

            // Reminder selector
            _buildDateTimeField(
              title: 'Recordatorio',
              value: _selectedReminder,
              onTap: () {
                _showReminderPicker();
              },
            ),

            const SizedBox(height: 32),

            // RSVP info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu RSVP se establecerá en: Asistiendo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Create button
            AppButton(
              text: 'Crear Evento',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _isLoading ? null : _handleCreateEvent,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Evento Personal',
              icon: Icons.calendar_today,
              index: 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              label: 'Evento de Círculo',
              icon: Icons.people,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildColorTagSection() {
    final colors = [
      AppColors.circleRed,
      AppColors.circleGreen,
      AppColors.circleBlue,
      AppColors.circleYellow,
      AppColors.circlePurple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiqueta de Color',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: colors.map((color) {
            final isSelected = color == _selectedColorTag;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorTag = color;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showReminderPicker() {
    final reminders = [
      'Ninguno',
      '5 min antes',
      '15 min antes',
      '30 min antes',
      '1 hora antes',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: AppColors.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: reminders.map((reminder) {
            return ListTile(
              title: Text(
                reminder,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: reminder == _selectedReminder
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: reminder == _selectedReminder
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedReminder = reminder;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper methods for data conversion
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  int? _reminderStringToMinutes(String reminder) {
    switch (reminder) {
      case 'Ninguno':
        return null;
      case '15 min antes':
        return 15;
      case '30 min antes':
        return 30;
      case '1 hora antes':
        return 60;
      case '1 día antes':
        return 1440;
      default:
        return null;
    }
  }

  void _handleCreateEvent() async {
    // Validation
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

    // Only handle personal events for now
    if (_selectedTabIndex != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crear eventos de círculo aún no está implementado'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
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

      // Prepare location
      LocationModel? location;
      if (_selectedLocation != null) {
        location = _selectedLocation;
      } else if (_locationController.text.isNotEmpty) {
        location = LocationModel(name: _locationController.text);
      }

      // Create request
      final request = CreatePersonalEventRequest(
        title: _eventTitleController.text.trim(),
        date: _selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        location: location,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        allDay: _isAllDay,
        reminderMinutes: _reminderStringToMinutes(_selectedReminder),
        color: _colorToHex(_selectedColorTag),
      );

      // Call API
      final service = PersonalEventService();
      await service.createPersonalEvent(request);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Evento "${_eventTitleController.text}" creado exitosamente',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error message
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
}
