import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_tracker/config/consts/map_token.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';

class GeofenceCard extends StatelessWidget {
  final Geofence geofence;

  const GeofenceCard({super.key, required this.geofence});

  @override
  Widget build(BuildContext context) {
    final coordinates = geofence.coordinates
        .map((coord) => LatLng(coord.latitude, coord.longitude))
        .toList();

    if (coordinates.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Geofence has no coordinates", style: TextStyle(color: Colors.red)),
        ),
      );
    }

    // !CameraFit -> FitCoordinates: ajusta todas las coordenadas
    final cameraFit = CameraFit.coordinates(
      coordinates: coordinates,
      padding: const EdgeInsets.all(8),
      maxZoom: 17.0,
      minZoom: 10.0,
      forceIntegerZoomLevel: false,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: MapToken.getMapToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data == 'No token found') {
                return const SizedBox(
                  height: 150,
                  child: Center(child: Text("Token no encontrado")),
                );
              }

              final mapboxToken = snapshot.data!;
              return SizedBox(
                height: 150,
                child: FlutterMap(
                  options: MapOptions(
                    initialCameraFit: cameraFit,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                      additionalOptions: {
                        'accessToken': mapboxToken,
                        'id': 'mapbox.streets'
                      },
                    ),
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: coordinates,
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: coordinates
                          .map((point) => Marker(
                                point: point,
                                width: 20,
                                height: 20,
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 13,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  geofence.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Status: ${geofence.geoFenceStatus}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
