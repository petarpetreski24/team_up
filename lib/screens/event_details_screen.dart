import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sport_event.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_button.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final event = eventsProvider.events.firstWhere((e) => e.id == eventId);
    final isOrganizer = event.organizerId == authProvider.currentUser?.id;
    final organizer = authProvider.getUserById(event.organizerId);
    final hasRegistered = event.registeredPlayers
        .contains(authProvider.currentUser?.id ?? '');
    final isAccepted = event.acceptedPlayers
        .contains(authProvider.currentUser?.id ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.sport,
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatEventDate(event.dateTime),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16),
                      const SizedBox(width: 4),
                      FutureBuilder<User?>(
                        future: organizer,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              'Loading organizer...',
                              style: AppTextStyles.body,
                            );
                          }
                          return Text(
                            'Organized by ${snapshot.data?.name ?? 'Unknown'}',
                            style: AppTextStyles.body,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Price per person',
                    value: '€${event.pricePerPerson}',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Players',
                    value: '${event.acceptedPlayers.length}/${event.maxPlayers}',
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: AppTextStyles.body,
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Text(
                    'Players',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),

                  if (event.acceptedPlayers.isNotEmpty) ...[
                    const Text(
                      'Accepted',
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: event.acceptedPlayers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('Player ${index + 1}'),
                          trailing: const Icon(Icons.check_circle, color: AppColors.success),
                        );
                      },
                    ),
                  ],

                  if (isOrganizer && event.registeredPlayers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Waiting for Approval',
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: event.registeredPlayers.length,
                      itemBuilder: (context, index) {
                        final playerId = event.registeredPlayers[index];
                        if (!event.acceptedPlayers.contains(playerId)) {
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text('Player ${index + 1}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    eventsProvider.acceptPlayer(event.id, playerId);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color: Colors.red,
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Reject Player'),
                                        content: const Text(
                                            'Are you sure you want to reject this player?'
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true && context.mounted) {
                                      try {
                                        await eventsProvider.rejectPlayer(event.id, playerId);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Player rejected successfully'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to reject player'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final eventDate = DateTime(
            event.dateTime.year,
            event.dateTime.month,
            event.dateTime.day,
          );

          if (eventDate.isBefore(today)) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isOrganizer
                ? CustomButton(
              text: 'Cancel Event',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Event'),
                    content: const Text(
                        'Are you sure you want to cancel this event? '
                            'This action cannot be undone.'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No, keep event'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Yes, cancel event'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    await eventsProvider.cancelEvent(event.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event cancelled successfully'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to cancel event'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              isOutlined: true,
            )
                : CustomButton(
              text: isAccepted
                  ? 'Leave Event'
                  : hasRegistered
                  ? 'Waiting for Approval'
                  : 'Join Event',
              onPressed: hasRegistered
                  ? () {}
                  : isAccepted
                  ? () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Leave Event'),
                    content: const Text(
                        'Are you sure you want to leave this event?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Leave'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    await eventsProvider.leaveEvent(
                      event.id,
                      authProvider.currentUser!.id,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Successfully left the event'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to leave event'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              }
                  : () {
                eventsProvider.registerForEvent(
                  event.id,
                  authProvider.currentUser!.id,
                );
              },
              isOutlined: isAccepted,
              isDisabled: hasRegistered,
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}