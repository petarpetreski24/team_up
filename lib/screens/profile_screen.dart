import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_up/utils/avatar_formatter.dart';
import 'package:team_up/utils/sport_formatter.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../routes/app_router.dart';
import '../widgets/custom_button.dart';
import './edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  double _avatarSize = 120.0;
  double _avatarPosition = 0.0;
  final double _minAvatarSize = 40.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateAvatarSizeOnScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateAvatarSizeOnScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateAvatarSizeOnScroll() {
    final double appBarHeight = 150.0;
    final double maxAvatarSize = 120.0;
    final double scrollOffset = _scrollController.offset;
    final double maxOffset = 100.0;

    final double newSize = (maxAvatarSize - ((scrollOffset / maxOffset) * (maxAvatarSize - _minAvatarSize)))
        .clamp(_minAvatarSize, maxAvatarSize);

    final double newPosition = (scrollOffset / maxOffset).clamp(0.0, 1.0);

    if (newSize != _avatarSize || newPosition != _avatarPosition) {
      setState(() {
        _avatarSize = newSize;
        _avatarPosition = newPosition;
      });
    }
  }

  double _getSinValue(double value) {
    return sin(value * 3.14159);
  }

  double _getCosValue(double value) {
    return cos(value * 3.14159);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading profile picture...'),
            duration: Duration(seconds: 1),
          ),
        );

        final url = await Provider.of<AuthProvider>(context, listen: false)
            .uploadProfileImage(_profileImage!);

        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Error
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Failed to upload profile picture. Please try again.'),
          //     behavior: SnackBarBehavior.floating,
          //     backgroundColor: Colors.red,
          //   ),
          // );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Choose Profile Picture',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
                if (_profileImage != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: const Text('Remove current photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _profileImage = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture removed'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    final appBarHeight = 150.0;
    final maxAvatarSize = 120.0;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: appBarHeight,
                pinned: true,
                backgroundColor: AppColors.primary,
                title: AnimatedOpacity(
                  opacity: _avatarPosition > 0.5 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    user.name,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                actions: [
                  if (_avatarPosition > 0.9)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: _showImageSourceActionSheet,
                        child: _buildSmallAvatar(user.name, user.profileImageUrl),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
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
                      ),

                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Positioned(
                                top: -30 + 10 * _getCosValue(_animationController.value * 3),
                                left: -20 + 10 * _getSinValue(_animationController.value * 2),
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
                                top: 50 + 15 * _getSinValue(_animationController.value * 5),
                                right: 40 + 20 * _getCosValue(_animationController.value * 4),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -40 + 10 * _getSinValue(_animationController.value * 3),
                                right: -30 + 10 * _getCosValue(_animationController.value * 4),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 0),
                              height: _avatarPosition < 0.9 ? maxAvatarSize / 2 : 0,
                              curve: Curves.easeOut,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: _avatarPosition < 0.9 ? 60 : 16,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: AppTextStyles.heading2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatItem(
                                  label: 'Hosted',
                                  value: user.hostedEvents.length.toString(),
                                  icon: Icons.event_available,
                                  color: AppColors.accent,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: AppColors.divider,
                                ),
                                _StatItem(
                                  label: 'Participated',
                                  value: user.participatedEvents.length.toString(),
                                  icon: Icons.sports_handball,
                                  color: AppColors.sportOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('My Sports', Icons.sports),
                        const SizedBox(height: 12),

                        if (user.sportsLevels.isEmpty)
                          _buildEmptySportsState(context)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: user.sportsLevels.length,
                            itemBuilder: (context, index) {
                              final sport = user.sportsLevels.keys.elementAt(index);
                              final level = user.sportsLevels[sport];
                              return _buildSportItem(context, sport, level ?? '');
                            },
                          ),

                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Edit Profile',
                          icon: Icons.edit,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Logout',
                          icon: Icons.logout,
                          isOutlined: true,
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_avatarPosition < 0.9)
            Positioned(
              top: appBarHeight - (_avatarSize / 2) + (_avatarPosition * appBarHeight / 2),
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  width: _avatarSize,
                  height: _avatarSize,
                  child: _buildAvatar(user.name, user.email, user.profileImageUrl),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String email, String? profileImageUrl) {
    final double borderWidth = 4.0 * (1.0 - _avatarPosition);

    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1 * (1.0 - _avatarPosition)),
            blurRadius: 8 * (1.0 - _avatarPosition),
            offset: Offset(0, 2 * (1.0 - _avatarPosition)),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              color: AvatarFormatter.getAvatarColor(name),
              child: _profileImage != null
                  ? Image.file(
                _profileImage!,
                fit: BoxFit.cover,
                width: _avatarSize,
                height: _avatarSize,
              )
                  : profileImageUrl != null
                  ? Image.network(
                profileImageUrl,
                fit: BoxFit.cover,
                width: _avatarSize,
                height: _avatarSize,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white70,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      AvatarFormatter.getInitials(name),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: _avatarSize * 0.35,
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  AvatarFormatter.getInitials(name),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: _avatarSize * 0.35,
                  ),
                ),
              ),
            ),
          ),

          if (_avatarPosition < 0.5)
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: 1.0 - (_avatarPosition * 2),
                child: Transform.scale(
                  scale: 1.0 - (_avatarPosition * 0.5),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _showImageSourceActionSheet,
                          child: Padding(
                            padding: EdgeInsets.all(10.0 * (1.0 - _avatarPosition * 0.5)),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20 * (1.0 - _avatarPosition * 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar(String name, String? profileImageUrl) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Container(
          color: AvatarFormatter.getAvatarColor(name),
          child: _profileImage != null
              ? Image.file(
            _profileImage!,
            fit: BoxFit.cover,
            width: 36,
            height: 36,
          )
              : profileImageUrl != null
              ? Image.network(
            profileImageUrl,
            fit: BoxFit.cover,
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  AvatarFormatter.getInitials(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            },
          )
              : Center(
            child: Text(
              AvatarFormatter.getInitials(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.subheading,
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading3,
        ),
      ],
    );
  }

  Widget _buildEmptySportsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_outlined,
            size: 48,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'No sports added yet',
            style: AppTextStyles.subheading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your favorite sports and skill levels to find better matches',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Add Sports',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportItem(BuildContext context, String sport, String level) {
    final Color sportColor = SportFormatter.getSportColor(sport);
    final IconData sportIcon = SportFormatter.getSportIcon(sport);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: sportColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            sportIcon,
            color: sportColor,
            size: 24,
          ),
        ),
        title: Text(
          sport,
          style: AppTextStyles.bodyBold,
        ),
        subtitle: Text(
          'Level: $level',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: sportColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            level,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: sportColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
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
}