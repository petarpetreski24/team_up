import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../models/sport.dart';
import '../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedSport;
  final TextEditingController _searchController = TextEditingController();
  final List<Sport> _sports = Sport.defaultSports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find an activity',
          style: AppTextStyles.heading3,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              leading: const Icon(Icons.search),
              hintText: 'Search events...',
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sports.length,
              itemBuilder: (context, index) {
                final sport = _sports[index];
                final isSelected = sport.name == _selectedSport;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(sport.name),
                    onSelected: (selected) {
                      setState(() {
                        _selectedSport = selected ? sport.name : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                final events = eventsProvider.events.where((event) {
                  bool matchesSport = _selectedSport == null ||
                      event.sport == _selectedSport;
                  bool matchesSearch = _searchController.text.isEmpty ||
                      event.location.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                      event.sport.toLowerCase().contains(_searchController.text.toLowerCase());
                  return matchesSport && matchesSearch;
                }).toList();

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
              },
            ),
          ),
        ],
      ),
    );
  }
}