import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

/// Ejemplos de pantallas completas usando los widgets de Togetherly
///
/// Este archivo contiene implementaciones de referencia que muestran
/// cómo combinar los widgets para crear pantallas completas.

// =============================================================================
// EJEMPLO 1: Pantalla de Login/Signup
// =============================================================================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo y título
              Icon(Icons.groups, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Togetherly',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Plan life together',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Formulario
              const AppTextField(
                label: 'Display Name',
                hintText: 'Enter your display name',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              const AppTextField(
                label: 'Email',
                hintText: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              const AppTextField(
                label: 'Password',
                hintText: 'Create a strong password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                suffixIcon: Icons.visibility_off,
              ),

              const SizedBox(height: 32),

              const AppButton(
                text: 'Create Account',
                type: AppButtonType.primary,
                fullWidth: true,
              ),

              const SizedBox(height: 16),

              const DividerWithText(text: 'or'),

              const SizedBox(height: 16),

              const AppButton(
                text: 'Send me a Magic Link',
                type: AppButtonType.outline,
                fullWidth: true,
              ),

              const SizedBox(height: 24),

              // Link a login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Log in',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EJEMPLO 2: Pantalla de Home
// =============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            WelcomeHeader(
              userName: 'Sarah',
              date: 'Today, October 18',
              unreadCount: 3,
              onNotificationPressed: () {
                // Navegar a notificaciones
              },
            ),

            // Círculos
            SectionHeader(
              title: 'Your Circles',
              actionLabel: 'See All',
              onActionPressed: () {},
            ),

            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  SizedBox(
                    width: 280,
                    child: CompactCircleCard(
                      name: 'Family',
                      memberCount: 8,
                      nextEventTitle: "Mom's Birthday",
                      nextEventDate: 'Oct 20, 7:00 PM',
                      color: AppColors.circleGreen,
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 280,
                    child: CompactCircleCard(
                      name: 'Weekend Warriors',
                      memberCount: 8,
                      nextEventTitle: 'Sunrise Trail Run',
                      nextEventDate: 'Oct 25, 8:00 AM',
                      color: AppColors.circleTeal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Eventos
            const SectionHeader(title: 'Upcoming Events'),

            FilterTabs(
              tabs: const ['All', 'Personal', 'Going', 'Maybe'],
              selectedIndex: _selectedTab,
              onTabSelected: (index) {
                setState(() => _selectedTab = index);
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  EventCard(
                    title: "Mom's Birthday Dinner",
                    date: 'Saturday, October 20',
                    time: '7:00 PM',
                    location: 'The Grand Bistro',
                    rsvpStatus: RsvpStatus.going,
                    attendeeCount: 6,
                    circleLabel: 'FAMILY',
                    circleColor: AppColors.circleGreen,
                  ),
                  SizedBox(height: 12),
                  EventCard(
                    title: "'The Midnight Library' Discussion",
                    date: 'Tuesday, October 22',
                    time: '6:30 PM',
                    location: 'Central Library',
                    rsvpStatus: RsvpStatus.maybe,
                    attendeeCount: 9,
                    circleLabel: 'BOOK CLUB',
                    circleColor: AppColors.circleOrange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Crear evento
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =============================================================================
// EJEMPLO 3: Pantalla de Detalle de Evento
// =============================================================================

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  RsvpStatus _currentRsvp = RsvpStatus.maybe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: "Sarah's Birthday Brunch",
              subtitle: 'Family',
              onBackPressed: () => Navigator.pop(context),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información del evento
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_today_outlined, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Saturday, November 23, 2024',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Icon(Icons.access_time, size: 20),
                              SizedBox(width: 12),
                              Text(
                                '11:00 AM - 2:00 PM',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.location_on_outlined, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'The Corner Bistro\n123 Main St, Anytown',
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.notes_outlined, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Don\'t forget to bring a small gift!',
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // RSVP
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your RSVP', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 16),

                          ConflictAlert(
                            message:
                                'You have a conflict with Dentist Appointment. Your RSVP has been automatically set to \'Not Going\'.',
                            onResolve: () {},
                            onChangeRsvp: () {},
                          ),

                          const SizedBox(height: 16),

                          RsvpSelector(
                            currentStatus: _currentRsvp,
                            onStatusChanged: (status) {
                              setState(() => _currentRsvp = status);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Asistentes
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Who\'s Coming?',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 16),

                          // Going
                          Row(
                            children: [
                              Text(
                                'Going',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.rsvpGoing,
                                ),
                              ),
                              Text(' (5)', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AvatarStack(
                            avatars: const [
                              AvatarData(name: 'John Doe'),
                              AvatarData(name: 'Jane Smith'),
                              AvatarData(name: 'Bob Wilson'),
                              AvatarData(name: 'Alice Johnson'),
                              AvatarData(name: 'Charlie Brown'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Maybe
                          Row(
                            children: [
                              Text(
                                'Maybe',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.rsvpMaybe,
                                ),
                              ),
                              Text(' (2)', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AvatarStack(
                            avatars: const [
                              AvatarData(name: 'Diana Prince'),
                              AvatarData(name: 'Clark Kent'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Time Poll
                    Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time Poll',
                                style: AppTextStyles.titleMedium,
                              ),
                              Text(
                                'Poll closes in 2 days',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Aquí irían las opciones de votación
                          const InfoBanner(
                            message: 'Time Confirmed: 11:00 AM',
                            subtitle: 'Locked by Alex',
                            type: InfoBannerType.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EJEMPLO 4: Pantalla de Notificaciones
// =============================================================================

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark All Read')),
        ],
      ),
      body: Column(
        children: [
          FilterTabs(
            tabs: const ['All', 'Events', 'Circles', 'RSVPs'],
            selectedIndex: 0,
            onTabSelected: (index) {},
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              children: [
                NotificationCard(
                  type: NotificationType.reminder,
                  message:
                      'Reminder: Family Dinner is at 7:00 PM at Mom\'s House.',
                  timeAgo: '5m ago',
                  primaryActionLabel: 'View Event',
                  secondaryActionLabel: 'Dismiss',
                  onPrimaryAction: () {},
                  onSecondaryAction: () {},
                ),

                const Divider(height: 1),

                NotificationCard(
                  type: NotificationType.conflict,
                  message:
                      'Conflict Detected: \'Game Night\' clashes with \'Project Deadline\'.',
                  timeAgo: '12m ago',
                  primaryActionLabel: 'Resolve',
                  secondaryActionLabel: 'View',
                  onPrimaryAction: () {},
                  onSecondaryAction: () {},
                  isUnread: true,
                ),

                const Divider(height: 1),

                NotificationCard(
                  type: NotificationType.rsvpUpdate,
                  message:
                      'Alex has updated their RSVP for \'Team Lunch\' to Going.',
                  timeAgo: '2h ago',
                  isUnread: true,
                ),

                const Divider(height: 1),

                NotificationCard(
                  type: NotificationType.invitation,
                  message:
                      'Sarah invited you to \'Weekend Hike\' in the \'Adventure Crew\' circle on Oct 28.',
                  timeAgo: '1d ago',
                  primaryActionLabel: 'Set RSVP',
                  secondaryActionLabel: 'View',
                  onPrimaryAction: () {},
                  onSecondaryAction: () {},
                ),

                const Divider(height: 1),

                NotificationCard(
                  type: NotificationType.circleInvitation,
                  message:
                      'Michael has invited you to join the \'Book Club\' circle.',
                  timeAgo: '3d ago',
                  primaryActionLabel: 'Accept',
                  secondaryActionLabel: 'Decline',
                  onPrimaryAction: () {},
                  onSecondaryAction: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EJEMPLO 5: Pantalla de Crear Círculo
// =============================================================================

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  Color _selectedColor = AppColors.circleTeal;
  bool _isInviteOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        title: const Text('Create Circle'),
        leadingWidth: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTextField(
              label: 'Circle Name',
              hintText: 'Enter a name for your circle',
            ),

            const SizedBox(height: 24),

            Text('Circle Color', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            ColorSelector(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() => _selectedColor = color);
              },
            ),

            const SizedBox(height: 24),

            const AppTextField(
              label: 'Description (optional)',
              hintText: 'What\'s this circle for?...',
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            Text('Privacy', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),

            // Radio buttons simulados con cards
            GestureDetector(
              onTap: () => setState(() => _isInviteOnly = true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isInviteOnly ? AppColors.primary : AppColors.border,
                    width: _isInviteOnly ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isInviteOnly
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _isInviteOnly
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invite-only', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Members can only join via direct invitation.',
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
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => setState(() => _isInviteOnly = false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_isInviteOnly
                        ? AppColors.primary
                        : AppColors.border,
                    width: !_isInviteOnly ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      !_isInviteOnly
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: !_isInviteOnly
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Public', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Anyone with the link can join.',
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
            ),

            const SizedBox(height: 32),

            const AppButton(
              text: 'Create Circle',
              type: AppButtonType.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
