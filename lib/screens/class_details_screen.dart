import 'package:flutter/material.dart';
import 'package:smartattend/services/database_helper.dart';
import 'package:smartattend/models/class_model.dart';

class ClassDetailsScreen extends StatefulWidget {
  final String classId;

  ClassDetailsScreen({required this.classId});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  Class? _classObj;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _recentSessions = [];
  Map<String, dynamic> _attendanceStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassDetails();
  }

  Future<void> _loadClassDetails() async {
    try {
      // Load class information
      final classes = await DatabaseHelper.instance.getAllClasses();
      _classObj = classes.firstWhere((c) => c.id == widget.classId);

      // Load enrolled students (placeholder data)
      _students = [
        {
          'id': 'STU001',
          'name': 'Alice Johnson',
          'attendance': 95.5,
          'status': 'excellent',
        },
        {
          'id': 'STU002',
          'name': 'Bob Smith',
          'attendance': 78.3,
          'status': 'good',
        },
        {
          'id': 'STU003',
          'name': 'Carol Davis',
          'attendance': 65.2,
          'status': 'at_risk',
        },
      ];

      // Load recent sessions (placeholder data)
      _recentSessions = [
        {
          'date': DateTime.now().subtract(Duration(days: 1)),
          'present': 28,
          'total': 30,
          'percentage': 93.3,
        },
        {
          'date': DateTime.now().subtract(Duration(days: 3)),
          'present': 26,
          'total': 30,
          'percentage': 86.7,
        },
        {
          'date': DateTime.now().subtract(Duration(days: 7)),
          'present': 29,
          'total': 30,
          'percentage': 96.7,
        },
      ];

      // Calculate attendance statistics
      _attendanceStats = {
        'averageAttendance': 85.5,
        'totalSessions': 15,
        'totalStudents': _students.length,
        'atRiskStudents': _students.where((s) => s['status'] == 'at_risk').length,
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading class details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Class Details'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_classObj == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Class Details'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text('Class not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_classObj!.courseCode} - ${_classObj!.courseName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit_class', arguments: widget.classId),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareClassInfo(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Overview Card
            _buildClassOverview(),
            SizedBox(height: 24),

            // Attendance Statistics
            _buildAttendanceStats(),
            SizedBox(height: 24),

            // Recent Sessions
            _buildRecentSessions(),
            SizedBox(height: 24),

            // Student Roster
            _buildStudentRoster(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/session_management'),
        icon: Icon(Icons.qr_code_scanner),
        label: Text('Take Attendance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildClassOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    icon: Icons.business,
                    title: 'Department',
                    value: _classObj!.department,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    icon: Icons.calendar_today,
                    title: 'Semester',
                    value: 'Semester ${_classObj!.semester}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    icon: Icons.people,
                    title: 'Enrolled',
                    value: '${_classObj!.maxStudents} students',
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    icon: Icons.show_chart,
                    title: 'Avg Attendance',
                    value: '${_attendanceStats['averageAttendance'] ?? 0}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    title: 'Average',
                    value: '${_attendanceStats['averageAttendance'] ?? 0}%',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    title: 'Sessions',
                    value: '${_attendanceStats['totalSessions'] ?? 0}',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    title: 'At Risk',
                    value: '${_attendanceStats['atRiskStudents'] ?? 0}',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/class_reports', arguments: widget.classId),
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._recentSessions.map((session) => _buildSessionItem(session)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${session['date'].month}/${session['date'].day}/${session['date'].year}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${session['present']}/${session['total']} present',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getAttendanceColor(session['percentage']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${session['percentage']}%',
              style: TextStyle(
                color: _getAttendanceColor(session['percentage']),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRoster() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Roster',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/students'),
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._students.take(5).map((student) => _buildStudentItem(student)),
            if (_students.length > 5)
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/students'),
                  child: Text('View All Students'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/student_details',
          arguments: student['id'],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Text(
                student['name'].split(' ').map((e) => e[0]).take(2).join(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    student['id'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAttendanceColor(student['attendance']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${student['attendance']}%',
                style: TextStyle(
                  color: _getAttendanceColor(student['attendance']),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  void _shareClassInfo() {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing class information...')),
    );
  }
}
