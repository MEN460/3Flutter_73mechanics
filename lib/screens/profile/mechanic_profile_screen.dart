import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/widgets/rating_bar.dart';
import 'package:mechanic_discovery_app/models/user_model.dart';

class MechanicProfileScreen extends StatefulWidget {
  final UserModel mechanic;
  const MechanicProfileScreen({super.key, required this.mechanic});

  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  late TextEditingController _specializationController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _specializationController = TextEditingController(
      text: widget.mechanic.specialization ?? '',
    );
    _phoneController = TextEditingController(text: widget.mechanic.phone ?? '');
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // NEW: Request service from this mechanic
  void _requestService(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/request-service',
      arguments: widget.mechanic.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isCurrentUser = authProvider.user?.id == widget.mechanic.id;
    final isCarOwner = authProvider.isCarOwner;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mechanic.username),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditProfileDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: widget.mechanic.avatarUrl != null
                    ? NetworkImage(widget.mechanic.avatarUrl!) as ImageProvider
                    : const AssetImage('assets/default_avatar.png'),
                child: widget.mechanic.avatarUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildProfileSection(context, 'Personal Information', [
              _buildListTile(
                Icons.person,
                'Username',
                widget.mechanic.username,
              ),
              _buildListTile(Icons.email, 'Email', widget.mechanic.email),
              _buildListTile(
                Icons.phone,
                'Phone',
                widget.mechanic.phone ?? 'Not set',
              ),
              _buildListTile(
                Icons.work,
                'Specialization',
                widget.mechanic.specialization ?? 'General Mechanic',
              ),
            ]),

            const SizedBox(height: 24),
            _buildProfileSection(context, 'Professional Stats', [
              _buildStatTile(
                Icons.star_rate_rounded,
                'Rating',
                widget.mechanic.rating?.toStringAsFixed(1) ?? 'N/A',
                widget.mechanic.rating != null
                    ? RatingBar(rating: widget.mechanic.rating!)
                    : null,
              ),
              _buildListTile(
                Icons.location_on,
                'Location',
                '${widget.mechanic.currentLatitude?.toStringAsFixed(4) ?? 'N/A'}, '
                    '${widget.mechanic.currentLongitude?.toStringAsFixed(4) ?? 'N/A'}',
              ),
              _buildStatTile(
                Icons.handyman,
                'Services Completed',
                '24', // Would come from backend
                null,
              ),
            ]),

            const SizedBox(height: 24),
            _buildProfileSection(context, 'Availability', [
              _buildAvailabilityStatus('Monday - Friday', '8:00 AM - 6:00 PM'),
              _buildAvailabilityStatus('Saturday', '9:00 AM - 4:00 PM'),
              _buildAvailabilityStatus('Sunday', 'Not Available'),
            ]),

            if (isCurrentUser) ...[
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('Update Location'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/update-location'),
                ),
              ),
            ],
          ],
        ),
      ),
      // NEW: Request service button for car owners
      floatingActionButton: !isCurrentUser && isCarOwner
          ? FloatingActionButton.extended(
              onPressed: () => _requestService(context),
              icon: const Icon(Icons.car_repair),
              label: const Text('Request Service'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildStatTile(
    IconData icon,
    String title,
    String value,
    Widget? extra,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value),
          if (extra != null) ...[const SizedBox(height: 4), extra],
        ],
      ),
    );
  }

  Widget _buildAvailabilityStatus(String days, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(days, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(hours, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  hintText: 'e.g., Engine Specialist',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().updateProfile(
                _specializationController.text,
                _phoneController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
// This screen displays the mechanic's profile, allowing car owners to view details and request services.
// It includes sections for personal information, professional stats, and availability.