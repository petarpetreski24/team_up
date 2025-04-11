import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_up/utils/avatar_formatter.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final now = DateTime.now();
    final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          final allUpcomingEvents = eventsProvider.events
              .where((event) {
            final eventDate = DateTime(
              event.dateTime.year,
              event.dateTime.month,
              event.dateTime.day,
            );
            return (eventDate.isAtSameMomentAs(today) || eventDate.isAfter(today)) && !event.isCancelled;
          })
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          final userEvents = allUpcomingEvents.where((event) =>
          event.registeredPlayers.contains(currentUser?.id) ||
              event.acceptedPlayers.contains(currentUser?.id)).toList();

          final availableEvents = allUpcomingEvents.where((event) =>
          event.isOpen &&
              event.organizerId != currentUser?.id &&
              !event.registeredPlayers.contains(currentUser?.id) &&
              !event.acceptedPlayers.contains(currentUser?.id) &&
              event.acceptedPlayers.length < event.maxPlayers &&
              event.dateTime.isAfter(thirtyMinutesFromNow)).toList();

          final todayEvents = userEvents.where((event) {
            return DateFormatter.isSameDay(event.dateTime, DateTime.now());
          }).toList();

          if (allUpcomingEvents.isEmpty) {
            return _buildEmptyState(context);
          }

          return CustomScrollView(
            slivers: [
              // Animated App Bar
              SliverAppBar(
                expandedHeight: 170,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primary,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated circles
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // Top right animated circle
                                Positioned(
                                  top: -30 + 10 * _getCosValue(_animationController.value * 3),
                                  right: -30 + 10 * _getSinValue(_animationController.value * 2),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // Middle animated circle
                                Positioned(
                                  top: 50 + 15 * _getSinValue(_animationController.value * 5),
                                  right: 100 + 20 * _getCosValue(_animationController.value * 4),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // Bottom left animated circle
                                Positioned(
                                  bottom: -20 + 10 * _getSinValue(_animationController.value * 3),
                                  left: -20 + 10 * _getCosValue(_animationController.value * 4),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // User greeting and info
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (currentUser != null)
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: AvatarFormatter.getAvatarColor(currentUser.name),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          AvatarFormatter.getInitials(currentUser.name),
                                          style: AppTextStyles.bodyBold.copyWith(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello, ${currentUser?.name.split(' ')[0] ?? "Guest"}!',
                                        style: AppTextStyles.heading3.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Ready to play?',
                                        style: AppTextStyles.body.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),

                                ],
                              ),

                              const Spacer(),

                              if (todayEvents.isNotEmpty)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.event_available,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${todayEvents.length} event${todayEvents.length > 1 ? 's' : ''} today',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rounded bottom edge
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),

              // Content sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Events',
                        style: AppTextStyles.heading3,
                      ),
                      if (userEvents.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  child: userEvents.isEmpty
                      ? _buildEmptySection(
                    title: 'No events yet',
                    message: 'You haven\'t joined any events. Find an event or create your own!',
                    icon: Icons.event_busy,
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userEvents.length,
                    itemBuilder: (context, index) {
                      final event = userEvents[index];
                      final isAccepted = event.acceptedPlayers.contains(currentUser?.id);
                      return EventCard(
                        event: event,
                        status: isAccepted ? 'Accepted' : 'Pending',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/event-details',
                          arguments: {'eventId': event.id},
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Events Near You',
                        style: AppTextStyles.heading3,
                      ),
                      if (availableEvents.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  child: availableEvents.isEmpty
                      ? _buildEmptySection(
                    title: 'No events available',
                    message: 'There are no events available to join at the moment. Check again later!',
                    icon: Icons.search_off,
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableEvents.length,
                    itemBuilder: (context, index) {
                      final event = availableEvents[index];
                      final spotsLeft = event.maxPlayers - event.acceptedPlayers.length;
                      return EventCard(
                        event: event,
                        spotsLeft: spotsLeft,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/event-details',
                          arguments: {'eventId': event.id},
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _getSinValue(double value) {
    return sin(value * 3.14159);
  }

  double _getCosValue(double value) {
    return cos(value * 3.14159);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_handball,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Events Found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Looks like there are no upcoming events. Why not create one?',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/create-event'),
            icon: const Icon(Icons.add),
            label: const Text('Create an Event'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.subheading,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}