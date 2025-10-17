enum SessionStatus { active, paused, completed, cancelled }

class AttendanceSession {
  final String id;
  final String classId;
  final String lecturerId;
  final String scheduleId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final int totalStudents;
  final int presentCount;
  final int lateCount;
  final String locationId;
  final String? notes;
  final DateTime createdAt;

  AttendanceSession({
    required this.id,
    required this.classId,
    required this.lecturerId,
    required this.scheduleId,
    required this.startTime,
    this.endTime,
    this.status = SessionStatus.active,
    this.totalStudents = 0,
    this.presentCount = 0,
    this.lateCount = 0,
    required this.locationId,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'lecturerId': lecturerId,
      'scheduleId': scheduleId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.index,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'lateCount': lateCount,
      'locationId': locationId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      id: map['id'],
      classId: map['classId'],
      lecturerId: map['lecturerId'],
      scheduleId: map['scheduleId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      status: SessionStatus.values[map['status']],
      totalStudents: map['totalStudents'],
      presentCount: map['presentCount'],
      lateCount: map['lateCount'],
      locationId: map['locationId'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Calculate attendance percentage
  double get attendancePercentage {
    if (totalStudents == 0) return 0.0;
    return ((presentCount + lateCount) / totalStudents) * 100;
  }

  // Check if session is currently active
  bool get isActive => status == SessionStatus.active;

  // Get session duration in minutes
  int get durationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  AttendanceSession copyWith({
    String? id,
    String? classId,
    String? lecturerId,
    String? scheduleId,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
    int? totalStudents,
    int? presentCount,
    int? lateCount,
    String? locationId,
    String? notes,
    DateTime? createdAt,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      lecturerId: lecturerId ?? this.lecturerId,
      scheduleId: scheduleId ?? this.scheduleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
      lateCount: lateCount ?? this.lateCount,
      locationId: locationId ?? this.locationId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
