import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartattend/models/user_provider.dart'; // Import UserProvider
import 'package:smartattend/services/notification_service.dart'; // Import NotificationService
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/attendance.dart';
import 'screens/settings.dart';
import 'screens/records.dart';
import 'screens/location_check_screen.dart';
import 'screens/biometric_selection.dart';
import 'screens/student_dashboard.dart';
import 'screens/my_classes_screen.dart';
import 'screens/class_details_screen.dart';
import 'screens/students_screen.dart';
import 'screens/session_management_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database; // Initialize database
  await NotificationService.initialize(); // This should now work

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartAttend',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.green,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/attendance': (context) => AttendanceScreen(),
        '/settings': (context) => SettingsScreen(),
        '/records': (context) => RecordsScreen(),
        '/location_check': (context) => LocationCheckScreen(),
        '/biometric_selection': (context) => BiometricSelectionScreen(),
        '/student_dashboard': (context) => StudentDashboard(),
        '/my_classes': (context) => MyClassesScreen(),
        '/class_details': (context) => ClassDetailsScreen(classId: ModalRoute.of(context)!.settings.arguments as String),
        '/students': (context) => StudentsScreen(),
        '/session_management': (context) => SessionManagementScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
