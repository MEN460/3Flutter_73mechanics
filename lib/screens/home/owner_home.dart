import 'package:flutter/material.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/utils/app_routes.dart';
import 'package:mechanic_discovery_app/utils/gradient_cache.dart';
import 'package:provider/provider.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose an action below to get started:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const DashboardCard(
              icon: Icons.car_repair,
              title: 'Request Service',
              description: 'Request a mechanic to assist you with your car.',
              route: AppRoutes.requestService,
            ),
            const SizedBox(height: 20),
            const DashboardCard(
              icon: Icons.location_on,
              title: 'Update Location',
              description:
                  'Set your current location to find nearby mechanics.',
              route: AppRoutes.updateLocation,
            ),
            const SizedBox(height: 20),
            const DashboardCard(
              icon: Icons.people,
              title: 'Nearby Mechanics',
              description: 'Find mechanics near your current location.',
              route: AppRoutes.nearbyMechanics,
            ),
            const SizedBox(height: 20),
            const DashboardCard(
              icon: Icons.person,
              title: 'My Profile',
              description: 'View and manage your profile information.',
              route: '/car-owner-profile',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String route;

  const DashboardCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: GradientCache.dashboardCardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha((0.2 * 255).toInt()), // alpha ≈ 51

                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
