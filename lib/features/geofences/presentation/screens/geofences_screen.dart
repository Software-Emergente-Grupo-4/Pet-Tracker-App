import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/geofences/presentation/providers/geofence_provider.dart';
import 'package:pet_tracker/features/geofences/presentation/widgets/geofence_card.dart';

class GeofencesScreen extends ConsumerStatefulWidget {
  const GeofencesScreen({super.key});

  @override
  GeofencesScreenState createState() => GeofencesScreenState();
}

class GeofencesScreenState extends ConsumerState<GeofencesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geofenceProvider.notifier).loadGeofences();
    });
  }

  Future<void> _refreshGeofences() async {
    await ref.read(geofenceProvider.notifier).loadGeofences();
  }

  @override
  Widget build(BuildContext context) {
    final geofenceState = ref.watch(geofenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List of geofences',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: geofenceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : geofenceState.geofences.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Geofences not found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshGeofences,
                  color: const Color(0xFF08273A),
                  child: ListView.builder(
                    itemCount: geofenceState.geofences.length,
                    itemBuilder: (context, index) {
                      final geofence = geofenceState.geofences[index];
                      return GestureDetector(
                        onTap: () {
                          context.go('/geofences/detail/${geofence.id}',
                              extra: geofence);
                        },
                        child: GeofenceCard(geofence: geofence),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/geofences/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
