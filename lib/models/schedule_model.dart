import 'package:flutter/material.dart';

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class ClassSchedule {
  final String id;
  final String classId;
  final DayOfWeek dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final String locationId;
  final String room;
  final bool isActive;
  final DateTime createdAt;

  ClassSchedule({
    required this.id,
    required this.classId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    required this.room,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'dayOfWeek': dayOfWeek.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'locationId': locationId,
      'room': room,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassSchedule.fromMap(Map<String, dynamic> map) {
    return ClassSchedule(
      id: map['id'],
      classId: map['classId'],
      dayOfWeek: DayOfWeek.values[map['dayOfWeek']],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      locationId: map['locationId'],
      room: map['room'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Helper method to get time string
  String get timeString {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  // Check if schedule is currently active
  bool isCurrentlyActive() {
    final now = DateTime.now();
    final today = DayOfWeek.values[now.weekday - 1]; // DateTime weekday is 1-7, enum is 0-6

    if (dayOfWeek != today || !isActive) return false;

    final currentTime = TimeOfDay.fromDateTime(now);
    final startTOD = TimeOfDay.fromDateTime(startTime);
    final endTOD = TimeOfDay.fromDateTime(endTime);

    // Compare TimeOfDay by converting to minutes
    int currentMinutes = currentTime.hour * 60 + currentTime.minute;
    int startMinutes = startTOD.hour * 60 + startTOD.minute;
    int endMinutes = endTOD.hour * 60 + endTOD.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }
}
