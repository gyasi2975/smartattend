import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For Provider and UserProvider
import 'package:smartattend/models/user_provider.dart'; // Import UserProvider
import 'package:smartattend/services/notification_service.dart'; // Import NotificationService
import 'package:smartattend/services/location_service.dart';
import 'package:smartattend/services/biometric_service.dart' as biometric_service;
import 'package:smartattend/models/attendance_model.dart'; // Import Attendance model
import 'package:smartattend/services/database_helper.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final BiometricMethod? selectedMethod;

  const AttendanceScreen({Key? key, this.selectedMethod}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isLoading = false;
  bool _attendanceMarked = false;
  DateTime? _lastCheckIn;


  @override
  void initState() {
    super.initState();
    _loadLastCheckIn();
  }



  void _loadLastCheckIn() async {
    String? userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      List<Attendance> records =
          await DatabaseHelper.instance.getAttendanceByUserId(userId);
      if (records.isNotEmpty) {
        // Get the most recent check-in
        records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        setState(() {
          _lastCheckIn = records.first.timestamp;
        });
      }
    }
  }

  void _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user is logged in
      String? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in. Please login first.')),
        );
        return;
      }

      print('Starting attendance marking for user: $userId');

      // Check location
      print('Checking location...');
      bool isInZone = await LocationService.checkLocation();
      print('Location check result: $isInZone');

      if (!isInZone) {
        NotificationService.showNotification('Outside permitted zone!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'You are outside the permitted zone. Please enable location services and grant permissions.'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Perform biometric authentication
      print('Performing biometric authentication...');
      var authResult = await biometric_service.BiometricService.authenticate();
      bool authenticated = authResult['success'] ?? false;
      print('Biometric authentication result: $authenticated, method: ${authResult['method']}');

      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed. Please try again or ensure biometrics/device credentials are set up.')),
        );
        return;
      }

      // Create attendance record
      Attendance log = Attendance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        sessionId: 'demo_session', // In real app, this would come from active session
        timestamp: DateTime.now(),
        locationId: 'main_campus',
        latitude: 6.70067,
        longitude: -1.68192,
        method: widget.selectedMethod ?? authResult['method'] ?? BiometricMethod.fingerprint,
      );

      print('Inserting attendance record...');
      int result = await DatabaseHelper.instance.insertAttendance(log);
      print('Database insert result: $result');

      if (result > 0) {
        setState(() {
          _attendanceMarked = true;
          _lastCheckIn = DateTime.now();
        });
        NotificationService.showNotification('Attendance marked successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked successfully!')),
        );
        // Auto navigate back after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        throw Exception('Failed to save attendance record');
      }
    } catch (e) {
      print('Error during attendance marking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
        title: Text('Mark Attendance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calendar Icon
            Icon(Icons.calendar_today,
                size: 80, color: Theme.of(context).colorScheme.primary),
            SizedBox(height: 24),

            // Current Date
            Text(
              'Today, ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),

            // Current Time
            Text(
              'Current Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),

            // Last Check-in info
            if (_lastCheckIn != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Last Check-in: ${DateFormat('MMM dd, hh:mm a').format(_lastCheckIn!)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 40),

            // Mark Now Button or Success Message
            if (!_attendanceMarked)
              if (_isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verifying location and authenticating...'),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _markAttendance,
                    child: Text('MARK NOW', style: TextStyle(fontSize: 16)),
                  ),
                )
            else
              // Success Message
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 16),
                    Text(
                      'Attendance Marked Successfully!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${DateFormat('MMMM dd, yyyy').format(DateTime.now())} at ${DateFormat('hh:mm a').format(DateTime.now())}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
