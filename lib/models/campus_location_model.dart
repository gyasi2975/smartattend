class CampusLocation {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final bool isActive;
  final DateTime createdAt;

  CampusLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CampusLocation.fromMap(Map<String, dynamic> map) {
    return CampusLocation(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      radius: map['radius'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Calculate distance from a point using basic approximation
  double distanceFrom(double lat, double lon) {
    // Simple distance calculation for demo purposes
    // In production, use proper geodetic calculations
    double latDiff = lat - latitude;
    double lonDiff = lon - longitude;
    // Rough approximation: 1 degree ≈ 111km at equator
    double latDistance = latDiff.abs() * 111000;
    double lonDistance = lonDiff.abs() * 111000; // Simplified, ignoring latitude adjustment
    // Use Pythagorean theorem for distance
    double distance = (latDistance * latDistance + lonDistance * lonDistance);
    // Simple square root approximation
    double result = distance;
    for (int i = 0; i < 10; i++) {
      result = (result + distance / result) / 2;
    }
    return result;
  }

  // Check if a point is within the location radius
  bool containsPoint(double lat, double lon) {
    return distanceFrom(lat, lon) <= radius;
  }


}
