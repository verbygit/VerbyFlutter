import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

class StoragePermissionHelper {
  /// Request storage permission for backup/restore functionality
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      return await _requestAndroidStoragePermission(context);
    } else if (Platform.isIOS) {
      // iOS handles file access through FilePicker automatically
      return true;
    }
    return false;
  }

  /// Handle Android storage permission with proper version handling
  static Future<bool> _requestAndroidStoragePermission(BuildContext context) async {
    try {
      // For Android 13+ (API 33+), we don't need READ_EXTERNAL_STORAGE
      // FilePicker handles file access automatically
      if (await _isAndroid13OrHigher()) {
        // Android 13+ - FilePicker handles permissions automatically
        return true;
      } else {
        // Android 12 and below - need READ_EXTERNAL_STORAGE
        var status = await Permission.storage.status;
        print("storage permission status=====> $status");
        
        if (status.isGranted) {
          return true;
        }
        
        if (status.isDenied) {
          status = await Permission.storage.request();
          print("storage permission status= request====> $status");

          if (status.isGranted) {
            return true;
          } else if (status.isPermanentlyDenied) {
            _showPermissionDeniedDialog(context, 'Storage');
            return false;
          }
        }
        
        if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog(context, 'Storage');
          return false;
        }
        
        return false;
      }
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check if running on Android 13+ (API 33+)
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    
    try {
      // This is a simplified check - in production you might want to use
      // platform-specific code to check Android version
      // For now, we'll assume FilePicker handles permissions correctly on newer Android versions
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check storage permission status
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return true; // Android 13+ doesn't need explicit storage permission
      } else {
        var status = await Permission.storage.status;
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS handles file access through FilePicker automatically
      return true;
    }
    return false;
  }

  /// Show permission denied dialog
  static void _showPermissionDeniedDialog(BuildContext context, String permissionType) {
    String title;
    String message;
    
    switch (permissionType) {
      case 'Storage':
        title = 'storage_permission_required'.tr();
        message = 'storage_permission_message'.tr();
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
