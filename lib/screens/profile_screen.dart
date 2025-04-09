import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../routes/app_router.dart';
import '../widgets/custom_button.dart';
import './edit_profile_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        user.email,
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'My Sports',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            if (user.sportsLevels.isEmpty)
              const Text(
                'No sports added yet',
                style: AppTextStyles.body,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.sportsLevels.length,
                itemBuilder: (context, index) {
                  final sport = user.sportsLevels.keys.elementAt(index);
                  final level = user.sportsLevels[sport];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.sports),
                      title: Text(sport),
                      subtitle: Text('Level: $level'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            const Text(
              'Statistics',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Hosted',
                      value: user.hostedEvents.length.toString(),
                    ),
                    _StatItem(
                      label: 'Participated',
                      value: user.participatedEvents.length.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Edit Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              isOutlined: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Logout',
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2,
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}