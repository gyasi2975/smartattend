import 'package:flutter/material.dart';
import 'package:smartattend/services/database_helper.dart';
import 'package:smartattend/models/class_model.dart';

class MyClassesScreen extends StatefulWidget {
  @override
  _MyClassesScreenState createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  List<Class> _classes = [];
  List<Class> _filteredClasses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'name'; // name, attendance, students

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      // final userProvider = Provider.of<UserProvider>(context, listen: false);
      // final lecturerId = userProvider.userId;
      final lecturerId = 'LECTURER001'; // Placeholder

      if (lecturerId.isNotEmpty) {
        final classes = await DatabaseHelper.instance.getClassesByLecturer(lecturerId);
        setState(() {
          _classes = classes;
          _filteredClasses = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading classes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterClasses(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredClasses = _classes;
      } else {
        _filteredClasses = _classes.where((classObj) =>
          classObj.courseName.toLowerCase().contains(query.toLowerCase()) ||
          classObj.courseCode.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      _sortClasses();
    });
  }

  void _sortClasses() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _filteredClasses.sort((a, b) => a.courseName.compareTo(b.courseName));
          break;
        case 'attendance':
          // In real app, sort by attendance percentage
          _filteredClasses.sort((a, b) => a.courseName.compareTo(b.courseName));
          break;
        case 'students':
          _filteredClasses.sort((a, b) => b.maxStudents.compareTo(a.maxStudents));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Classes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add_class'),
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
                          hintText: 'Search classes...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: _filterClasses,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(value: 'name', child: Text('Name')),
                                DropdownMenuItem(value: 'attendance', child: Text('Attendance %')),
                                DropdownMenuItem(value: 'students', child: Text('Student Count')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _sortBy = value;
                                    _sortClasses();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Classes List
                Expanded(
                  child: _filteredClasses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredClasses.length,
                          itemBuilder: (context, index) {
                            return _buildClassCard(_filteredClasses[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildClassCard(Class classObj) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/class_details',
          arguments: classObj.id,
        ),
        borderRadius: BorderRadius.circular(12),
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
                          classObj.courseName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          classObj.courseCode,
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
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${classObj.maxStudents} students',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    classObj.department,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Semester ${classObj.semester}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.show_chart, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        '85% avg attendance', // Placeholder
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/session_management'),
                        icon: Icon(Icons.qr_code_scanner, size: 20),
                        tooltip: 'Take Attendance',
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/class_reports', arguments: classObj.id),
                        icon: Icon(Icons.bar_chart, size: 20),
                        tooltip: 'View Reports',
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/edit_class', arguments: classObj.id),
                        icon: Icon(Icons.edit, size: 20),
                        tooltip: 'Edit Class',
                      ),
                    ],
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
              Icons.class_,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No classes found' : 'No classes match your search',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (_searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/add_class'),
                icon: Icon(Icons.add),
                label: Text('Add Your First Class'),
              ),
          ],
        ),
      ),
    );
  }
}
