import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smartattend/models/user_provider.dart';
import 'package:smartattend/models/attendance_session_model.dart';
import 'package:smartattend/models/class_model.dart';
import 'package:smartattend/services/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class SessionManagementScreen extends StatefulWidget {
  @override
  _SessionManagementScreenState createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  bool _isLoading = false;
  AttendanceSession? _activeSession;
  List<Class> _availableClasses = [];
  Class? _selectedClass;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadAvailableClasses();
    _checkActiveSession();
  }

  Future<void> _loadAvailableClasses() async {
    try {
      // Load classes that the lecturer teaches
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final lecturerId = userProvider.userId;

      if (lecturerId != null) {
        // For now, load all classes - in real app, filter by lecturer
        _availableClasses = await DatabaseHelper.instance.getAllClasses();
        setState(() {});
      }
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _checkActiveSession() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final lecturerId = userProvider.userId;

      if (lecturerId != null) {
        // Check for active sessions by this lecturer
        final sessions = await DatabaseHelper.instance.getActiveSessionsByLecturer(lecturerId);
        if (sessions.isNotEmpty) {
          setState(() {
            _activeSession = sessions.first;
          });
        }
      }
    } catch (e) {
      print('Error checking active session: $e');
    }
  }

  Future<void> _startSession() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a class first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final lecturerId = userProvider.userId;

      if (lecturerId == null) {
        throw Exception('Lecturer not logged in');
      }

      final session = AttendanceSession(
        id: _uuid.v4(),
        classId: _selectedClass!.id,
        lecturerId: lecturerId,
        scheduleId: 'current_schedule', // In real app, get from schedule
        startTime: DateTime.now(),
        locationId: 'main_campus',
        status: SessionStatus.active,
        totalStudents: await DatabaseHelper.instance.getStudentCountForClass(_selectedClass!.id),
      );

      await DatabaseHelper.instance.insertAttendanceSession(session);

      setState(() {
        _activeSession = session;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance session started successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting session: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _endSession() async {
    if (_activeSession == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSession = _activeSession!.copyWith(
        endTime: DateTime.now(),
        status: SessionStatus.completed,
      );

      await DatabaseHelper.instance.updateAttendanceSession(updatedSession);

      setState(() {
        _activeSession = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance session ended successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending session: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: _activeSession != null
                  ? _buildActiveSessionView()
                  : _buildSessionSetupView(),
            ),
    );
  }

  Widget _buildSessionSetupView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start New Attendance Session',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select a class and start taking attendance',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 32),

        // Class Selection
        Text(
          'Select Class',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<Class>(
          value: _selectedClass,
          hint: Text('Choose a class'),
          items: _availableClasses.map((classModel) {
            return DropdownMenuItem<Class>(
              value: classModel,
              child: Text('${classModel.courseName} (${classModel.courseCode})'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClass = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        SizedBox(height: 32),

        // Start Session Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedClass != null ? _startSession : null,
            child: Text('START ATTENDANCE SESSION'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Status Card
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Session Active',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Class: ${_activeSession!.classId}'),
                Text('Started: ${DateFormat('MMM dd, hh:mm a').format(_activeSession!.startTime)}'),
                Text('Present: ${_activeSession!.presentCount}/${_activeSession!.totalStudents}'),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),

        // QR Code Section
        Text(
          'Session QR Code',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 16),
        Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: QrImageView(
              data: _activeSession!.id,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Students can scan this QR code to mark their attendance',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // End Session Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _endSession,
            child: Text('END SESSION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
