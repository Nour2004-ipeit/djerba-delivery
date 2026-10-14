import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RoutingService {
  final Dio _dio = Dio();

  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    try {
      final response = await _dio.get(
        'http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=geojson',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          return coordinates.map((coord) {
            // OSRM returns [longitude, latitude]
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching route: $e');
      return [];
    }
  }

  // Convenience method for multi-point routes (e.g., driver -> restaurant -> delivery)
  Future<List<LatLng>> getMultiPointRoute(List<LatLng> points) async {
    if (points.length < 2) return points;

    try {
      final coordsString = points.map((p) => '${p.longitude},${p.latitude}').join(';');
      final response = await _dio.get(
        'http://router.project-osrm.org/route/v1/driving/$coordsString?geometries=geojson',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          return coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching route: $e');
      return [];
    }
  }
}
