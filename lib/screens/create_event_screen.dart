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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() || _selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedLocation.latitude == 0 && _selectedLocation.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Host your next event!',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: const InputDecoration(
                  labelText: 'Sport',
                  border: OutlineInputBorder(),
                ),
                items: Sport.defaultSports.map((sport) {
                  return DropdownMenuItem(
                    value: sport.name,
                    child: Text(sport.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSport = value);
                },
                validator: (value) =>
                value == null ? 'Please select a sport' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Date'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      onTap: _selectDate,
                      trailing: const Icon(Icons.calendar_today),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Time'),
                      subtitle: Text(_selectedTime.format(context)),
                      onTap: _selectTime,
                      trailing: const Icon(Icons.access_time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Location',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: _searchLocation,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
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
                    myLocationButtonEnabled: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price per person',
                      hint: '0.00',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
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
                        const Text(
                          'Max Players',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _maxPlayers,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(13, (index) => index + 2)
                              .map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text(count.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _maxPlayers = value ?? 4);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Enter event description',
                controller: _descriptionController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Create Event',
                onPressed: _createEvent,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}