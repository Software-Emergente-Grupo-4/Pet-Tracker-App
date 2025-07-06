import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/shared/widgets/polygon_utils.dart';
import 'package:latlong2/latlong.dart';

class MapNotifier extends ChangeNotifier {
  final MapController mapController;
  List<LatLng> geofencePoints = [];
  final Distance distance = const Distance();

  MapNotifier({required this.mapController});

  void initializePoints(List<LatLng> initialPoints) {
    geofencePoints =
        PolygonUtils.convexHull(initialPoints); // Usamos Convex Hull
    notifyListeners();
  }

  void addGeofencePoint(LatLng point) {
    if (geofencePoints.length < 4) {
      geofencePoints.add(point);
      geofencePoints =
          PolygonUtils.convexHull(geofencePoints);
      notifyListeners();
    }
  }

  void removeGeofencePoint(int index) {
    if (index >= 0 && index < geofencePoints.length) {
      geofencePoints.removeAt(index);
      geofencePoints =
          PolygonUtils.convexHull(geofencePoints);
      notifyListeners();
    }
  }

  void moveToLocation(LatLng position) {
    mapController.move(position, 15);
  }
}

final mapProvider = ChangeNotifierProvider<MapNotifier>((ref) {
  return MapNotifier(mapController: MapController());
});
