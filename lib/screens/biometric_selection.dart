import 'package:flutter/material.dart';
import 'package:smartattend/services/biometric_service.dart';

class BiometricSelectionScreen extends StatefulWidget {
  @override
  _BiometricSelectionScreenState createState() => _BiometricSelectionScreenState();
}

class _BiometricSelectionScreenState extends State<BiometricSelectionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAvailableMethods();
  }

  Future<void> _checkAvailableMethods() async {
    // This could be used to disable unavailable methods
    List<BiometricMethod> availableMethods = await BiometricService.getAvailableMethods();
    print('Available biometric methods: $availableMethods');
  }

  void _selectMethod(BiometricMethod method) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Navigate to attendance screen with selected method
      Navigator.pushNamed(
        context,
        '/attendance',
        arguments: {'selectedMethod': method},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting method: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Authentication Method'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing authentication...'),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Choose Authentication Method',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select your preferred biometric method to mark attendance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),

                  // Face Recognition Card
                  _buildMethodCard(
                    icon: Icons.face,
                    title: 'Face Recognition',
                    subtitle: 'Use facial recognition to authenticate',
                    color: Colors.blue,
                    onTap: () => _selectMethod(BiometricMethod.face),
                  ),
                  SizedBox(height: 24),

                  // Fingerprint Card
                  _buildMethodCard(
                    icon: Icons.fingerprint,
                    title: 'Fingerprint',
                    subtitle: 'Use fingerprint sensor to authenticate',
                    color: Colors.green,
                    onTap: () => _selectMethod(BiometricMethod.fingerprint),
                  ),
                  SizedBox(height: 48),

                  // Alternative option
                  TextButton(
                    onPressed: () => _selectMethod(BiometricMethod.deviceCredentials),
                    child: Text(
                      'Use Device Credentials Instead',
                      style: TextStyle(
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
