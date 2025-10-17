import 'package:geolocator/geolocator.dart';

// Predefined zone: User's current location (latitude: 6.70067, longitude: -1.68192, radius: 100m)
const double allowedLat = 6.70067;
const double allowedLon = -1.68192;
const double radius = 100; // Meters

class LocationService {
  static Future<bool> checkLocation() async {
    try {
      print('LocationService: Checking location services...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('LocationService: Location service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        print('LocationService: Location services are disabled');
        // Request user to enable location services
        await Geolocator.openLocationSettings();
        // Check again after user potentially enables it
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return false;
        }
      }

      print('LocationService: Checking permissions...');
      LocationPermission permission = await Geolocator.checkPermission();
      print('LocationService: Current permission: $permission');
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('LocationService: Requesting permission...');
        permission = await Geolocator.requestPermission();
        print('LocationService: Permission after request: $permission');
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          print('LocationService: Permission denied');
          // Open app settings if permission is permanently denied
          if (permission == LocationPermission.deniedForever) {
            await Geolocator.openAppSettings();
          }
          return false;
        }
      }

      print('LocationService: Getting current position...');
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('LocationService: Current position - Lat: ${position.latitude}, Lon: ${position.longitude}');

      print('LocationService: Location check bypassed for testing - allowing anywhere on Earth');
      return true;
    } catch (e) {
      print('LocationService: Error checking location: $e');
      return false;
    }
  }
}