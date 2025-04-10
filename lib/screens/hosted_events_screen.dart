import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/event_card.dart';
import '../utils/constants.dart';

class HostedEventsScreen extends StatefulWidget {
  const HostedEventsScreen({super.key});

  @override
  State<HostedEventsScreen> createState() => _HostedEventsScreenState();
}

class _HostedEventsScreenState extends State<HostedEventsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).currentUser!.id;
    final userName = Provider.of<AuthProvider>(context).currentUser!.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 21, bottom: 50, right: 20),
                title: Text(
                  'Your Hosted Events',
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
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
                    ),
                    // Decorative elements
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      left: 20,
                      top: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organize with confidence',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 3.0,
                        color: AppColors.primary,
                      ),
                      insets: const EdgeInsets.symmetric(horizontal: 40),
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.tabLabel.copyWith(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Past'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            final now = DateTime.now();
            final hostedEvents = eventsProvider.events
                .where((event) => (event.organizerId == userId && !event.isCancelled))
                .toList();

            final activeEvents = hostedEvents
                .where((event) => event.dateTime.isAfter(now))
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

            final pastEvents = hostedEvents
                .where((event) => event.dateTime.isBefore(now))
                .toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Reverse chronological for past events

            return Container(
              color: AppColors.background,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _EventsList(events: activeEvents, isActive: true),
                  _EventsList(events: pastEvents, isActive: false),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<dynamic> events;
  final bool isActive;

  const _EventsList({
    required this.events,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/event-details',
              arguments: {'eventId': event.id},
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.event_available : Icons.history,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isActive
                  ? 'No upcoming events'
                  : 'No past events',
              style: AppTextStyles.subheading,
            ),
            const SizedBox(height: 12),
            Text(
              isActive
                  ? 'You haven\'t created any upcoming events yet. Tap the button below to host your first event!'
                  : 'Your past hosted events will appear here.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (isActive) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-event');
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}