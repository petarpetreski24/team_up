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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.sport,
                      style: AppTextStyles.subheading,
                    ),
                  ),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'Accepted'
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status!,
                        style: AppTextStyles.caption.copyWith(
                          color: status == 'Accepted'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormatter.formatEventDate(event.dateTime),
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    '${event.pricePerPerson}MKD/person',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.acceptedPlayers.length}/${event.maxPlayers} players',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  if (spotsLeft != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: spotsLeft! < 3
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spotsLeft == 1
                            ? '1 spot left'
                            : '${spotsLeft!} spots left',
                        style: AppTextStyles.caption.copyWith(
                          color: spotsLeft! < 3
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              if (event.description.isNotEmpty) ...[
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
      ),
    );
  }
}