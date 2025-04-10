import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

          // Extract events happening today
          final todayEvents = userEvents.where((event) {
            return DateFormatter.isSameDay(event.dateTime, DateTime.now());
          }).toList();

          if (allUpcomingEvents.isEmpty) {
            return _buildEmptyState(context);
          }

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.primary,
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
                        // Decorative elements
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (currentUser != null)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getAvatarColor(currentUser.name),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getInitials(currentUser.name),
                                          style: AppTextStyles.bodyBold.copyWith(
                                            color: Colors.white,
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Events',
                        style: AppTextStyles.heading3,
                      ),
                      if (userEvents.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Navigate to all user events
                          },
                          child: Text(
                            '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ,
                    ],
                  ),
                ),
              ),

              // Your Events List
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
                    itemCount: userEvents.length > 3 ? 3 : userEvents.length, // Limit to 3
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

              // Available Events Section
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
                          onPressed: () {
                            // Navigate to all available events
                          },
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

              // Available Events List
              SliverToBoxAdapter(
                child: SizedBox(
                  child: availableEvents.isEmpty
                      ? _buildEmptySection(
                    title: 'No events available',
                    message: 'There are no events available to join at the moment. Check again later!',
                    icon: Icons.search_off,
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Extra padding at bottom
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCategoryItem(
      BuildContext context,
      String name,
      IconData icon,
      Color color
      ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // Filter by category
                },
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return AppColors.primary;

    // Generate a consistent color based on the name
    final hashCode = name.hashCode;
    final colorIndex = hashCode.abs() % AppColors.avatarColors.length;
    return AppColors.avatarColors[colorIndex];
  }
}