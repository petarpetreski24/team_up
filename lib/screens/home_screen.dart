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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome back, ${currentUser?.name ?? ""}!',
          style: AppTextStyles.heading3,
        ),
      ),
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          final now = DateTime.now();
          final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));
          final today = DateTime(now.year, now.month, now.day);
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

          if (allUpcomingEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No upcoming events',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/create-event'),
                    child: const Text('Create an Event'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Your Events',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),
              if (userEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'You haven\'t joined any events yet',
                    style: AppTextStyles.body,
                  ),
                )
              else
                ListView.builder(
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

              const SizedBox(height: 24),

              const Text(
                'Available Events',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),
              if (availableEvents.isEmpty)
                const Text(
                  'No available events to join',
                  style: AppTextStyles.body,
                )
              else
                ListView.builder(
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () => Navigator.pushNamed(context, '/create-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
}