import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class DriverApi {
  final DioClient _dioClient;

  DriverApi(this._dioClient);

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _dioClient.dio.post(
        '/drivers/location',
        data: {
          'lat': lat,
          'lng': lng,
        },
      );
    } on DioException catch (e) {
      print('Location Update Error: ${e.response?.data}');
      throw Exception(e.response?.data['error'] ?? 'Network error');
    }
  }
}
