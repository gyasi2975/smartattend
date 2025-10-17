import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartattend/models/attendance_model.dart';
import 'package:smartattend/models/user_provider.dart';
import 'package:smartattend/models/user_model.dart';
import 'package:smartattend/services/database_helper.dart';

class RecordsScreen extends StatefulWidget {
  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Attendance> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        final records = await DatabaseHelper.instance.getAttendanceByUserId(userId);
        setState(() {
          _records = records;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load records: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.role == UserRole.student ? 'My Attendance Records' : 'Class Attendance Reports'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _records.isEmpty
                  ? Center(child: Text('No attendance records found'))
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                            title: Text(
                              record.formattedDate,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time: ${record.formattedTime}'),
                                Text('Method: ${record.method.name}'),
                                Text('Status: ${record.status.name}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
