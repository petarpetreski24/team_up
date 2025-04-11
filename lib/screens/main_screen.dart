import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'create_event_screen.dart';
import 'hosted_events_screen.dart';
import 'profile_screen.dart';
import '../utils/constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CreateEventScreen(),
    HostedEventsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    final int distance = (index - _currentIndex).abs();

    setState(() {
      _currentIndex = index;
    });

    final int duration = distance == 1
        ? 200
        : 100 + (distance * 50);

    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: duration),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onNavItemTapped,
                items: [
                  _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
                  _buildNavItem(Icons.search_outlined, Icons.search, 'Search'),
                  _buildNavItem(Icons.add_circle_outline, Icons.add_circle, 'Create'),
                  _buildNavItem(Icons.star_outline, Icons.star, 'Hosted'),
                  _buildNavItem(Icons.person_outline, Icons.person, 'Profile'),
                ],
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                elevation: 0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 2 ? null : FloatingActionButton(
        onPressed: () {
          _onNavItemTapped(2);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon,
      IconData activeIcon,
      String label
      ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(activeIcon),
      ),
      label: label,
      tooltip: '',
    );
  }
}