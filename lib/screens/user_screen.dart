import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class UserScreen extends StatefulWidget {
  final String userId;

  const UserScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = await authProvider.getUserById(widget.userId);

      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load user: ${e.toString()}',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
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
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return AppColors.primary;

    // Generate a consistent color based on the name
    final hashCode = name.hashCode;
    final colorIndex = hashCode.abs() % AppColors.avatarColors.length;
    return AppColors.avatarColors[colorIndex];
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('User not found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: AppColors.textDisabled,
              ),
              const SizedBox(height: 16),
              Text(
                'User not found or has been deleted.',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // User header with gradient background
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -50,
                  left: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // User avatar and info
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16), // Space for app bar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _getAvatarColor(_user!.name),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(_user!.name),
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user!.name,
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user!.email,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sports section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sports & Skills',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced from 16 to 8

                  // Sports list
                  Expanded(
                    child: _user!.sportsLevels.isEmpty
                        ? _buildEmptySportsState()
                        : ListView.builder(
                      padding: const EdgeInsets.only(top: 8), // Added small top padding
                      itemCount: _user!.sportsLevels.length,
                      itemBuilder: (context, index) {
                        final sport = _user!.sportsLevels.keys.elementAt(index);
                        final level = _user!.sportsLevels[sport] ?? '';
                        final sportColor = _getSportColor(sport);
                        final sportIcon = _getSportIcon(sport);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: sportColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: sportColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  sportIcon,
                                  color: sportColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sport,
                                      style: AppTextStyles.subheading,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getLevelDescription(level),
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: sportColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  level,
                                  style: AppTextStyles.caption.copyWith(
                                    color: sportColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // User activity stats
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          label: 'Hosted',
                          value: _user!.hostedEvents.length.toString(),
                          icon: Icons.event_available,
                          color: AppColors.accent,
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: AppColors.divider,
                        ),
                        _buildStatItem(
                          label: 'Participated',
                          value: _user!.participatedEvents.length.toString(),
                          icon: Icons.sports_handball,
                          color: AppColors.sportOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySportsState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No Sports Added',
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This user hasn\'t added any sports or skill levels yet.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getLevelDescription(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Just starting out, learning the basics';
      case 'intermediate':
        return 'Familiar with the game, some experience';
      case 'advanced':
        return 'Skilled player with significant experience';
      case 'professional':
        return 'Expert level with competitive background';
      default:
        return 'Skill level specified';
    }
  }
}