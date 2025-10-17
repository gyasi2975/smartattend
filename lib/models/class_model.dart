class Class {
  final String id;
  final String courseCode;
  final String courseName;
  final String lecturerId;
  final String department;
  final int semester;
  final int academicYear;
  final int maxStudents;
  final String? description;
  final DateTime createdAt;

  Class({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.lecturerId,
    required this.department,
    required this.semester,
    required this.academicYear,
    required this.maxStudents,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'lecturerId': lecturerId,
      'department': department,
      'semester': semester,
      'academicYear': academicYear,
      'maxStudents': maxStudents,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
      id: map['id'],
      courseCode: map['courseCode'],
      courseName: map['courseName'],
      lecturerId: map['lecturerId'],
      department: map['department'],
      semester: map['semester'],
      academicYear: map['academicYear'],
      maxStudents: map['maxStudents'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
