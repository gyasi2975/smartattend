import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartattend/models/user_provider.dart';
import 'package:smartattend/models/user_model.dart';
import 'package:smartattend/services/database_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _id = '';
  UserRole? _selectedRole;

  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User? user = await DatabaseHelper.instance.getUserById(_id);

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        if (user.role == UserRole.student) {
          Navigator.pushReplacementNamed(context, '/student_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: User ID not found.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Icon(Icons.work_outline,
                    size: 80, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 16),
                Text(
                  'SmartAttend',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 40),

                // Welcome text
                Text(
                  'University Attendance System',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'Please select your role and sign in',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 32),

                // Role Selection Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedRole = UserRole.student;
                          });
                        },
                        icon: Icon(Icons.school),
                        label: Text('Student'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedRole == UserRole.student
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          foregroundColor: _selectedRole == UserRole.student
                              ? Colors.white
                              : Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedRole = UserRole.lecturer;
                          });
                        },
                        icon: Icon(Icons.person),
                        label: Text('Lecturer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedRole == UserRole.lecturer
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey[300],
                          foregroundColor: _selectedRole == UserRole.lecturer
                              ? Colors.white
                              : Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // User ID Field
                      TextFormField(
                        initialValue: _id,
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your ID';
                          }
                          return null;
                        },
                        onSaved: (value) => _id = value!,
                      ),
                      SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        obscureText: _obscurePassword,
                        initialValue: '',
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                      SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: Text('LOGIN', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Register link
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: Text("Don't have an account? Register here"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
