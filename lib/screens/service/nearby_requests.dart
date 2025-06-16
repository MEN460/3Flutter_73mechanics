import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mechanic_discovery_app/models/service_request_model.dart';
import 'package:mechanic_discovery_app/providers/service_provider.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/widgets/cards/service_request_card.dart';

class NearbyRequestsScreen extends StatelessWidget {
  const NearbyRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isMechanic) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('Only mechanics can access this feature'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Requests')),
      body: FutureBuilder<List<ServiceRequest>>(
        future: context.read<ServiceProvider>().getNearbyRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) => ServiceRequestCard(
              request: snapshot.data![index],
              onAccept: () => _acceptRequest(context, snapshot.data![index].id),
            ),
          );
        },
      ),
    );
  }

  void _acceptRequest(BuildContext context, int requestId) async {
    try {
      await context.read<ServiceProvider>().acceptRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accepting request: $e')));
    }
  }
}
