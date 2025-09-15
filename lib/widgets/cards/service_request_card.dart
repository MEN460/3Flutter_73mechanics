import 'package:flutter/material.dart';
import 'package:mechanic_discovery_app/models/service_request_model.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback? onAccept;

  const ServiceRequestCard({super.key, required this.request, this.onAccept});

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'pending':
        return colorScheme.secondary;
      case 'accepted':
        return colorScheme.primary;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.description,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context, request.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Location: ${request.latitude.toStringAsFixed(4)}, '
                '${request.longitude.toStringAsFixed(4)}',
                style: textTheme.bodyMedium,
              ),
              if (onAccept != null && request.status == 'pending')
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept Request'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
