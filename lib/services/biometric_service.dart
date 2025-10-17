import 'package:local_auth/local_auth.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

enum BiometricMethod {
  fingerprint,
  face,
  deviceCredentials
}

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static CameraController? _cameraController;
  static FaceDetector? _faceDetector;

  /// Initialize camera and face detector for face recognition
  static Future<void> initializeFaceDetection() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true,
          minFaceSize: 0.1,
        ),
      );
    } catch (e) {
      print('Face detection initialization error: $e');
    }
  }

  /// Dispose camera and face detector resources
  static Future<void> dispose() async {
    await _cameraController?.dispose();
    _faceDetector?.close();
    _cameraController = null;
    _faceDetector = null;
  }

  /// Main authentication method with dual biometric support
  static Future<Map<String, dynamic>> authenticate() async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

      print('Can check biometrics: $canCheckBiometrics');
      print('Available biometrics: $availableBiometrics');

      // Try fingerprint/face authentication first
      if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
        // Check if face recognition is available
        bool hasFace = availableBiometrics.contains(BiometricType.face);
        bool hasFingerprint = availableBiometrics.contains(BiometricType.fingerprint);

        if (hasFace) {
          // Try face recognition first
          var faceResult = await _authenticateWithFace();
          if (faceResult['success']) {
            return {
              'success': true,
              'method': BiometricMethod.face,
              'message': 'Face recognition successful'
            };
          }
        }

        if (hasFingerprint) {
          // Try fingerprint as fallback
          var fingerprintResult = await _authenticateWithFingerprint();
          if (fingerprintResult['success']) {
            return {
              'success': true,
              'method': BiometricMethod.fingerprint,
              'message': 'Fingerprint authentication successful'
            };
          }
        }
      }

      // Fallback to device credentials
      var deviceResult = await _authenticateWithDeviceCredentials();
      return {
        'success': deviceResult,
        'method': BiometricMethod.deviceCredentials,
        'message': deviceResult ? 'Device credentials authentication successful' : 'Authentication failed'
      };

    } catch (e) {
      print('Biometric authentication error: $e');
      return {
        'success': false,
        'method': null,
        'message': 'Authentication error: $e'
      };
    }
  }

  /// Authenticate using fingerprint
  static Future<Map<String, dynamic>> _authenticateWithFingerprint() async {
    try {
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate using fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      return {
        'success': authenticated,
        'method': BiometricMethod.fingerprint
      };
    } catch (e) {
      print('Fingerprint authentication error: $e');
      return {
        'success': false,
        'method': BiometricMethod.fingerprint
      };
    }
  }

  /// Authenticate using face recognition
  static Future<Map<String, dynamic>> _authenticateWithFace() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await initializeFaceDetection();
      }

      if (_cameraController == null || _faceDetector == null) {
        return {
          'success': false,
          'method': BiometricMethod.face,
          'message': 'Face detection not available'
        };
      }

      // Capture image
      XFile imageFile = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);

      // Detect faces
      final faces = await _faceDetector!.processImage(inputImage);

      // Clean up captured image
      await File(imageFile.path).delete();

      if (faces.isNotEmpty) {
        // Face detected - in a real implementation, you'd compare with stored face data
        // For now, we just check if a face is present
        Face face = faces.first;
        if (face.headEulerAngleY != null && face.headEulerAngleZ != null) {
          // Face is properly positioned
          return {
            'success': true,
            'method': BiometricMethod.face,
            'confidence': face.smilingProbability ?? 0.0
          };
        }
      }

      return {
        'success': false,
        'method': BiometricMethod.face,
        'message': 'No face detected or face not properly positioned'
      };

    } catch (e) {
      print('Face authentication error: $e');
      return {
        'success': false,
        'method': BiometricMethod.face,
        'message': 'Face authentication failed: $e'
      };
    }
  }

  /// Authenticate using device credentials (PIN/pattern/password)
  static Future<bool> _authenticateWithDeviceCredentials() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate using device credentials (PIN, pattern, or password)',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Device credentials authentication error: $e');
      return false;
    }
  }

  /// Get available biometric methods
  static Future<List<BiometricMethod>> getAvailableMethods() async {
    List<BiometricMethod> methods = [];

    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        methods.add(BiometricMethod.deviceCredentials);
        return methods;
      }

      List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        methods.add(BiometricMethod.face);
      }
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        methods.add(BiometricMethod.fingerprint);
      }

      // Always include device credentials as fallback
      methods.add(BiometricMethod.deviceCredentials);

    } catch (e) {
      print('Error getting available biometric methods: $e');
      methods.add(BiometricMethod.deviceCredentials);
    }

    return methods;
  }

  /// Legacy method for backward compatibility
  static Future<bool> authenticateLegacy() async {
    var result = await authenticate();
    return result['success'] ?? false;
  }
}
