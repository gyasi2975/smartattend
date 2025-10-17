import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartattend/models/user_provider.dart';
import 'package:smartattend/models/user_model.dart';
import 'package:smartattend/services/database_helper.dart';
import 'package:intl/intl.dart';

class EnhancedHomeScreen extends StatefulWidget {
  @override
  _EnhancedHomeScreenState createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  String? _userName;
  List<Map<String, dynamic>> _todayClasses = [];
  Map<String, dynamic> _quickStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    String? userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      User? user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        setState(() {
          _userName = user.name;
        });
        await _loadDashboardData(userId);
      }
    }
  }

  Future<void> _loadDashboardData(String lecturerId) async {
    try {
      // Load today's classes
      final classes = await DatabaseHelper.instance.getClassesByLecturer(lecturerId);
      // final today = DateTime.now().weekday - 1; // Convert to enum index (0-6)

      // Filter classes for today (simplified - in real app, check schedules)
      _todayClasses = classes.map((classObj) => {
        'id': classObj.id,
        'name': classObj.courseName,
        'code': classObj.courseCode,
        'time': '9:00 AM - 10:30 AM', // Placeholder
        'venue': 'Room 101', // Placeholder
        'totalStudents': classObj.maxStudents,
        'presentCount': 0, // Would calculate from recent sessions
        'attendancePercentage': 0.0, // Would calculate from recent sessions
      }).toList();

      // Load quick statistics
      _quickStats = {
        'totalClassesToday': _todayClasses.length,
        'totalStudents': _todayClasses.fold(0, (sum, classObj) => sum + (classObj['totalStudents'] as int)),
        'overallAttendance': 85.5, // Placeholder - would calculate from recent data
        'pendingSessions': 2, // Placeholder
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                String? userId = Provider.of<UserProvider>(context, listen: false).userId;
                if (userId != null) {
                  await _loadDashboardData(userId);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message and current date/time
                      Text(
                        'Good ${DateFormat('a').format(DateTime.now()) == 'AM' ? 'morning' : 'afternoon'}, Dr. ${_userName ?? 'Lecturer'}!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      SizedBox(height: 24),

                      // Quick Statistics Cards
                      _buildQuickStats(),
                      SizedBox(height: 24),

                      // Today's Classes Section
                      Text(
                        'Today\'s Classes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _todayClasses.isEmpty
                          ? _buildEmptyState('No classes scheduled for today')
                          : Column(
                              children: _todayClasses.map((classObj) => _buildClassCard(classObj)).toList(),
                            ),

                      SizedBox(height: 24),

                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.class_,
            title: 'Classes Today',
            value: '${_quickStats['totalClassesToday'] ?? 0}',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'Total Students',
            value: '${_quickStats['totalStudents'] ?? 0}',
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classObj) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classObj['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        classObj['code'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${classObj['attendancePercentage'] ?? 0}%',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  classObj['time'] ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  classObj['venue'] ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${classObj['presentCount'] ?? 0}/${classObj['totalStudents'] ?? 0} students',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/session_management'),
                      icon: Icon(Icons.qr_code, size: 16),
                      label: Text('Take Attendance'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/class_details', arguments: classObj['id']),
                      icon: Icon(Icons.info_outline),
                      tooltip: 'View Details',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionCard(
          icon: Icons.qr_code_scanner,
          title: 'Take Attendance',
          subtitle: 'Start session',
          onTap: () => Navigator.pushNamed(context, '/session_management'),
          color: Theme.of(context).colorScheme.primary,
        ),
        _buildActionCard(
          icon: Icons.bar_chart,
          title: 'View Reports',
          subtitle: 'Analytics',
          onTap: () => Navigator.pushNamed(context, '/records'),
          color: Theme.of(context).colorScheme.secondary,
        ),
        _buildActionCard(
          icon: Icons.class_,
          title: 'My Classes',
          subtitle: 'Manage subjects',
          onTap: () => Navigator.pushNamed(context, '/my_classes'),
          color: Colors.orange,
        ),
        _buildActionCard(
          icon: Icons.people,
          title: 'Students',
          subtitle: 'View roster',
          onTap: () => Navigator.pushNamed(context, '/students'),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function onTap,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
