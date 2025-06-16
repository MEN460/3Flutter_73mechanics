import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:mechanic_discovery_app/models/user_model.dart';
import 'package:mechanic_discovery_app/providers/location_provider.dart';
import 'package:mechanic_discovery_app/screens/map_screen.dart';
import 'package:mechanic_discovery_app/services/api_service.dart';
import 'package:mechanic_discovery_app/services/storage_service.dart';
import 'package:mechanic_discovery_app/services/api_endpoints.dart';
import 'package:mechanic_discovery_app/widgets/cards/mechanic_card.dart';

class NearbyMechanicsScreen extends StatefulWidget {
  const NearbyMechanicsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyMechanicsScreen> createState() => _NearbyMechanicsScreenState();
}

class _NearbyMechanicsScreenState extends State<NearbyMechanicsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<UserModel>> _mechanicsFuture;
  List<UserModel> _mechanics = [];
  late TabController _tabController;
  bool _isFullScreenMap = false;
  bool _isFullScreenList = false;
  bool _tabControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _mechanicsFuture = _getNearbyMechanics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tabControllerInitialized) {
      _tabController = TabController(length: 2, vsync: this);
      _tabControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    if (_tabControllerInitialized) {
      _tabController.dispose();
    }
    super.dispose();
  }

  Future<List<UserModel>> _getNearbyMechanics() async {
    final locationProvider = context.read<LocationProvider>();
    final storageService = context.read<StorageService>();
    final apiService = context.read<ApiService>();

    final location = await locationProvider.getCurrentPosition();
    final token = await storageService.getAccessToken();

    if (location == null) {
      throw Exception('Location services are disabled or permission denied');
    }

    if (token == null) {
      throw Exception('Authentication required');
    }

    try {
      final response = await apiService.get(
        '${ApiEndpoints.nearbyMechanics}?latitude=${location.latitude}&longitude=${location.longitude}',
        token: token,
      );

      if (response is! List) throw const FormatException('Expected List');
      _mechanics = response.map((item) => UserModel.fromJson(item)).toList();
      return _mechanics;
    } catch (e) {
      throw Exception('Failed to load mechanics: $e');
    }
  }

  void _showMechanicProfile(BuildContext context, UserModel mechanic) {
    Navigator.pushNamed(context, '/mechanic-profile', arguments: mechanic);
  }

  void _refreshMechanics() {
    setState(() {
      _mechanicsFuture = _getNearbyMechanics();
    });
  }

  void _toggleFullScreenMap() {
    setState(() {
      _isFullScreenMap = !_isFullScreenMap;
      if (_isFullScreenMap) _isFullScreenList = false;
    });
  }

  void _toggleFullScreenList() {
    setState(() {
      _isFullScreenList = !_isFullScreenList;
      if (_isFullScreenList) _isFullScreenMap = false;
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Nearby Mechanics'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshMechanics,
          tooltip: 'Refresh',
        ),
      ],
      bottom: !_isFullScreenMap && !_isFullScreenList
          ? TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'List'),
                Tab(icon: Icon(Icons.map), text: 'Map'),
              ],
            )
          : null,
    );
  }

  Widget _buildListTab(List<UserModel> mechanics) {
    return Column(
      children: [
        if (!_isFullScreenMap && !_isFullScreenList)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreenList,
                  tooltip: 'Maximize list',
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: mechanics.length,
            itemBuilder: (context, index) => MechanicCard(
              mechanic: mechanics[index],
              onTap: () => _showMechanicProfile(context, mechanics[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapTab(Position? position) {
    return Column(
      children: [
        if (!_isFullScreenMap && !_isFullScreenList)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreenMap,
                  tooltip: 'Maximize map',
                ),
              ],
            ),
          ),
        Expanded(
          child: MapScreen(
            showMechanics: true,
            initialMechanics: _mechanics,
            initialPosition: position,
          ),
        ),
      ],
    );
  }

  Scaffold _buildFullScreenList(List<UserModel> mechanics) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanics List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_fullscreen),
            onPressed: _toggleFullScreenList,
            tooltip: 'Exit fullscreen',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: mechanics.length,
        itemBuilder: (context, index) => MechanicCard(
          mechanic: mechanics[index],
          onTap: () => _showMechanicProfile(context, mechanics[index]),
        ),
      ),
    );
  }

  Scaffold _buildFullScreenMap(Position? position) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanics Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_fullscreen),
            onPressed: _toggleFullScreenMap,
            tooltip: 'Exit fullscreen',
          ),
        ],
      ),
      body: MapScreen(
        showMechanics: true,
        initialMechanics: _mechanics,
        initialPosition: position,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_tabControllerInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final locationProvider = context.watch<LocationProvider>();
    final position = locationProvider.currentPosition;

    if (_isFullScreenMap) {
      return _buildFullScreenMap(position);
    }

    if (_isFullScreenList) {
      return _buildFullScreenList(_mechanics);
    }

    return FutureBuilder<List<UserModel>>(
      future: _mechanicsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text('Finding nearby mechanics...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      onPressed: _refreshMechanics,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final mechanics = snapshot.data ?? [];

        if (mechanics.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      color: Theme.of(context).colorScheme.primary,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No mechanics found nearby',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try refreshing or updating your location',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      onPressed: _refreshMechanics,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: [_buildListTab(mechanics), _buildMapTab(position)],
          ),
        );
      },
    );
  }
}
