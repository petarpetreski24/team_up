import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          const SnackBar(
            content: Text('Failed to create event'),
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
              CustomTextField(
                label: 'Location',
                hint: 'Enter location',
                controller: _locationController,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Location is required' : null,
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