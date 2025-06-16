import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';

class CarOwnerProfileScreen extends StatelessWidget {
  const CarOwnerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!) as ImageProvider
                    : const AssetImage('assets/default_avatar.png'),
                child: user?.avatarUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Username'),
              subtitle: Text(user?.username ?? 'Not set'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? 'Not set'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(user?.phone ?? 'Not set'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location'),
              subtitle: Text(
                user?.currentLatitude != null && user?.currentLongitude != null
                    ? '${user!.currentLatitude!.toStringAsFixed(4)}, ${user.currentLongitude!.toStringAsFixed(4)}'
                    : 'Not set',
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/update-location'),
                child: const Text('Update Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
