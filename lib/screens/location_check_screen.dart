import 'package:flutter/material.dart';
import 'package:smartattend/services/location_service.dart';

class LocationCheckScreen extends StatefulWidget {
  @override
  _LocationCheckScreenState createState() => _LocationCheckScreenState();
}

class _LocationCheckScreenState extends State<LocationCheckScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Tap "Check Location" to verify your position';
  IconData _statusIcon = Icons.location_on;
  Color _statusColor = Colors.grey;

  void _checkLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking location...';
      _statusIcon = Icons.location_searching;
      _statusColor = Colors.deepPurple;
    });

    try {
      bool isInZone = await LocationService.checkLocation();
      setState(() {
        _isLoading = false;
        if (isInZone) {
          _statusMessage = '✅ You are inside AAMUSTED zone';
          _statusIcon = Icons.check_circle;
          _statusColor = Colors.green;
        } else {
          _statusMessage = '❌ You are outside the allowed zone';
          _statusIcon = Icons.error;
          _statusColor = Colors.red;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
        _statusIcon = Icons.error_outline;
        _statusColor = Colors.orange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Check'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Icon(
              _statusIcon,
              size: 100,
              color: _statusColor,
            ),
            SizedBox(height: 24),

            // Status Message
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _statusColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),

            // Check Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 16),
                          Text('Checking...'),
                        ],
                      )
                    : Text(
                        'Check Location',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),

            SizedBox(height: 24),

            // Zone Information
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'AAMUSTED Main Campus Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Latitude: 6.70067\nLongitude: -1.68192\nRadius: 100 meters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.shade700,
                    ),
                    textAlign: TextAlign.center,
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
