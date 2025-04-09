import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/event_card.dart';
import '../utils/constants.dart';

class HostedEventsScreen extends StatelessWidget {
  const HostedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).currentUser!.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your hosted events',
            style: AppTextStyles.heading3,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            final now = DateTime.now();
            final hostedEvents = eventsProvider.events
                .where((event) => event.organizerId == userId && event.isOpen)
                .toList();

            final activeEvents = hostedEvents
                .where((event) => event.dateTime.isAfter(now))
                .toList();
            final pastEvents = hostedEvents
                .where((event) => event.dateTime.isBefore(now))
                .toList();

            return TabBarView(
              children: [
                _EventsList(events: activeEvents),
                _EventsList(events: pastEvents),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create-event');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<dynamic> events;

  const _EventsList({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events found',
          style: AppTextStyles.body,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
}