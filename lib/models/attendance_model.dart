enum AttendanceStatus { present, late, absent }
enum BiometricMethod { fingerprint, face, manual }

class Attendance {
  final String id;
  final String userId;
  final String sessionId;
  final DateTime timestamp;
  final AttendanceStatus status;
  final BiometricMethod method;
  final String locationId;
  final double? latitude;
  final double? longitude;
  final String? deviceInfo;
  final String? notes;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.timestamp,
    this.status = AttendanceStatus.present,
    this.method = BiometricMethod.fingerprint,
    required this.locationId,
    this.latitude,
    this.longitude,
    this.deviceInfo,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.index,
      'method': method.index,
      'locationId': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'deviceInfo': deviceInfo,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      userId: map['userId'],
      sessionId: map['sessionId'],
      timestamp: DateTime.parse(map['timestamp']),
      status: AttendanceStatus.values[map['status']],
      method: BiometricMethod.values[map['method']],
      locationId: map['locationId'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      deviceInfo: map['deviceInfo'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Check if attendance was marked on time
  bool get isOnTime => status != AttendanceStatus.late;

  // Get formatted timestamp
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted date
  String get formattedDate {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }

  Attendance copyWith({
    String? id,
    String? userId,
    String? sessionId,
    DateTime? timestamp,
    AttendanceStatus? status,
    BiometricMethod? method,
    String? locationId,
    double? latitude,
    double? longitude,
    String? deviceInfo,
    String? notes,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      method: method ?? this.method,
      locationId: locationId ?? this.locationId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
