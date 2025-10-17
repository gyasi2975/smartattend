import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartattend/models/user_provider.dart';
import 'package:smartattend/models/user_model.dart';
import 'package:smartattend/services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;

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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Good morning, Dr. ${_userName ?? 'Lecturer'}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'What would you like to do today?',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),

            // Feature cards
            Expanded(
              child: Column(
                children: [
                  // Take Attendance Card
                  _buildFeatureCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Take Attendance',
                    subtitle: 'Start attendance session for your class',
                    onTap: () => Navigator.pushNamed(context, '/attendance'),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 16),

                  // View Reports Card
                  _buildFeatureCard(
                    icon: Icons.bar_chart,
                    title: 'View Reports',
                    subtitle: 'Check class attendance reports',
                    onTap: () => Navigator.pushNamed(context, '/records'),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(height: 16),

                  // Settings Card
                  _buildFeatureCard(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Manage your account',
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function onTap,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        onTap: () => onTap(),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
