import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _id = '';
  String _name = '';
  String _email = '';
  String _department = '';
  UserRole _selectedRole = UserRole.student;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if user already exists
      final existingUser = await DatabaseHelper.instance.getUserByEmail(_email);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User with this email already exists')),
        );
        return;
      }

      User newUser = User(
        id: _id,
        name: _name,
        email: _email,
        department: _department,
        role: _selectedRole,
      );

      await DatabaseHelper.instance.insertUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful! Please login.')),
      );

      Navigator.pop(context); // Go back to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an ID';
                    }
                    return null;
                  },
                  onSaved: (value) => _id = value!,
                ),
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                TextFormField(
                  initialValue: _department,
                  decoration: InputDecoration(labelText: 'Department'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your department';
                    }
                    return null;
                  },
                  onSaved: (value) => _department = value!,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role == UserRole.student ? 'Student' : 'Lecturer'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
