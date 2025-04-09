import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/create_event_screen.dart';
import 'utils/constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sports Activity Organizer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const AuthWrapper());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/main':
              return MaterialPageRoute(builder: (_) => const MainScreen());
            case '/create-event':
              return MaterialPageRoute(builder: (_) => const CreateEventScreen());
            case '/event-details':
              final args = settings.arguments;
              if (args is Map<String, dynamic> && args.containsKey('eventId')) {
                return MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(eventId: args['eventId']),
                );
              }
              return MaterialPageRoute(builder: (_) => const MainScreen());
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Error'),
                  ),
                  body: const Center(
                    child: Text('Page not found'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.currentUser != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}