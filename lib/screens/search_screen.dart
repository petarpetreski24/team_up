import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_up/utils/sport_formatter.dart';
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
  bool _showOnlyFutureEvents = true;
  bool _showFilters = false;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSport = null;
      _showOnlyFutureEvents = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Discover Events',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.tune : Icons.tune_outlined,
              color: _showFilters ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: _toggleFilters,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search by location, sport...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: _clearSearch,
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? null : 0,
            color: Colors.white,
            child: Visibility(
              visible: _showFilters,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sport', style: AppTextStyles.subheading),
                        if (_selectedSport != null)
                          GestureDetector(
                            onTap: _clearFilters,
                            child: Text(
                              'Clear All',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sports.length,
                      itemBuilder: (context, index) {
                        final sport = _sports[index];
                        final isSelected = sport.name == _selectedSport;
                        final sportColor = SportFormatter.getSportColor(sport.name);
                        final sportIcon = SportFormatter.getSportIcon(sport.name);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSport = isSelected ? null : sport.name;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? sportColor.withOpacity(0.1) : AppColors.cardBackground2,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? sportColor : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    sportIcon,
                                    size: 16,
                                    color: isSelected ? sportColor : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sport.name,
                                    style: TextStyle(
                                      color: isSelected ? sportColor : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: _showOnlyFutureEvents,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _showOnlyFutureEvents = value ?? true;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Show only upcoming events',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          Expanded(
            child: Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                final now = DateTime.now();
                var events = eventsProvider.events.where((event) {
                  bool matchesSport = _selectedSport == null ||
                      event.sport == _selectedSport;

                  bool matchesSearch = _searchController.text.isEmpty ||
                      event.location.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                      event.sport.toLowerCase().contains(_searchController.text.toLowerCase());

                  bool isFutureEvent = !_showOnlyFutureEvents || event.dateTime.isAfter(now);

                  return matchesSport && matchesSearch && isFutureEvent && !event.isCancelled;
                }).toList();

                events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

                if (events.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '${events.length} ${events.length == 1 ? 'Event' : 'Events'} Found',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final spotsLeft = event.maxPlayers - event.acceptedPlayers.length;

                          return EventCard(
                            event: event,
                            spotsLeft: spotsLeft > 0 ? spotsLeft : null,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/event-details',
                                arguments: {'eventId': event.id},
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    bool hasFilters = _selectedSport != null || _searchController.text.isNotEmpty;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  hasFilters ? Icons.filter_list_off : Icons.search_off,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                hasFilters ? 'No matching events found' : 'No events available',
                style: AppTextStyles.subheading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                hasFilters
                    ? 'Try adjusting your filters or search terms to find more events'
                    : 'Check back later or create your own event',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              if (hasFilters) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _clearFilters();
                    _clearSearch();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filters'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}