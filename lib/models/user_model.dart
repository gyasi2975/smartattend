enum UserRole { student, lecturer }

class User {
  final String id;
  final String name;
  final String email;
  final String department;
  final UserRole role;
  final String? profilePicturePath;
  final String? preferredBiometricMethod; // 'face' or 'fingerprint'
  final bool faceEnrolled;
  final bool fingerprintEnrolled;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    this.profilePicturePath,
    this.preferredBiometricMethod,
    this.faceEnrolled = false,
    this.fingerprintEnrolled = false,
    DateTime? createdAt,
    this.lastLoginAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'role': role.index, // Store as int
      'profilePicturePath': profilePicturePath,
      'preferredBiometricMethod': preferredBiometricMethod,
      'faceEnrolled': faceEnrolled ? 1 : 0,
      'fingerprintEnrolled': fingerprintEnrolled ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      department: map['department'],
      role: UserRole.values[map['role']],
      profilePicturePath: map['profilePicturePath'],
      preferredBiometricMethod: map['preferredBiometricMethod'],
      faceEnrolled: map['faceEnrolled'] == 1,
      fingerprintEnrolled: map['fingerprintEnrolled'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    UserRole? role,
    String? profilePicturePath,
    String? preferredBiometricMethod,
    bool? faceEnrolled,
    bool? fingerprintEnrolled,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      role: role ?? this.role,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      preferredBiometricMethod: preferredBiometricMethod ?? this.preferredBiometricMethod,
      faceEnrolled: faceEnrolled ?? this.faceEnrolled,
      fingerprintEnrolled: fingerprintEnrolled ?? this.fingerprintEnrolled,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
