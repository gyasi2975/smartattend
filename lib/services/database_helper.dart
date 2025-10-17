import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smartattend/models/attendance_model.dart';
import 'package:smartattend/models/user_model.dart';
import 'package:smartattend/models/class_model.dart';
import 'package:smartattend/models/schedule_model.dart';
import 'package:smartattend/models/campus_location_model.dart';
import 'package:smartattend/models/attendance_session_model.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartattend_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  department TEXT NOT NULL,
  role INTEGER NOT NULL,
  profilePicturePath TEXT,
  preferredBiometricMethod TEXT,
  faceEnrolled INTEGER DEFAULT 0,
  fingerprintEnrolled INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,
  lastLoginAt TEXT
)
''');

    // Classes table
    await db.execute('''
CREATE TABLE classes (
  id TEXT PRIMARY KEY,
  courseCode TEXT NOT NULL,
  courseName TEXT NOT NULL,
  lecturerId TEXT NOT NULL,
  department TEXT NOT NULL,
  semester INTEGER NOT NULL,
  academicYear INTEGER NOT NULL,
  maxStudents INTEGER NOT NULL,
  description TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (lecturerId) REFERENCES users (id)
)
''');

    // Class schedules table
    await db.execute('''
CREATE TABLE class_schedules (
  id TEXT PRIMARY KEY,
  classId TEXT NOT NULL,
  dayOfWeek INTEGER NOT NULL,
  startTime TEXT NOT NULL,
  endTime TEXT NOT NULL,
  locationId TEXT NOT NULL,
  room TEXT NOT NULL,
  isActive INTEGER DEFAULT 1,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (classId) REFERENCES classes (id)
)
''');

    // Campus locations table
    await db.execute('''
CREATE TABLE campus_locations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  radius REAL NOT NULL,
  isActive INTEGER DEFAULT 1,
  createdAt TEXT NOT NULL
)
''');

    // Attendance sessions table
    await db.execute('''
CREATE TABLE attendance_sessions (
  id TEXT PRIMARY KEY,
  classId TEXT NOT NULL,
  lecturerId TEXT NOT NULL,
  scheduleId TEXT NOT NULL,
  startTime TEXT NOT NULL,
  endTime TEXT,
  status INTEGER NOT NULL,
  totalStudents INTEGER DEFAULT 0,
  presentCount INTEGER DEFAULT 0,
  lateCount INTEGER DEFAULT 0,
  locationId TEXT NOT NULL,
  notes TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (classId) REFERENCES classes (id),
  FOREIGN KEY (lecturerId) REFERENCES users (id),
  FOREIGN KEY (scheduleId) REFERENCES class_schedules (id)
)
''');

    // Attendance records table
    await db.execute('''
CREATE TABLE attendance (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  sessionId TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  status INTEGER NOT NULL,
  method INTEGER NOT NULL,
  locationId TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  deviceInfo TEXT,
  notes TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users (id),
  FOREIGN KEY (sessionId) REFERENCES attendance_sessions (id)
)
''');

    // Insert default campus location
    await db.insert('campus_locations', {
      'id': 'main_campus',
      'name': 'AAMUSTED Main Campus',
      'description': 'Main university campus location',
      'latitude': 6.70067,
      'longitude': -1.68192,
      'radius': 100.0,
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration logic for version 2
      // This would handle migrating from the old schema to the new one
      // For now, we'll recreate the database
      await _createDB(db, newVersion);
    }
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<User>> getUsersByRole(UserRole role) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role.index],
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Class operations
  Future<int> insertClass(Class classObj) async {
    final db = await instance.database;
    return await db.insert('classes', classObj.toMap());
  }

  Future<List<Class>> getClassesByLecturer(String lecturerId) async {
    final db = await instance.database;
    final maps = await db.query(
      'classes',
      where: 'lecturerId = ?',
      whereArgs: [lecturerId],
    );

    return maps.map((map) => Class.fromMap(map)).toList();
  }

  // Schedule operations
  Future<int> insertSchedule(ClassSchedule schedule) async {
    final db = await instance.database;
    return await db.insert('class_schedules', schedule.toMap());
  }

  Future<List<ClassSchedule>> getSchedulesByClass(String classId) async {
    final db = await instance.database;
    final maps = await db.query(
      'class_schedules',
      where: 'classId = ?',
      whereArgs: [classId],
    );

    return maps.map((map) => ClassSchedule.fromMap(map)).toList();
  }

  // Location operations
  Future<int> insertLocation(CampusLocation location) async {
    final db = await instance.database;
    return await db.insert('campus_locations', location.toMap());
  }

  Future<List<CampusLocation>> getActiveLocations() async {
    final db = await instance.database;
    final maps = await db.query(
      'campus_locations',
      where: 'isActive = ?',
      whereArgs: [1],
    );

    return maps.map((map) => CampusLocation.fromMap(map)).toList();
  }

  // Session operations
  Future<int> insertSession(AttendanceSession session) async {
    final db = await instance.database;
    return await db.insert('attendance_sessions', session.toMap());
  }

  Future<List<AttendanceSession>> getSessionsByLecturer(String lecturerId) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance_sessions',
      where: 'lecturerId = ?',
      whereArgs: [lecturerId],
      orderBy: 'startTime DESC',
    );

    return maps.map((map) => AttendanceSession.fromMap(map)).toList();
  }

  // Attendance operations
  Future<int> insertAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<List<Attendance>> getAttendanceByUserId(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<List<Attendance>> getAttendanceBySession(String sessionId) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => Attendance.fromMap(map)).toList();
  }

  // Complex queries
  Future<List<Map<String, dynamic>>> getStudentAttendanceStatsDetailed(String userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT
        DATE(timestamp) as date,
        COUNT(*) as total_sessions,
        SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) as present_count,
        SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as late_count
      FROM attendance
      WHERE userId = ?
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
    ''', [userId]);
  }

  Future<Map<String, dynamic>?> getClassAttendanceSummary(String classId) async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT
        COUNT(DISTINCT a.userId) as total_students,
        COUNT(CASE WHEN a.status = 0 THEN 1 END) as present_count,
        COUNT(CASE WHEN a.status = 1 THEN 1 END) as late_count,
        AVG(CASE WHEN a.status IN (0,1) THEN 1.0 ELSE 0.0 END) * 100 as attendance_percentage
      FROM attendance a
      INNER JOIN attendance_sessions s ON a.sessionId = s.id
      WHERE s.classId = ?
    ''', [classId]);

    return results.isNotEmpty ? results.first : null;
  }

  // Student-specific queries
  Future<List<Class>> getTodayClassesForStudent(String studentId) async {
    final db = await instance.database;
    final now = DateTime.now();
    final today = now.weekday - 1; // Convert to enum index (0-6)

    final maps = await db.rawQuery('''
      SELECT DISTINCT c.* FROM classes c
      INNER JOIN class_schedules cs ON c.id = cs.classId
      WHERE cs.dayOfWeek = ? AND cs.isActive = 1
      ORDER BY cs.startTime ASC
    ''', [today]);

    return maps.map((map) => Class.fromMap(map)).toList();
  }

  Future<List<ClassSchedule>> getStudentSchedule(String studentId) async {
    final db = await instance.database;

    final maps = await db.rawQuery('''
      SELECT cs.* FROM class_schedules cs
      INNER JOIN classes c ON cs.classId = c.id
      WHERE cs.isActive = 1
      ORDER BY cs.dayOfWeek ASC, cs.startTime ASC
    ''');

    return maps.map((map) => ClassSchedule.fromMap(map)).toList();
  }

  Future<Map<String, int>> getStudentAttendanceStats(String studentId) async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT
        COUNT(*) as total,
        SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) as present
      FROM attendance
      WHERE userId = ?
    ''', [studentId]);

    if (results.isNotEmpty) {
      final row = results.first;
      return {
        'total': row['total'] as int,
        'present': row['present'] as int,
      };
    }
    return {'total': 0, 'present': 0};
  }

  Future<Map<DateTime, List<String>>> getStudentAttendanceCalendar(String studentId) async {
    final db = await instance.database;
    final maps = await db.rawQuery('''
      SELECT
        DATE(timestamp) as date,
        GROUP_CONCAT(DISTINCT CASE WHEN status = 0 THEN 'present' WHEN status = 1 THEN 'late' ELSE 'absent' END) as statuses
      FROM attendance
      WHERE userId = ?
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
    ''', [studentId]);

    Map<DateTime, List<String>> result = {};
    for (var map in maps) {
      final dateStr = map['date'] as String;
      final date = DateTime.parse(dateStr);
      final statuses = (map['statuses'] as String?)?.split(',') ?? [];
      result[date] = statuses;
    }
    return result;
  }

  // Additional methods for session management
  Future<List<Class>> getAllClasses() async {
    final db = await instance.database;
    final maps = await db.query('classes');
    return maps.map((map) => Class.fromMap(map)).toList();
  }

  Future<List<AttendanceSession>> getActiveSessionsByLecturer(String lecturerId) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance_sessions',
      where: 'lecturerId = ? AND status = ?',
      whereArgs: [lecturerId, SessionStatus.active.index],
    );
    return maps.map((map) => AttendanceSession.fromMap(map)).toList();
  }

  Future<int> getStudentCountForClass(String classId) async {
    final db = await instance.database;
    final maps = await db.query('classes', where: 'id = ?', whereArgs: [classId]);
    if (maps.isNotEmpty) {
      return maps.first['maxStudents'] as int;
    }
    return 0;
  }

  Future<int> insertAttendanceSession(AttendanceSession session) async {
    return insertSession(session);
  }

  Future<int> updateAttendanceSession(AttendanceSession session) async {
    final db = await instance.database;
    return await db.update(
      'attendance_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }
}
