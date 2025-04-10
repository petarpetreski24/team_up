import 'package:flutter/material.dart';
import '../models/sport_event.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class EventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onTap;
  final String? status;
  final int? spotsLeft;

  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
    this.status,
    this.spotsLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPastEvent = event.dateTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isPastEvent
                  ? AppColors.cardBackground.withOpacity(0.7)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sport Type Banner
                Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: _getSportColor(event.sport).withOpacity(0.15),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _getSportColor(event.sport),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _getSportIcon(event.sport),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event.sport,
                              style: AppTextStyles.subheading.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'Accepted'
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status!,
                            style: AppTextStyles.caption.copyWith(
                              color: status == 'Accepted'
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground2,
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
                                DateFormatter.formatEventDate(event.dateTime),
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${event.pricePerPerson} MKD',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Location
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              style: AppTextStyles.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Players info and spots left
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.people_alt_outlined,
                                  color: AppColors.accent,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPlayerAvatar(event.acceptedPlayers.length),
                              Text(
                                ' ${event.acceptedPlayers.length}/${event.maxPlayers}',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (spotsLeft != null && !isPastEvent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getSpotsLeftColor(spotsLeft!).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                spotsLeft == 1
                                    ? '1 spot left'
                                    : '${spotsLeft!} spots left',
                                style: AppTextStyles.caption.copyWith(
                                  color: _getSpotsLeftColor(spotsLeft!),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (isPastEvent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textDisabled.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Completed',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textDisabled,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSpotsLeftColor(int spots) {
    if (spots <= 1) return AppColors.error;
    if (spots <= 3) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildPlayerAvatar(int count) {
    return SizedBox(
      width: 34,
      height: 24,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          for (var i = 0; i < (count > 3 ? 3 : count); i++)
            Positioned(
              left: i * 10.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.avatarColors[i % AppColors.avatarColors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
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