import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_tracker/features/home/presentation/providers/current_location_provider.dart';
import 'package:pet_tracker/features/geofences/presentation/providers/geofence_provider.dart';
import 'package:pet_tracker/config/consts/map_token.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocationState = ref.watch(currentLocationProvider);
    final geofenceState = ref.watch(geofenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real Time Monitoring Map',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: MapToken.getMapToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == 'No token found') {
            return const Center(child: Text("Failed to load Map Token"));
          }

          final mapboxToken = snapshot.data!;

          return Stack(
            children: [
              // Mapa principal
              currentLocationState.when(
                data: (currentLocation) {
                  final location = LatLng(
                    currentLocation.latitude,
                    currentLocation.longitude,
                  );
                  final riskColor = currentLocation.riskLevel == 'DANGER'
                      ? Colors.red
                      : Colors.green;

                  return FlutterMap(
                    options: MapOptions(
                      initialCenter: location,
                      initialZoom: 17,
                      maxZoom: 18,
                      minZoom: 14,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: location,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: riskColor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      if (geofenceState.geofences.isNotEmpty)
                        PolygonLayer(
                          polygons: geofenceState.geofences.map((geofence) {
                            final points = geofence.coordinates.map((coord) {
                              return LatLng(coord.latitude, coord.longitude);
                            }).toList();

                            return Polygon(
                              points: points,
                              borderColor: Colors.blue,
                              borderStrokeWidth: 2,
                              color: Colors.blue.withOpacity(0.3),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                    child: SvgPicture.asset(
                  'assets/images/map-location-dot-solid.svg',
                  width: 70,
                  height: 70,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                )),
              ),

              // Información en tiempo real
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: currentLocationState.when(
                        data: (currentLocation) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Risk Level: ${currentLocation.riskLevel}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentLocation.riskLevel == 'DANGER'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Latitude: ${currentLocation.latitude.toStringAsFixed(4)}, '
                              'Longitude: ${currentLocation.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        loading: () =>
                            const Text('Loading current location...'),
                        error: (error, stackTrace) {
                          return const Text(
                            'If you don\'t see the map, please check if you have selected a device.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF08273A),
                              fontWeight: FontWeight.w500
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
