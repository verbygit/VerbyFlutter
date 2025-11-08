import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ICloudDocumentsService {
  static const MethodChannel _channel = MethodChannel('icloud_documents');

  /// Save data to iCloud Documents
  static Future<bool> saveToICloud(Uint8List data) async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('saveToICloud', {
        'data': data,
      });
      return result['success'] == true;
    } catch (e) {
      print('Error saving to iCloud: $e');
      return false;
    }
  }

  /// Load data from iCloud Documents
  static Future<Uint8List?> loadFromICloud() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('loadFromICloud');
      if (result['success'] == true && result['data'] != null) {
        return result['data'];
      }
      return null;
    } catch (e) {
      print('Error loading from iCloud: $e');
      return null;
    }
  }

  /// Check if iCloud is available
  static Future<bool> isICloudAvailable() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('isICloudAvailable');
      return result['available'] == true;
    } catch (e) {
      print('Error checking iCloud availability: $e');
      return false;
    }
  }

  /// Get iCloud file URL (for debugging)
  static Future<String?> getICloudFileURL() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getICloudFileURL');
      return result['url'];
    } catch (e) {
      print('Error getting iCloud file URL: $e');
      return null;
    }
  }

  /// Check if iCloud file exists
  static Future<bool> checkICloudFileExists() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('checkICloudFileExists');
      return result['exists'] == true;
    } catch (e) {
      print('Error checking iCloud file existence: $e');
      return false;
    }
  }

  /// Check iCloud sync status (for debugging)
  static Future<Map<String, dynamic>?> checkICloudSyncStatus() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('checkICloudSyncStatus');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error checking iCloud sync status: $e');
      return null;
    }
  }

  /// Get iCloud account info (for debugging)
  static Future<Map<String, dynamic>?> getICloudAccountInfo() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getICloudAccountInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting iCloud account info: $e');
      return null;
    }
  }

  static Future<bool> deleteICloudFile() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('deleteICloudFile');
      return result['success'] == true;
    } catch (e) {
      print('Error deleting iCloud file: $e');
      return false;
    }
  }
}
