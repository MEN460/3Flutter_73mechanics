import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechanic_discovery_app/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:mechanic_discovery_app/models/service_request_model.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/providers/location_provider.dart';
import 'package:mechanic_discovery_app/providers/service_provider.dart';
import 'package:mechanic_discovery_app/widgets/shimmer_loading_overlay.dart';
import 'package:mechanic_discovery_app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapScreen extends StatefulWidget {
  final bool showMechanics;
  final List<UserModel>? initialMechanics;
  final Position? initialPosition;

  const MapScreen({
    Key? key,
    this.showMechanics = false,
    this.initialMechanics,
    this.initialPosition,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<UserModel> _nearbyMechanics = [];
  bool _showMechanics = false;
  late MapController _mapController;
  final List<Marker> _markers = [];
  ServiceRequest? _selectedRequest;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _showRequestsList = false;
  List<ServiceRequest> _nearbyRequests = [];
  late AnimationController _listAnimationController;
  late Animation<double> _listOpacityAnimation;
  late Animation<Offset> _listSlideAnimation;
  bool _animationsInitialized = false;

  // Mechanic view state
  bool _showRequestsMenu = false;
  String _selectedRequestCategory = 'All Pending Requests';
  List<ServiceRequest> _allPendingRequests = [];
  List<ServiceRequest> _myPendingRequests = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _showMechanics = widget.showMechanics;

    if (widget.initialMechanics != null) {
      _nearbyMechanics = widget.initialMechanics!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateMarkers());
    }

    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            latlng.LatLng(
              widget.initialPosition!.latitude,
              widget.initialPosition!.longitude,
            ),
            14.0,
          );
        }
        _updateMarkers();
      });
    } else {
      _getCurrentLocation();
    }

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animationsInitialized) {
      _setupAnimations();
      _animationsInitialized = true;
    }
  }

  void _setupAnimations() {
    final customTheme = Theme.of(context).extension<AppCustomTheme>();
    if (customTheme == null) return;

    if (customTheme.animationDuration != _listAnimationController.duration) {
      _listAnimationController.duration = customTheme.animationDuration;
    }

    _listOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _listSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _listAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!context.read<AuthProvider>().isMechanic && _nearbyMechanics.isEmpty) {
      await _fetchNearbyMechanics();
    }
  }

  Future<void> _fetchNearbyMechanics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final location = _currentPosition;
      if (location == null) return;

      final response = await context.read<ServiceProvider>().getNearbyMechanics(
        location.latitude,
        location.longitude,
      );

      setState(() => _nearbyMechanics = response);
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading mechanics: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    final locationProvider = context.read<LocationProvider>();

    try {
      final position = await locationProvider.getCurrentPosition();
      if (!mounted) return;

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        _mapController.move(
          latlng.LatLng(position.latitude, position.longitude),
          14.0,
        );
        _updateMarkers();

        if (context.read<AuthProvider>().isMechanic) {
          _fetchNearbyRequests(position.latitude, position.longitude);
        } else {
          _fetchNearbyMechanics();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location error: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _fetchNearbyRequests(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final serviceProvider = context.read<ServiceProvider>();
      final requests = await serviceProvider.getNearbyRequests();

      setState(() => _nearbyRequests = requests);
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateMarkers() {
    if (!mounted) return;

    final newMarkers = <Marker>[];

    // 1. Always add user marker if position exists
    if (_currentPosition != null) {
      newMarkers.add(
        Marker(
          point: latlng.LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 40,
          height: 40,
          builder: (ctx) => _buildUserMarker(),
        ),
      );
    }

    // 2. Add request markers (for mechanics)
    if (context.read<AuthProvider>().isMechanic) {
      for (final request in _nearbyRequests) {
        // Skip if coordinates are invalid
        if (request.longitude == null) continue;

        newMarkers.add(
          Marker(
            point: latlng.LatLng(request.latitude, request.longitude),
            width: 40,
            height: 40,
            builder: (ctx) => GestureDetector(
              onTap: () => _onMarkerTapped(request),
              child: _buildRequestMarker(request),
            ),
          ),
        );
      }
    }
    // 3. Add mechanic markers (for car owners)
    else if (_showMechanics) {
      for (final mechanic in _nearbyMechanics) {
        // Skip if coordinates are invalid
        if (mechanic.currentLatitude == null ||
            mechanic.currentLongitude == null) {
          continue;
        }

        newMarkers.add(
          Marker(
            point: latlng.LatLng(
              mechanic.currentLatitude!,
              mechanic.currentLongitude!,
            ),
            width: 50,
            height: 50,
            builder: (ctx) => GestureDetector(
              onTap: () => _onMechanicTapped(mechanic),
              child: _buildMechanicMarker(mechanic),
            ),
          ),
        );
      }
    }

    // Add test marker for debugging
    newMarkers.add(
      Marker(
        point: latlng.LatLng(-1.2921, 36.8219),
        builder: (ctx) =>
            const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });

    debugPrint("Updated ${_markers.length} markers");
  }

  Widget _buildUserMarker() {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppCustomTheme>();
    final isMechanic = context.read<AuthProvider>().isMechanic;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isMechanic
              ? customTheme?.mechanicColor ?? Colors.blue
              : customTheme?.nonMechanicColor ?? Colors.green,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          customTheme?.markerShadow ??
              BoxShadow(
                color: Colors.black.withAlpha((0.2 * 255).toInt()),
                blurRadius: 10,
                spreadRadius: 1,
              ),
        ],
      ),
      child: Icon(
        isMechanic ? Icons.directions_car : Icons.person_pin,
        color: isMechanic
            ? customTheme?.mechanicColor ?? Colors.blue
            : customTheme?.nonMechanicColor ?? Colors.green,
        size: 30,
      ),
    );
  }

  Widget _buildRequestMarker(ServiceRequest request) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppCustomTheme>();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              customTheme?.markerShadow ??
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
            ],
          ),
          child: Icon(
            Icons.location_pin,
            color: _getStatusColor(request.status),
            size: 40,
          ),
        ),
        if (request.distance != null)
          Positioned(
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  customTheme?.markerShadow ??
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                ],
              ),
              child: Text(
                '${request.distance!.toStringAsFixed(1)}km',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMechanicMarker(UserModel mechanic) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<AppCustomTheme>();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 239, 237, 240),
            shape: BoxShape.circle,
            boxShadow: [
              customTheme?.markerShadow ??
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: mechanic.avatarUrl != null
                ? CachedNetworkImageProvider(mechanic.avatarUrl!)
                : null,
            child: mechanic.avatarUrl == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
        ),
        if (mechanic.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _onMechanicTapped(UserModel mechanic) {
    if (context.read<AuthProvider>().isMechanic) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: mechanic.avatarUrl != null
                    ? NetworkImage(mechanic.avatarUrl!)
                    : null,
                child: mechanic.avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                mechanic.username,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                mechanic.specialization ?? 'General Mechanic',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/mechanic-profile',
                    arguments: mechanic,
                  );
                },
                child: const Text('View Profile'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleRequestsList() {
    setState(() {
      _showRequestsList = !_showRequestsList;
      if (_showRequestsList) {
        _listAnimationController.forward();
      } else {
        _listAnimationController.reverse();
      }
    });
  }

  void _onMarkerTapped(ServiceRequest request) {
    setState(() {
      _selectedRequest = request;
      if (_showRequestsList) {
        _showRequestsList = false;
        _listAnimationController.reverse();
      }
    });

    _mapController.move(
      latlng.LatLng(request.latitude, request.longitude),
      14.0,
    );
  }

  Future<void> _acceptRequest(int requestId) async {
    setState(() => _isLoading = true);
    try {
      await context.read<ServiceProvider>().acceptRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully!')),
      );
      setState(() {
        _nearbyRequests.removeWhere((req) => req.id == requestId);
        _selectedRequest = null;
        _updateMarkers();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.move(
        latlng.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14.0,
      );
    }
  }

  Widget _buildMechanicFAB() {
    final theme = Theme.of(context);
    return FloatingActionButton(
      heroTag: 'location',
      backgroundColor: theme.colorScheme.primary,
      onPressed: _centerMap,
      child: const Icon(Icons.my_location, color: Colors.white),
    );
  }

  Widget _buildOwnerFAB() {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      heroTag: 'request_service',
      backgroundColor: theme.colorScheme.primary,
      icon: const Icon(Icons.car_repair, color: Colors.white),
      label: const Text(
        'Request Service',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pushNamed(context, '/request-service'),
    );
  }

  void _toggleRequestsMenu() {
    setState(() {
      _showRequestsMenu = !_showRequestsMenu;
      if (_showRequestsMenu) {
        _loadPendingRequests();
      }
    });
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoading = true);
    try {
      final serviceProvider = context.read<ServiceProvider>();
      _allPendingRequests = await serviceProvider.getAllPendingRequests();
      _myPendingRequests = await serviceProvider.getMyPendingRequests();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRequestsMenu() {
    final requests = _selectedRequestCategory == 'All Pending Requests'
        ? _allPendingRequests
        : _myPendingRequests;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedRequestCategory,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleRequestsMenu,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'All Pending Requests',
                  label: Text('All Pending'),
                ),
                ButtonSegment(
                  value: 'Your Pending Requests',
                  label: Text('Your Pending'),
                ),
              ],
              selected: {_selectedRequestCategory},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedRequestCategory = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: requests.isEmpty
                ? const Center(child: Text('No requests found'))
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return ListTile(
                        leading: Icon(
                          Icons.car_repair,
                          color: _getStatusColor(request.status),
                        ),
                        title: Text('Request #${request.id}'),
                        subtitle: Text(request.description),
                        onTap: () => _zoomToRequest(request),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _zoomToRequest(ServiceRequest request) {
    _mapController.move(
      latlng.LatLng(request.latitude, request.longitude),
      16.0,
    );
    setState(() {
      _selectedRequest = request;
      _showRequestsMenu = false;
    });
  }

  Widget _buildTopControls() {
    final theme = Theme.of(context);
    final isMechanic = context.read<AuthProvider>().isMechanic;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            FloatingActionButton(
              heroTag: 'back',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'refresh',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.refresh, color: Colors.black),
            ),
            const SizedBox(width: 10),
            if (!isMechanic) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search nearby mechanics...',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            if (isMechanic) ...[
              FloatingActionButton(
                heroTag: 'list',
                mini: true,
                backgroundColor: _showRequestsList
                    ? theme.colorScheme.primary
                    : Colors.white,
                onPressed: _toggleRequestsList,
                child: Icon(
                  Icons.list,
                  color: _showRequestsList ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                heroTag: 'menu',
                mini: true,
                backgroundColor: _showRequestsMenu
                    ? theme.colorScheme.primary
                    : Colors.white,
                onPressed: _toggleRequestsMenu,
                child: Icon(
                  Icons.menu,
                  color: _showRequestsMenu ? Colors.white : Colors.black,
                ),
              ),
            ] else ...[
              FloatingActionButton(
                heroTag: 'mechanics_toggle',
                mini: true,
                backgroundColor: _showMechanics
                    ? theme.colorScheme.primary
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _showMechanics = !_showMechanics;
                    _updateMarkers();
                  });
                },
                child: Icon(
                  Icons.garage,
                  color: _showMechanics ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                heroTag: 'mechanics_list',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () =>
                    Navigator.pushNamed(context, '/nearby-mechanics'),
                child: const Icon(Icons.list, color: Colors.black),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    if (!context.read<AuthProvider>().isMechanic) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleRequestsList,
                ),
              ],
            ),
          ),
          Expanded(
            child: _nearbyRequests.isEmpty
                ? const Center(child: Text('No nearby requests found'))
                : ListView.builder(
                    itemCount: _nearbyRequests.length,
                    itemBuilder: (context, index) {
                      final request = _nearbyRequests[index];
                      return ListTile(
                        leading: Icon(
                          Icons.car_repair,
                          color: _getStatusColor(request.status),
                        ),
                        title: Text(
                          'Request #${request.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          request.description,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${request.distance?.toStringAsFixed(1) ?? 'N/A'} km',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () => _onMarkerTapped(request),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition != null
                  ? latlng.LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : latlng.LatLng(-1.2921, 36.8219),
              zoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading) const ShimmerLoadingOverlay(),
          Positioned(top: 0, left: 0, right: 0, child: _buildTopControls()),
          if (_selectedRequest != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RequestInfoCard(
                request: _selectedRequest!,
                onAccept: () => _acceptRequest(_selectedRequest!.id),
                onClose: () => setState(() => _selectedRequest = null),
              ),
            ),
          if (_showRequestsList || _listAnimationController.isAnimating)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              bottom: _selectedRequest != null ? 180 : 16,
              child: SlideTransition(
                position: _listSlideAnimation,
                child: FadeTransition(
                  opacity: _listOpacityAnimation,
                  child: _buildRequestsList(),
                ),
              ),
            ),
          if (_showRequestsMenu)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildRequestsMenu(),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: context.watch<AuthProvider>().isMechanic
          ? _buildMechanicFAB()
          : _buildOwnerFAB(),
    );
  }
}

class RequestInfoCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onAccept;
  final VoidCallback onClose;

  const RequestInfoCard({
    Key? key,
    required this.request,
    required this.onAccept,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request #${request.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 10),
          Text(request.description),
          const SizedBox(height: 10),
          Text(
            'Distance: ${request.distance?.toStringAsFixed(1) ?? 'N/A'} km',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (request.carModel != null || request.carPlate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  if (request.carModel != null)
                    Chip(
                      label: Text(request.carModel!),
                      backgroundColor: Colors.blue[50],
                    ),
                  const SizedBox(width: 8),
                  if (request.carPlate != null)
                    Chip(
                      label: Text(request.carPlate!),
                      backgroundColor: Colors.green[50],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAccept,
              child: const Text('Accept Request'),
            ),
          ),
        ],
      ),
    );
  }
}
