// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mechanic_discovery_app/screens/map_screen.dart';
import 'package:mechanic_discovery_app/screens/profile/mechanic_profile_screen.dart';
import 'package:mechanic_discovery_app/screens/profile/car_owner_profile_screen.dart';
import 'package:mechanic_discovery_app/services/api_endpoints.dart';
import 'package:mechanic_discovery_app/services/api_service.dart';
import 'package:mechanic_discovery_app/services/auth_service.dart';
import 'package:mechanic_discovery_app/services/storage_service.dart';
import 'package:provider/provider.dart';

import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/providers/location_provider.dart';
import 'package:mechanic_discovery_app/providers/service_provider.dart';
import 'package:mechanic_discovery_app/providers/mechanic_stats_provider.dart';

import 'package:mechanic_discovery_app/screens/auth/login_screen.dart';
import 'package:mechanic_discovery_app/screens/auth/register_screen.dart';
import 'package:mechanic_discovery_app/screens/home/mechanic_home.dart';
import 'package:mechanic_discovery_app/screens/home/owner_home.dart';
import 'package:mechanic_discovery_app/screens/location/update_location.dart';
import 'package:mechanic_discovery_app/screens/service/nearby_mechanics.dart';
import 'package:mechanic_discovery_app/screens/service/nearby_requests.dart';
import 'package:mechanic_discovery_app/screens/service/request_service.dart';

import 'package:mechanic_discovery_app/services/location_service.dart';
import 'package:mechanic_discovery_app/models/user_model.dart';
import 'package:mechanic_discovery_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    final apiUrl = dotenv.get('API_URL', fallback: '');
    if (apiUrl.isEmpty) {
      throw Exception('API_URL is missing in .env file');
    }

    // Set API base URL
    ApiEndpoints.baseUrl = apiUrl;

    print('API Server: $apiUrl');
    print('Full API Base: ${ApiEndpoints.apiBase}');

    // Test API connection
    final apiService = ApiService();
    final testResponse = await apiService.get(ApiEndpoints.health);
    print('API Connection Test: $testResponse');
  } catch (e) {
    print("Error during initialization: ${e.toString()}");
  }

  // Create shared instances
  final storageService = StorageService();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => storageService),
        Provider(create: (_) => apiService),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: AuthService(
              apiService: context.read<ApiService>(),
              storageService: context.read<StorageService>(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(
            LocationService(
              apiService: context.read<ApiService>(),
              storageService: context.read<StorageService>(),
            ),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ServiceProvider(
            auth: context.read<AuthProvider>(),
            apiService: context.read<ApiService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => MechanicStatsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mechanic Discovery',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final authProvider = context.read<AuthProvider>();
          return authProvider.isMechanic
              ? const MechanicHomeScreen()
              : const OwnerHomeScreen();
        },
        '/profile': (context) {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.user == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profile Error')),
              body: const Center(child: Text('Please login first')),
            );
          }
          return authProvider.isMechanic
              ? MechanicProfileScreen(mechanic: authProvider.user!)
              : const CarOwnerProfileScreen();
        },
        '/map': (context) => const MapScreen(),
        '/update-location': (context) => const UpdateLocationScreen(),
        '/request-service': (context) => const RequestServiceScreen(),
        '/nearby-mechanics': (context) => const NearbyMechanicsScreen(),
        '/nearby-requests': (context) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isMechanic) {
            return Scaffold(
              appBar: AppBar(title: const Text('Access Denied')),
              body: const Center(
                child: Text('Only mechanics can access this feature'),
              ),
            );
          }
          return const NearbyRequestsScreen();
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/mechanic-profile') {
          final mechanic = settings.arguments as UserModel;
          return MaterialPageRoute(
            builder: (context) => MechanicProfileScreen(mechanic: mechanic),
          );
        }
        if (settings.name == '/car-owner-profile') {
          return MaterialPageRoute(
            builder: (context) => const CarOwnerProfileScreen(),
          );
        }
        return null;
      },
    );
  }
}
