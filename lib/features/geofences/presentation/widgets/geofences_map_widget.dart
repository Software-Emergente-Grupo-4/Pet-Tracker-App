import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pet_tracker/config/consts/map_token.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_provider.dart';

class GeofenceMapWidget extends ConsumerWidget {
  final Geofence? geofence;
  final bool isEditable;

  static const LatLng defaultLocation = LatLng(-12.0464, -77.0428);

  const GeofenceMapWidget({
    super.key,
    this.geofence,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapNotifier = ref.watch(mapProvider);

    final rawCoords = mapNotifier.geofencePoints.isNotEmpty
        ? mapNotifier.geofencePoints
        : geofence?.coordinates
            .map((coord) => LatLng(coord.latitude, coord.longitude))
            .toList() ?? [];

    final coordinates = rawCoords.isNotEmpty ? rawCoords : [defaultLocation];

    final cameraFit = CameraFit.coordinates(
      coordinates: coordinates,
      padding: const EdgeInsets.all(8),
      maxZoom: 17.0,
      minZoom: 10.0,
    );

    return SizedBox(
      height: isEditable ? 400 : 200,
      child: FutureBuilder<String>(
        future: MapToken.getMapToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == 'No token found') {
            return const Center(child: Text("Token not found"));
          }

          final mapboxToken = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
              initialCameraFit: cameraFit,
              onTap: isEditable && coordinates.length < 4
                  ? (tapPosition, point) {
                      ref.read(mapProvider).addGeofencePoint(point);
                    }
                  : null,
              interactionOptions: InteractionOptions(
                flags: isEditable ? InteractiveFlag.all : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                additionalOptions: {
                  'accessToken': mapboxToken,
                  'id': 'mapbox.streets',
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
                    .asMap()
                    .entries
                    .map((entry) => Marker(
                          point: entry.value,
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 10,
                              ),
                              Positioned(
                                left: 2,
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
