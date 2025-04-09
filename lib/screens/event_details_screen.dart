import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/sport_event.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = true;
  SportEvent? _event;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isRegistering = false;
  bool _isLeaving = false;
  LatLng? _currentUserLocation;
  bool _loadingUsers = false;
  List<User> _participants = [];

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _getCurrentLocation();
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    try {
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

      SportEvent? foundEvent = eventsProvider.events.firstWhere(
            (e) => e.id == widget.eventId,
        orElse: () => null as SportEvent, // This will throw if not found, which we handle in the catch
      );

      if (foundEvent == null) {
        // Assuming your EventsProvider has a method to fetch a single event
        foundEvent = await eventsProvider.getEventById(widget.eventId);

        if (foundEvent == null) {
          throw Exception('Event not found');
        }
      }

      if (mounted) {
        setState(() {
          _event = foundEvent;
          _isLoading = false;
        });

        _setMarkers();
        _loadParticipants();
      }
    } catch (e) {
      print('Error loading event: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load event: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _setMarkers() {
    if (_event == null) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('eventLocation'),
          position: LatLng(_event!.latitude, _event!.longitude),
          infoWindow: InfoWindow(title: _event!.sport, snippet: _event!.location),
        ),
      };
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentUserLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _loadParticipants() async {
    if (_event == null || _event!.registeredPlayers.isEmpty) return;

    setState(() => _loadingUsers = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<User> users = [];

      for (String userId in _event!.registeredPlayers) {
        final user = await authProvider.getUserById(userId);
        if (user != null) {
          users.add(user);
        }
      }

      if (mounted) {
        setState(() {
          _participants = users;
          _loadingUsers = false;
        });
      }
    } catch (e) {
      print('Error loading participants: $e');
      if (mounted) {
        setState(() => _loadingUsers = false);
      }
    }
  }

  Future<void> _openDirections() async {
    if (_event == null) return;

    if (_event!.latitude == 0 && _event!.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event does not have a valid location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String googleMapsUrl;

    if (_currentUserLocation != null) {
      // If we have the user's current location, use it as the starting point
      googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=${_currentUserLocation!.latitude},${_currentUserLocation!.longitude}&destination=${_event!.latitude},${_event!.longitude}&travelmode=driving';
    } else {
      // Otherwise just show the destination
      googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${_event!.latitude},${_event!.longitude}&travelmode=driving';
    }

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _registerForEvent() async {
    if (_event == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      return;
    }

    setState(() => _isRegistering = true);

    try {
      await eventsProvider.registerForEvent(_event!.id, authProvider.currentUser!.id);
      // Refresh the event data to get updated player lists
      await _loadEventData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for the event'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  Future<void> _leaveEvent() async {
    if (_event == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      return;
    }

    setState(() => _isLeaving = true);

    try {
      await eventsProvider.leaveEvent(_event!.id, authProvider.currentUser!.id);
      // Refresh the event data
      await _loadEventData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left the event'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave event: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLeaving = false);
      }
    }
  }

  Future<void> _acceptPlayer(String playerId) async {
    if (_event == null) return;

    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    try {
      await eventsProvider.acceptPlayer(_event!.id, playerId);
      // Refresh the event data
      await _loadEventData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player accepted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept player: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectPlayer(String playerId) async {
    if (_event == null) return;

    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    try {
      await eventsProvider.rejectPlayer(_event!.id, playerId);
      // Refresh the event data
      await _loadEventData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player rejected successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject player: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event not found'),
        ),
        body: const Center(
          child: Text('Event not found or has been deleted.'),
        ),
      );
    }

    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final isOrganizer = currentUser?.id == _event!.organizerId;
    final isRegistered = _event!.registeredPlayers.contains(currentUser?.id);
    final isAccepted = _event!.acceptedPlayers.contains(currentUser?.id);
    final isPastEvent = _event!.dateTime.isBefore(DateTime.now());
    final canRegister = !isPastEvent && _event!.isOpen && !isOrganizer && !isRegistered;

    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _event!.sport,
          style: AppTextStyles.heading3,
        ),
        actions: [
          if (isOrganizer)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Event'),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancel Event'),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  // Navigate to edit screen with event data
                } else if (value == 'cancel') {
                  _showCancelEventDialog();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map section
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_event!.latitude, _event!.longitude),
                      zoom: 14,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: AppColors.primary,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(_event!.latitude, _event!.longitude),
                            14,
                          ),
                        );
                      },
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Get Directions button
                  CustomButton(
                    text: 'Get Directions',
                    // icon: Icons.directions,
                    onPressed: _openDirections,
                    // color: AppColors.secondary,
                  ),

                  const SizedBox(height: 24),

                  // Event details
                  Text(
                    'Event Details',
                    // style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: 8),

                  _buildDetailRow('Sport', _event!.sport),
                  _buildDetailRow('Date', dateFormat.format(_event!.dateTime)),
                  _buildDetailRow('Time', timeFormat.format(_event!.dateTime)),
                  _buildDetailRow('Location', _event!.location),
                  _buildDetailRow('Max Players', _event!.maxPlayers.toString()),
                  _buildDetailRow('Price per Person', '${_event!.pricePerPerson.toStringAsFixed(2)} MKD'),

                  if (_event!.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      // style: AppTextStyles.heading4,
                    ),
                    const SizedBox(height: 8),
                    Text(_event!.description),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Participants (${_event!.acceptedPlayers.length}/${_event!.maxPlayers})',
                        // style: AppTextStyles.heading4,
                      ),
                      Text(
                        isPastEvent ? 'Event Ended' :
                        _event!.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: isPastEvent ? AppColors.textSecondary :
                          _event!.isOpen ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_loadingUsers)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (_participants.isEmpty && !isPastEvent)
                    const Text(
                      'No participants yet. Be the first to join!',
                      // style: AppTextStyles.bodyMedium,
                    )
                  else
                    _buildParticipantsList(isOrganizer),

                  // Show registration/leave button if the user is not the organizer
                  if (!isPastEvent && !isOrganizer && _event!.isOpen) ...[
                    const SizedBox(height: 24),
                    if (!isRegistered) ...[
                      CustomButton(
                        text: 'Register for Event',
                        onPressed: _registerForEvent,
                        isLoading: _isRegistering,
                      ),
                    ] else if (!isAccepted) ...[
                      Column(
                        children: [
                          Card(
                            // color: AppColors.cardBackground,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: AppColors.textSecondary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Your registration is pending approval',
                                    // style: AppTextStyles.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            text: 'Leave Event',
                            onPressed: _leaveEvent,
                            isLoading: _isLeaving,
                            // color: AppColors.error,
                          ),
                        ],
                      ),
                    ] else ...[
                      Column(
                        children: [
                          Card(
                            color: AppColors.success.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'You\'re all set! You are registered for this event.',
                                    // style: AppTextStyles.bodyMediumBold,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            text: 'Leave Event',
                            onPressed: _leaveEvent,
                            isLoading: _isLeaving,
                            // color: AppColors.error,
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              // style: AppTextStyles.bodyMediumBold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              // style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(bool isOrganizer) {
    final bool isEventFull = _event!.acceptedPlayers.length >= _event!.maxPlayers;

    return Column(
      children: [
        if (isEventFull && isOrganizer && _event!.registeredPlayers.length > _event!.acceptedPlayers.length)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              color: AppColors.warning.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: const [
                    Icon(Icons.info, color: AppColors.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Event is full. You can still reject accepted players to make room for others.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        for (var participant in _participants)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(participant.name.substring(0, 1).toUpperCase()),
              ),
              title: Text(participant.name),
              subtitle: Text(
                participant.sportsLevels.containsKey(_event!.sport)
                    ? '${_event!.sport}: ${participant.sportsLevels[_event!.sport]}'
                    : 'Skill level not specified',
              ),
              trailing: isOrganizer
                  ? _buildPlayerActionButtons(participant, isEventFull)
                  : _event!.acceptedPlayers.contains(participant.id)
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerActionButtons(User participant, bool isEventFull) {
    // If player is already accepted
    if (_event!.acceptedPlayers.contains(participant.id)) {
      return Icon(Icons.check_circle, color: AppColors.success);
    }

    // If event is full, don't show accept button for pending registrations
    if (isEventFull) {
      return Icon(Icons.do_not_disturb, color: AppColors.error);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: AppColors.success),
          onPressed: () => _acceptPlayer(participant.id),
          tooltip: 'Accept player',
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.error),
          onPressed: () => _rejectPlayer(participant.id),
          tooltip: 'Reject player',
        ),
      ],
    );
  }

  void _showCancelEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text('Are you sure you want to cancel this event? All participants will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                await eventsProvider.cancelEvent(_event!.id);
                await _loadEventData(); // Reload the data
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event cancelled successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel event: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose();
    }
    super.dispose();
  }
}