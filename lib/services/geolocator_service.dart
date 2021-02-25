import 'package:geolocator/geolocator.dart';

class GeoLocatorService {
  // Gets the user's current position
  Future<Position> getLocation() async {
    return await Geolocator.getCurrentPosition()
        .catchError((error) => throw (error));
  }

  // Gets the relative distance between current position and place
  Future<double> getDistance(
      double startLat, double startLng, double endLat, double endLng) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
