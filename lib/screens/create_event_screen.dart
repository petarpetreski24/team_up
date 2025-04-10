import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/sport_event.dart';
import '../models/sport.dart';
import '../providers/events_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constants.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedSport;
  int _maxPlayers = 4;
  bool _isLoading = false;

  // Google Maps related variables
  late GoogleMapController _mapController;
  LatLng _selectedLocation = const LatLng(0, 0);
  Set<Marker> _markers = {};
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get the current position
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _updateMarker(_selectedLocation);
    });
  }

  // Update the marker on the map
  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: position,
          infoWindow: const InfoWindow(title: 'Event Location'),
        ),
      };
      _selectedLocation = position;
    });

    if (_mapInitialized) {
      _mapController.animateCamera(CameraUpdate.newLatLng(position));
    }

    // Reverse geocode to get address
    _getAddressFromLatLng(position);
  }

  // Get address from coordinates
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.country}';

        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Search for a location
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        LatLng position = LatLng(
            locations.first.latitude,
            locations.first.longitude
        );

        _updateMarker(position);

        if (_mapInitialized) {
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
        }
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() || _selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Please fill all required fields',
                    style: AppTextStyles.body.copyWith(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (_selectedLocation.latitude == 0 && _selectedLocation.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Please select a location on the map',
                    style: AppTextStyles.body.copyWith(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = SportEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        organizerId: authProvider.currentUser!.id,
        sport: _selectedSport!,
        dateTime: dateTime,
        location: _locationController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        maxPlayers: _maxPlayers,
        pricePerPerson: double.parse(_priceController.text),
        description: _descriptionController.text,
      );

      await eventsProvider.createEvent(event);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    if (_mapInitialized) {
      _mapController.dispose();
    }
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: AppTextStyles.subheading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Host Event',
          style: AppTextStyles.heading3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show guide for event creation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Hosting Guide', style: AppTextStyles.heading3),
                  content: const Text(
                    'Creating a great event is easy!\n\n'
                        '1. Choose your sport and set the date & time\n'
                        '2. Select a location on the map\n'
                        '3. Set player limit and price\n'
                        '4. Add a description to attract players\n\n'
                        'That\'s it! Your event will be visible to all users.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sport selection
              _buildSectionTitle('What sport are you playing?'),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.cardBackground,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedSport,
                  decoration: InputDecoration(
                    hintText: 'Select sport',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground2,
                  ),
                  icon: const Icon(Icons.sports_basketball, color: AppColors.primary),
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  dropdownColor: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  items: Sport.defaultSports.map((sport) {
                    return DropdownMenuItem(
                      value: sport.name,
                      child: Row(
                        children: [
                          Icon(
                            _getSportIcon(sport.name),
                            color: _getSportColor(sport.name),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(sport.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSport = value);
                  },
                  validator: (value) =>
                  value == null ? 'Please select a sport' : null,
                ),
              ),

              const SizedBox(height: 24),

              // Date and time section
              _buildSectionTitle('When is your event?'),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Date',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: AppTextStyles.bodyBold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.accent,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Time',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedTime.format(context),
                                style: AppTextStyles.bodyBold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Location section
              _buildSectionTitle('Where is it happening?'),
              CustomTextField(
                label: '',
                hint: 'Search for a location',
                controller: _locationController,
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                onChanged: (value) {
                  // If user stops typing for a bit, search location
                  if (value.length > 3) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_locationController.text == value) {
                        _searchLocation(value);
                      }
                    });
                  }
                },
                validator: (value) =>
                value?.isEmpty ?? true ? 'Location is required' : null,
              ),
              const SizedBox(height: 12),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation,
                          zoom: 15,
                        ),
                        markers: _markers,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          setState(() {
                            _mapInitialized = true;
                          });
                        },
                        onTap: (position) {
                          _updateMarker(position);
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.my_location, color: AppColors.primary),
                            onPressed: _getCurrentLocation,
                            tooltip: 'My Location',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.touch_app, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to set location',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Event details section
              _buildSectionTitle('Event details'),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price per person (MKD)',
                      hint: '0',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.attach_money, color: AppColors.accent),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Price is required';
                        if (double.tryParse(value!) == null) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maximum Players',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.cardBackground2,
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _maxPlayers,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.people, color: AppColors.secondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            items: List.generate(19, (index) => index + 2)
                                .map((count) {
                              return DropdownMenuItem(
                                value: count,
                                child: Text('$count players'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _maxPlayers = value ?? 4);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Tell players about your event...',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Create Event',
                icon: Icons.sports_handball,
                onPressed: _createEvent,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    final String sportLower = sport.toLowerCase();

    if (sportLower.contains('soccer') || sportLower.contains('football')) {
      return Icons.sports_soccer;
    } else if (sportLower.contains('basket')) {
      return Icons.sports_basketball;
    } else if (sportLower.contains('tennis')) {
      return Icons.sports_tennis;
    } else if (sportLower.contains('volley')) {
      return Icons.sports_volleyball;
    } else if (sportLower.contains('baseball')) {
      return Icons.sports_baseball;
    } else if (sportLower.contains('cricket')) {
      return Icons.sports_cricket;
    } else if (sportLower.contains('run') || sportLower.contains('marathon')) {
      return Icons.directions_run;
    } else if (sportLower.contains('golf')) {
      return Icons.sports_golf;
    } else if (sportLower.contains('swim')) {
      return Icons.pool;
    } else if (sportLower.contains('cycle') || sportLower.contains('bike')) {
      return Icons.directions_bike;
    } else if (sportLower.contains('ping pong') || sportLower.contains('table tennis')) {
      return Icons.sports_tennis; // Using tennis icon as fallback for ping pong
    } else if (sportLower.contains('rock') && sportLower.contains('climb')) {
      return Icons.terrain; // Mountain icon for rock climbing
    } else if (sportLower.contains('yoga')) {
      return Icons.self_improvement; // Yoga pose icon
    } else if (sportLower.contains('box') || sportLower.contains('boxing')) {
      return Icons.sports_mma; // MMA/boxing icon
    } else {
      return Icons.sports;
    }
  }

  Color _getSportColor(String sport) {
    final String sportLower = sport.toLowerCase();

    if (sportLower.contains('soccer') || sportLower.contains('football')) {
      return AppColors.sportGreen;
    } else if (sportLower.contains('basket')) {
      return AppColors.sportOrange;
    } else if (sportLower.contains('tennis')) {
      return AppColors.accent;
    } else if (sportLower.contains('volley')) {
      return AppColors.sportPink;
    } else if (sportLower.contains('baseball')) {
      return AppColors.sportPurple;
    } else if (sportLower.contains('cricket')) {
      return AppColors.sportCyan;
    } else if (sportLower.contains('run') || sportLower.contains('marathon')) {
      return AppColors.textSecondary;
    } else if (sportLower.contains('golf')) {
      return Colors.brown;
    } else if (sportLower.contains('swim')) {
      return AppColors.primary;
    } else if (sportLower.contains('cycle') || sportLower.contains('bike')) {
      return AppColors.sportRed;
    } else if (sportLower.contains('ping pong') || sportLower.contains('table tennis')) {
      return Colors.teal; // Teal for ping pong
    } else if (sportLower.contains('rock') && sportLower.contains('climb')) {
      return Colors.brown[700] ?? Colors.brown; // Dark brown for rock climbing
    } else if (sportLower.contains('yoga')) {
      return Colors.purple[300] ?? Colors.purple; // Light purple for yoga
    } else if (sportLower.contains('box') || sportLower.contains('boxing')) {
      return Colors.red[900] ?? Colors.red; // Dark red for boxing
    } else {
      return AppColors.primary;
    }
  }
}