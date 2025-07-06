import 'package:latlong2/latlong.dart';

class PolygonUtils {
  static List<LatLng> convexHull(List<LatLng> points) {
    if (points.length <= 3) return points;

    points.sort((a, b) {
      if (a.latitude == b.latitude) {
        return a.longitude.compareTo(b.longitude);
      }
      return a.latitude.compareTo(b.latitude);
    });

    List<LatLng> lower = [];
    for (LatLng point in points) {
      while (lower.length >= 2 &&
          _cross(lower[lower.length - 2], lower[lower.length - 1], point) <=
              0) {
        lower.removeLast();
      }
      lower.add(point);
    }

    List<LatLng> upper = [];
    for (LatLng point in points.reversed) {
      while (upper.length >= 2 &&
          _cross(upper[upper.length - 2], upper[upper.length - 1], point) <=
              0) {
        upper.removeLast();
      }
      upper.add(point);
    }

    lower.removeLast();
    upper.removeLast();
    lower.addAll(upper);
    return lower;
  }

  static double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }
}
