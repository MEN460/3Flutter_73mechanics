import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart' as latlng;
import 'package:latlong2/latlong.dart' as latlng;

class LocationPicker extends StatefulWidget {
  final Function(latlng.LatLng) onLocationSelected;
  final latlng.LatLng? initialLocation;

  const LocationPicker({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late MapController _mapController;
  late latlng.LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? latlng.LatLng(0.0, 0.0);
  }

  void _onMapTap(latlng.TapPosition tapPosition, latlng.LatLng latLng) {
    setState(() => _selectedLocation = latLng);
    widget.onLocationSelected(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedLocation,
              zoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: _selectedLocation,
                    builder: (ctx) => const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Selected: ${_selectedLocation.latitude.toStringAsFixed(4)}, '
            '${_selectedLocation.longitude.toStringAsFixed(4)}',
          ),
        ),
      ],
    );
  }
}
