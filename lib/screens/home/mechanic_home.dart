import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/providers/mechanic_stats_provider.dart';
import 'package:mechanic_discovery_app/utils/app_routes.dart';
import 'package:mechanic_discovery_app/utils/platform_utils.dart';
import 'package:mechanic_discovery_app/utils/gradient_cache.dart';

class MechanicHomeScreen extends StatelessWidget {
  const MechanicHomeScreen({super.key});

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
        title: const Text('Mechanic Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<MechanicStatsProvider>(
            builder: (context, statsProvider, _) {
              return Column(
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
                    icon: Icons.map,
                    title: 'Service Map',
                    description:
                        'View and interact with the service map to see requests near you.',
                    route: AppRoutes.serviceMap,
                  ),
                  const SizedBox(height: 20),
                  const DashboardCard(
                    icon: Icons.location_on,
                    title: 'Update Location',
                    description:
                        'Update your current work location so car owners can find you.',
                    route: AppRoutes.updateLocation,
                  ),
                  const SizedBox(height: 20),
                  const DashboardCard(
                    icon: Icons.list_alt,
                    title: 'Service Requests',
                    description: 'View and manage service requests',
                    route: AppRoutes.serviceRequests,
                  ),
                  const SizedBox(height: 20),
                  const DashboardCard(
                    icon: Icons.person,
                    title: 'My Profile',
                    description: 'View and manage your profile information.',
                    route: '/profile',
                  ),
                  const SizedBox(height: 30),
                  QuickStatsCard(
                    pending: statsProvider.pending,
                    completed: statsProvider.completed,
                    rating: statsProvider.rating,
                  ),
                ],
              );
            },
          ),
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
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color, // Use theme card color
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
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
      ),
    );
  }
}

class QuickStatsCard extends StatelessWidget {
  final int pending;
  final int completed;
  final double rating;

  const QuickStatsCard({
    super.key,
    required this.pending,
    required this.completed,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: GradientCache.dashboardCardGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatItem(value: pending.toString(), label: 'Pending'),
                    StatItem(value: completed.toString(), label: 'Completed'),
                    StatItem(value: rating.toStringAsFixed(1), label: 'Rating'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}

class HoverWrapper extends StatefulWidget {
  final Widget child;

  const HoverWrapper({super.key, required this.child});

  @override
  HoverWrapperState createState() => HoverWrapperState();
}

class HoverWrapperState extends State<HoverWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isDesktopOrWeb(context)) {
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: widget.child,
      ),
    );
  }
}
