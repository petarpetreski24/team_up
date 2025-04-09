import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/create_event_screen.dart';
import '../screens/event_details_screen.dart';
import '../screens/profile_screen.dart';

class AppRouter {
  static const String initial = '/login';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createEvent = '/create-event';
  static const String eventDetails = '/event-details';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case createEvent:
        return MaterialPageRoute(builder: (_) => const CreateEventScreen());
      case eventDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: args?['eventId'] ?? ''),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found!')),
          ),
        );
    }
  }
}