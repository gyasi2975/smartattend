import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smartattend/models/user_provider.dart';
import 'package:smartattend/models/user_model.dart';
import 'package:smartattend/models/class_model.dart';
import 'package:smartattend/models/schedule_model.dart';
import 'package:smartattend/services/database_helper.dart';
import 'package:smartattend/widgets/custom_button.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  List<Class> _todayClasses = [];
  List<ClassSchedule> _weeklySchedule = [];
  Map<String, int> _attendanceStats = {};

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId != null) {
      // Load today's classes
      _todayClasses = await DatabaseHelper.instance.getTodayClassesForStudent(userId);

      // Load weekly schedule
      _weeklySchedule = await DatabaseHelper.instance.getStudentSchedule(userId);

      // Load attendance statistics
      _attendanceStats = await DatabaseHelper.instance.getStudentAttendanceStats(userId);

      // Load attendance data for calendar
      // _attendanceData = await DatabaseHelper.instance.getStudentAttendanceCalendar(userId);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(user),

            SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),

            SizedBox(height: 20),

            // Attendance Statistics
            _buildAttendanceStats(),

            SizedBox(height: 20),

            // Today's Classes
            _buildTodayClasses(),

            SizedBox(height: 20),

            // Calendar View
            _buildCalendarView(),

            SizedBox(height: 20),

            // Weekly Schedule
            _buildWeeklySchedule(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/biometric_selection'),
        child: Icon(Icons.fingerprint),
        tooltip: 'Mark Attendance',
      ),
    );
  }

  Widget _buildWelcomeSection(User? user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user?.profilePicturePath != null
                  ? NetworkImage(user!.profilePicturePath!)
                  : null,
              child: user?.profilePicturePath == null
                  ? Icon(Icons.person, size: 30)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.name ?? 'Student'}!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.department ?? 'Department',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Mark Attendance',
                icon: Icons.check_circle,
                onPressed: () => Navigator.pushNamed(context, '/biometric_selection'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'View Records',
                icon: Icons.history,
                onPressed: () => Navigator.pushNamed(context, '/records'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceStats() {
    int totalClasses = _attendanceStats['total'] ?? 0;
    int presentClasses = _attendanceStats['present'] ?? 0;
    double attendancePercentage = totalClasses > 0 ? (presentClasses / totalClasses) * 100 : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Classes', totalClasses.toString()),
                _buildStatItem('Present', presentClasses.toString()),
                _buildStatItem('Percentage', '${attendancePercentage.toStringAsFixed(1)}%'),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: attendancePercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                attendancePercentage >= 75 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTodayClasses() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Classes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _todayClasses.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No classes scheduled for today'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _todayClasses.length,
                    itemBuilder: (context, index) {
                      final classItem = _todayClasses[index];
                      return ListTile(
                        leading: Icon(Icons.class_, color: Theme.of(context).primaryColor),
                        title: Text(classItem.courseName),
                        subtitle: Text('Course: ${classItem.courseCode}'),
                        trailing: Text(classItem.department),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _weeklySchedule.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No schedule available'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _weeklySchedule.length,
                    itemBuilder: (context, index) {
                      final schedule = _weeklySchedule[index];
                      return ListTile(
                        leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                        title: Text(schedule.dayOfWeek.toString().split('.').last.toUpperCase()),
                        subtitle: Text('${schedule.timeString} - Room ${schedule.room}'),
                        trailing: Text(schedule.locationId),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
