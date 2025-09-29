import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CameraPermissionHelper {
  /// Request both camera and microphone permissions for face recognition
  static Future<bool> requestCameraAndAudioPermissions(BuildContext context) async {
    // Request camera permission first
    final cameraGranted = await requestCameraPermission(context);
    if (!cameraGranted) {
      return false;
    }

    // Request microphone permission for camera recording
    final audioGranted = await requestAudioPermission(context);
    if (!audioGranted) {
      return false;
    }

    return true;
  }

  static Future<bool> requestCameraPermission(BuildContext context) async {
    // Check current permission status
    var status = await Permission.camera.status;
    print("camera permission status=====> $status");
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
      print("camera permission status= request====> $status");

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showPermissionDeniedDialog(context, 'Camera');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(context, 'Camera');
      return false;
    }
    
    return false;
  }

  /// Request microphone permission for camera recording
  static Future<bool> requestAudioPermission(BuildContext context) async {
    // Check current permission status
    var status = await Permission.microphone.status;
    print("microphone permission status=====> $status");
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // Request permission
      status = await Permission.microphone.request();
      print("microphone permission status= request====> $status");

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showPermissionDeniedDialog(context, 'Microphone');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(context, 'Microphone');
      return false;
    }
    
    return false;
  }
  
  static Future<bool> checkCameraPermission() async {
    var status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if both camera and microphone permissions are granted
  static Future<bool> checkCameraAndAudioPermissions() async {
    final cameraGranted = await Permission.camera.status.isGranted;
    final audioGranted = await Permission.microphone.status.isGranted;
    return cameraGranted && audioGranted;
  }

  /// Check microphone permission status
  static Future<bool> checkAudioPermission() async {
    var status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  static void _showPermissionDeniedDialog(BuildContext context, String permissionType) {
    String title;
    String message;
    
    switch (permissionType) {
      case 'Camera':
        title = 'Camera Permission Required';
        message = 'Camera access is required for face recognition. Please enable camera permission in app settings.';
        break;
      case 'Microphone':
        title = 'Microphone Permission Required';
        message = 'Microphone access is required for camera recording during face recognition. Please enable microphone permission in app settings.';
        break;
      default:
        title = 'Permission Required';
        message = 'This permission is required for the app to function properly. Please enable it in app settings.';
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
