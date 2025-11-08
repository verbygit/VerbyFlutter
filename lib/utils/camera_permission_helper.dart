import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

class CameraPermissionHelper {


  /// Request only camera permission for face recognition
  static Future<bool> requestCameraPermissionOnly(BuildContext context) async {
    return await requestCameraPermission(context);
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



  
  static void _showPermissionDeniedDialog(BuildContext context, String permissionType) {
    String title;
    String message;
    
    switch (permissionType) {
      case 'Camera':
        title = 'camera_permission_required'.tr();
        message = 'camera_permission_message'.tr();
        break;
      default:
        title = 'permission_required'.tr();
        message = 'permission_required_message'.tr();
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('open_settings'.tr()),
            ),
          ],
        );
      },
    );
  }
}
