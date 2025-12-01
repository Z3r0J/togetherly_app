import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

/// Catálogo de componentes de UI de Togetherly
///
/// Esta página muestra todos los componentes reutilizables disponibles
/// en la aplicación para facilitar el desarrollo y mantener la consistencia.
class ComponentCatalog extends StatefulWidget {
  const ComponentCatalog({super.key});

  @override
  State<ComponentCatalog> createState() => _ComponentCatalogState();
}

class _ComponentCatalogState extends State<ComponentCatalog> {
  int _selectedTab = 0;
  RsvpStatus _selectedRsvp = RsvpStatus.going;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Component Catalog')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Botones
          SectionHeader(title: 'Buttons', icon: Icons.touch_app),
          const SizedBox(height: 16),
          const AppButton(text: 'Primary Button', type: AppButtonType.primary),
          const SizedBox(height: 12),
          const AppButton(
            text: 'Secondary Button',
            type: AppButtonType.secondary,
          ),
          const SizedBox(height: 12),
          const AppButton(text: 'Outline Button', type: AppButtonType.outline),
          const SizedBox(height: 12),
          const AppButton(text: 'Text Button', type: AppButtonType.text),
          const SizedBox(height: 12),
          const AppButton(
            text: 'Destructive Button',
            type: AppButtonType.destructive,
          ),
          const SizedBox(height: 12),
          const AppButton(
            text: 'Button with Icon',
            icon: Icons.add,
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 12),
          const AppButton(
            text: 'Loading Button',
            isLoading: true,
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIconButton(icon: Icons.add, onPressed: () {}),
              const SizedBox(width: 12),
              AppIconButton(
                icon: Icons.favorite,
                backgroundColor: AppColors.error,
                iconColor: Colors.white,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Campos de texto
          const SectionHeader(title: 'Text Fields', icon: Icons.text_fields),
          const SizedBox(height: 16),
          const AppTextField(
            label: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          const AppTextField(
            label: 'Password',
            hintText: 'Create a strong password',
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            suffixIcon: Icons.visibility_off,
          ),
          const SizedBox(height: 12),
          const SearchTextField(hintText: 'Search events...'),

          const SizedBox(height: 32),

          // RSVP
          const SectionHeader(
            title: 'RSVP Components',
            icon: Icons.event_available,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              RsvpBadge(status: RsvpStatus.going),
              RsvpBadge(status: RsvpStatus.maybe),
              RsvpBadge(status: RsvpStatus.notGoing),
            ],
          ),
          const SizedBox(height: 16),
          RsvpSelector(
            currentStatus: _selectedRsvp,
            onStatusChanged: (status) {
              setState(() => _selectedRsvp = status);
            },
          ),
          const SizedBox(height: 16),
          const RsvpSummary(goingCount: 4, maybeCount: 1, notGoingCount: 0),

          const SizedBox(height: 32),

          // Avatares
          const SectionHeader(title: 'Avatars', icon: Icons.person),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              UserAvatar(name: 'John Doe', size: 40),
              UserAvatar(name: 'Jane Smith', size: 48),
              UserAvatar(name: 'Bob Wilson', size: 56),
            ],
          ),
          const SizedBox(height: 16),
          AvatarStack(
            avatars: const [
              AvatarData(name: 'John Doe'),
              AvatarData(name: 'Jane Smith'),
              AvatarData(name: 'Bob Wilson'),
              AvatarData(name: 'Alice Johnson'),
              AvatarData(name: 'Charlie Brown'),
              AvatarData(name: 'Diana Prince'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              CircleBadge(color: AppColors.circleGreen),
              CircleBadge(color: AppColors.circleOrange),
              CircleBadge(color: AppColors.circlePurple),
            ],
          ),
          const SizedBox(height: 16),
          ColorSelector(
            selectedColor: AppColors.circlePurple,
            onColorSelected: (color) {},
          ),

          const SizedBox(height: 32),

          // Cards de eventos
          const SectionHeader(title: 'Event Cards', icon: Icons.event),
          const SizedBox(height: 16),
          EventCard(
            title: 'Annual BBQ Party',
            date: 'Saturday, August 17',
            time: '2:00 PM - 7:00 PM',
            location: "Alex's Backyard",
            rsvpStatus: RsvpStatus.going,
            attendeeCount: 6,
            onViewDetails: () {},
          ),
          const SizedBox(height: 16),
          CompactEventCard(
            title: 'Team Standup',
            time: '9:00 AM - 9:15 AM',
            location: 'Remote (Google Meet)',
            notes: 'Quick check-in on project milestones.',
            colorTag: AppColors.warning,
            hasConflict: true,
          ),

          const SizedBox(height: 32),

          // Cards de círculos
          const SectionHeader(title: 'Circle Cards', icon: Icons.groups),
          const SizedBox(height: 16),
          CircleCard(
            name: 'Family Get-Together',
            memberCount: 5,
            eventCount: 2,
            color: AppColors.circlePurple,
            lastActivity: '2h ago',
          ),
          const SizedBox(height: 16),
          CompactCircleCard(
            name: 'Family',
            memberCount: 8,
            nextEventTitle: "Mom's Birthday",
            nextEventDate: 'Oct 20, 7:00 PM',
            color: AppColors.circleGreen,
            onViewCircle: () {},
          ),

          const SizedBox(height: 32),

          // Notificaciones
          const SectionHeader(
            title: 'Notifications',
            icon: Icons.notifications,
          ),
          const SizedBox(height: 16),
          NotificationCard(
            type: NotificationType.reminder,
            message: 'Reminder: Family Dinner is at 7:00 PM at Mom\'s House.',
            timeAgo: '5m ago',
            primaryActionLabel: 'View Event',
            secondaryActionLabel: 'Dismiss',
            onPrimaryAction: () {},
            onSecondaryAction: () {},
          ),
          const SizedBox(height: 12),
          NotificationCard(
            type: NotificationType.conflict,
            message:
                'Conflict Detected: \'Game Night\' clashes with \'Project Deadline\'.',
            timeAgo: '12m ago',
            primaryActionLabel: 'Resolve',
            secondaryActionLabel: 'View',
            onPrimaryAction: () {},
            onSecondaryAction: () {},
          ),
          const SizedBox(height: 12),
          NotificationCard(
            type: NotificationType.rsvpUpdate,
            message: 'Alex has updated their RSVP for \'Team Lunch\' to Going.',
            timeAgo: '2h ago',
            isUnread: true,
          ),

          const SizedBox(height: 32),

          // Alertas y banners
          const SectionHeader(
            title: 'Alerts & Banners',
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: 16),
          ConflictBanner(
            message:
                'This event overlaps with "Design Sync" (2:30 PM - 3:30 PM). Your RSVP for that event will be set to \'Not Going\'.',
          ),
          const SizedBox(height: 12),
          ConflictAlert(
            message:
                'You have a conflict with Dentist Appointment. Your RSVP has been automatically set to \'Not Going\'.',
            onResolve: () {},
            onChangeRsvp: () {},
          ),
          const SizedBox(height: 12),
          const InfoBanner(
            message: 'Time Confirmed: 11:00 AM',
            subtitle: 'Locked by Alex',
            type: InfoBannerType.success,
          ),
          const SizedBox(height: 12),
          const InfoBanner(
            message: 'Poll closes in 2 days',
            type: InfoBannerType.info,
          ),

          const SizedBox(height: 32),

          // Layout widgets
          const SectionHeader(
            title: 'Layout Components',
            icon: Icons.dashboard,
          ),
          const SizedBox(height: 16),
          WelcomeHeader(
            userName: 'Sarah',
            date: 'Today, October 18',
            unreadCount: 3,
            onNotificationPressed: () {},
          ),
          const SizedBox(height: 16),
          FilterTabs(
            tabs: const ['All', 'Personal', 'Going', 'Maybe'],
            selectedIndex: _selectedTab,
            onTabSelected: (index) {
              setState(() => _selectedTab = index);
            },
          ),
          const SizedBox(height: 16),
          const DividerWithText(text: 'or'),
          const SizedBox(height: 16),
          const EmptyState(
            icon: Icons.event_busy,
            title: 'No events yet',
            message: 'Create your first event to get started',
            actionLabel: 'Create Event',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
