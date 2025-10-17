import 'package:flutter/material.dart';

class StudentsScreen extends StatefulWidget {
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterBy = 'all'; // all, at_risk, good, excellent
  String _sortBy = 'name'; // name, attendance, id

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      // final userProvider = Provider.of<UserProvider>(context, listen: false);
      // final lecturerId = userProvider.userId;
      final lecturerId = 'LECTURER001'; // Placeholder

      if (lecturerId.isNotEmpty) {
        // Get all students from lecturer's classes
        // final classes = await DatabaseHelper.instance.getClassesByLecturer(lecturerId);
        // Set<String> studentIds = {};

        // for (var classObj in classes) {
        //   // In real app, get enrolled students for each class
        //   // For now, using placeholder data
        // }

        // Placeholder student data
        _students = [
          {
            'id': 'STU001',
            'name': 'Alice Johnson',
            'email': 'alice.johnson@university.edu',
            'course': 'Computer Science',
            'year': '3rd Year',
            'attendancePercentage': 95.5,
            'status': 'excellent',
            'photo': null,
          },
          {
            'id': 'STU002',
            'name': 'Bob Smith',
            'email': 'bob.smith@university.edu',
            'course': 'Computer Science',
            'year': '2nd Year',
            'attendancePercentage': 78.3,
            'status': 'good',
            'photo': null,
          },
          {
            'id': 'STU003',
            'name': 'Carol Davis',
            'email': 'carol.davis@university.edu',
            'course': 'Information Technology',
            'year': '3rd Year',
            'attendancePercentage': 65.2,
            'status': 'at_risk',
            'photo': null,
          },
        ];

        setState(() {
          _filteredStudents = _students;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading students: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
      _filteredStudents = _students.where((student) {
        final matchesQuery = query.isEmpty ||
          student['name'].toLowerCase().contains(query.toLowerCase()) ||
          student['id'].toLowerCase().contains(query.toLowerCase()) ||
          student['email'].toLowerCase().contains(query.toLowerCase());

        final matchesFilter = _filterBy == 'all' || student['status'] == _filterBy;

        return matchesQuery && matchesFilter;
      }).toList();

      _sortStudents();
    });
  }

  void _sortStudents() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _filteredStudents.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case 'attendance':
          _filteredStudents.sort((a, b) => b['attendancePercentage'].compareTo(a['attendancePercentage']));
          break;
        case 'id':
          _filteredStudents.sort((a, b) => a['id'].compareTo(b['id']));
          break;
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'at_risk':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'at_risk':
        return 'At Risk';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () => Navigator.pushNamed(context, '/bulk_message'),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportStudents(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Bar
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: _filterStudents,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _filterBy,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(value: 'all', child: Text('All Students')),
                                DropdownMenuItem(value: 'excellent', child: Text('Excellent (≥90%)')),
                                DropdownMenuItem(value: 'good', child: Text('Good (70-89%)')),
                                DropdownMenuItem(value: 'at_risk', child: Text('At Risk (<70%)')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _filterBy = value;
                                    _filterStudents(_searchQuery);
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Sort: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _sortBy,
                            items: [
                              DropdownMenuItem(value: 'name', child: Text('Name')),
                              DropdownMenuItem(value: 'attendance', child: Text('Attendance')),
                              DropdownMenuItem(value: 'id', child: Text('ID')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                  _sortStudents();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Students List
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            return _buildStudentCard(_filteredStudents[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/student_details',
          arguments: student['id'],
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Student Photo
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: student['photo'] != null
                    ? ClipOval(child: Image.network(student['photo'], fit: BoxFit.cover))
                    : Text(
                        student['name'].split(' ').map((e) => e[0]).take(2).join(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
              ),
              SizedBox(width: 16),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      student['id'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${student['course']} - ${student['year']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.show_chart, size: 16, color: _getStatusColor(student['status'])),
                        SizedBox(width: 4),
                        Text(
                          '${student['attendancePercentage']}%',
                          style: TextStyle(
                            color: _getStatusColor(student['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(student['status']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(student['status']),
                            style: TextStyle(
                              color: _getStatusColor(student['status']),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () => _sendMessage(student),
                    icon: Icon(Icons.message, size: 20),
                    tooltip: 'Send Message',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/student_history',
                      arguments: student['id'],
                    ),
                    icon: Icon(Icons.history, size: 20),
                    tooltip: 'View History',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No students found' : 'No students match your search',
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

  void _sendMessage(Map<String, dynamic> student) {
    // Navigate to message screen or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message to ${student['name']}'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Type your message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Send message logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${student['name']}')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _exportStudents() {
    // Export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting student list...')),
    );
  }
}
