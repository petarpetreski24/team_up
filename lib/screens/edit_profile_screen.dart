import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../models/sport.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final Map<String, String> _selectedSportsLevels = {};
  final List<Sport> _sports = Sport.defaultSports;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _selectedSportsLevels.addAll(user.sportsLevels);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().updateProfile(
        name: _nameController.text,
        sportsLevels: _selectedSportsLevels,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Profile updated successfully',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Failed to update profile',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  Color _getAvatarColor() {
    final name = _nameController.text;
    if (name.isEmpty) return AppColors.primary;

    // Generate a consistent color based on the name
    final hashCode = name.hashCode;
    final colorIndex = hashCode.abs() % AppColors.avatarColors.length;
    return AppColors.avatarColors[colorIndex];
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.subheading.copyWith(
              fontSize: 18,
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

  String getLevelDescription(String level) {
    final String levelLower = level.toLowerCase();

    // Handle special formatted levels first
    if (levelLower.contains('5k')) {
      return 'Beginning runner comfortable with 5K distances';
    } else if (levelLower.contains('10k')) {
      return 'Intermediate runner comfortable with 10K distances';
    } else if (levelLower.contains('half marathon')) {
      return 'Advanced runner capable of completing half marathons';
    } else if (levelLower.contains('marathon') || levelLower.contains('elite')) {
      return 'Elite runner with marathon experience';
    } else if (levelLower.contains('v0') || levelLower.contains('v1') || levelLower.contains('v2')) {
      return 'Beginning climber handling V0-V2 bouldering problems';
    } else if (levelLower.contains('v3') || levelLower.contains('v4') || levelLower.contains('v5')) {
      return 'Intermediate climber handling V3-V5 bouldering problems';
    } else if (levelLower.contains('v6') || levelLower.contains('v7') || levelLower.contains('v8')) {
      return 'Advanced climber handling V6-V8 bouldering problems';
    } else if (levelLower.contains('v9')) {
      return 'Expert climber handling V9+ bouldering problems';
    }

    // Handle general levels
    else if (levelLower.contains('beginner')) {
      return 'Just starting out and learning the basics';
    } else if (levelLower.contains('intermediate')) {
      return 'Competent with good understanding of the activity';
    } else if (levelLower.contains('advanced')) {
      return 'Highly skilled with extensive experience';
    } else if (levelLower.contains('professional') || levelLower.contains('pro')) {
      return 'Expert level with competitive experience';
    } else if (levelLower.contains('semi-pro')) {
      return 'Advanced player with some competitive experience';
    } else if (levelLower.contains('competition')) {
      return 'Skilled competitor participating in organized events';
    } else if (levelLower.contains('instructor')) {
      return 'Expert level with ability to teach others';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();
    final initials = getInitials(_nameController.text);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTextStyles.heading3,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: avatarColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                // Image picker would go here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Photo upload coming soon!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal Information'),

                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CustomTextField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _nameController,
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondary),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            // Additional user info fields could go here
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Your Sports & Skills'),

                    // Sports selection list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sports.length,
                      itemBuilder: (context, index) {
                        final sport = _sports[index];
                        final selectedLevel = _selectedSportsLevels[sport.name];
                        final sportIcon = _getSportIcon(sport.name);
                        final sportColor = _getSportColor(sport.name);

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: selectedLevel != null
                                ? BorderSide(color: sportColor.withOpacity(0.3), width: 1.5)
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: sportColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        sportIcon,
                                        color: sportColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        sport.name,
                                        style: AppTextStyles.bodyBold,
                                      ),
                                    ),
                                    if (selectedLevel != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sportColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          selectedLevel,
                                          style: AppTextStyles.caption.copyWith(
                                            color: sportColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Skill level dropdown with better styling
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedLevel,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                    decoration: InputDecoration(
                                      hintText: 'Select your skill level',
                                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: sportColor.withOpacity(0.3)),
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          'I don\'t play this sport',
                                          style: TextStyle(color: AppColors.textDisabled),
                                        ),
                                      ),
                                      ...sport.skillLevels.map((level) {
                                        return DropdownMenuItem(
                                          value: level,
                                          child: Text(
                                            level,
                                            style: AppTextStyles.body.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == null) {
                                          _selectedSportsLevels.remove(sport.name);
                                        } else {
                                          _selectedSportsLevels[sport.name] = value;
                                        }
                                      });
                                    },
                                  ),
                                ),

                                // Show description of the selected level
                                if (selectedLevel != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: sportColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: sportColor.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: sportColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            getLevelDescription(selectedLevel),
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Save Profile',
                      icon: Icons.check_circle_outline,
                      onPressed: _saveProfile,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}