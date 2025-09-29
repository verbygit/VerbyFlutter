import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/utils/storage_permission_helper.dart';

class BackupService {
  static const String _backupPassword =
      'your_secure_password_123'; // Make dynamic
  static const String _backupFileName = 'records_backup.zip';
  static const int _keyLength = 32; // AES-256
  static const int _ivLength = 16; // AES IV
  static const int _iterations = 10000; // PBKDF2 iterations

  // Main function to save records to DB and external file
  Future<bool> saveRecordsWithBackup(List<CreateRecordRequest> records) async {
    try {
      final recordMap = records.map((record) => record.toJson()).toList();

      // Create simple ZIP backup (no encryption for testing)
      final zipData = await _createSimpleZip(recordMap);

      // Save to platform-specific location
      if (Platform.isAndroid) {
        return await _saveToAndroid(zipData);
      } else if (Platform.isIOS) {
        return await _saveToIOS(zipData);
      } else {
        print('Unsupported platform');
        return false;
      }
    } catch (e) {
      print('Error in saveRecordsWithBackup: $e');
      return false;
    }
  }

  // Create simple ZIP file (no encryption for testing)
  Future<Uint8List> _createSimpleZip(List<Map<String, dynamic>> records) async {
    // Convert records to JSON string
    final jsonString = jsonEncode(records);

    // Write JSON data to temp file
    final tempDir = await getTemporaryDirectory();
    final jsonFilePath = path.join(tempDir.path, 'records.json');
    final jsonFile = File(jsonFilePath);
    await jsonFile.writeAsString(jsonString);

    // Create ZIP file in temp directory
    final zipFilePath = path.join(tempDir.path, _backupFileName);
    final zipFile = File(zipFilePath);
    await ZipFile.createFromFiles(
      sourceDir: tempDir,
      files: [jsonFile],
      zipFile: zipFile,
    );

    // Read ZIP file as bytes
    final zipBytes = await zipFile.readAsBytes();

    // Clean up temp files
    if (await jsonFile.exists()) {
      await jsonFile.delete();
    }
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    return zipBytes;
  }

  // Create encrypted file, then ZIP it (commented out for testing)
  Future<Uint8List> _createEncryptedZip(
    List<Map<String, dynamic>> records,
  ) async {
    // Encrypt JSON data
    final encryptedBytes = await _encryptData(records);

    // Write encrypted data to temp file
    final tempDir = await getTemporaryDirectory();
    final encryptedFilePath = path.join(tempDir.path, 'encrypted_records.bin');
    final encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsBytes(encryptedBytes);

    // Create ZIP file in temp directory
    final zipFilePath = path.join(tempDir.path, _backupFileName);
    final zipFile = File(zipFilePath);
    await ZipFile.createFromFiles(
      sourceDir: tempDir,
      files: [encryptedFile],
      zipFile: zipFile,
    );

    // Read ZIP file as bytes
    final zipBytes = await zipFile.readAsBytes();

    // Clean up temp files
    if (await encryptedFile.exists()) {
      await encryptedFile.delete();
    }
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    return zipBytes;
  }

  // Encrypt records with AES-256-CBC using PBKDF2-derived key
  Future<Uint8List> _encryptData(List<Map<String, dynamic>> records) async {
    final jsonString = jsonEncode(records);
    final jsonBytes = utf8.encode(jsonString);

    // Derive key and IV
    final key = await _deriveKey(_backupPassword);
    final iv = IV.fromSecureRandom(_ivLength); // Random IV for security

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encryptBytes(jsonBytes, iv: iv);

    // Prepend IV to encrypted data for decryption
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  // PBKDF2 key derivation using PointyCastle
  Future<Key> _deriveKey(String password) async {
    final salt = utf8.encode('salt_for_key'); // Use random salt in production
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _iterations, _keyLength));
    final keyBytes = pbkdf2.process(utf8.encode(password));
    return Key(keyBytes);
  }

  // Android: Save to Downloads directory
  Future<bool> _saveToAndroid(Uint8List zipData) async {
    try {
      // Check storage permission using the helper
      if (!await StoragePermissionHelper.checkStoragePermission()) {
        print('Storage permission not available');
        return false;
      }

      // Get Downloads directory
      final downloadsDir = Directory('/storage/emulated/0/Documents');
      final filePath = path.join(downloadsDir.path, _backupFileName);

      // Overwrite existing file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Write new file
      await file.writeAsBytes(zipData);
      print('Backup saved to $filePath');
      return true;
    } catch (e) {
      print('Error saving to Android: $e');
      return false;
    }
  }

  // iOS: Save using UIDocumentPicker via file_picker
  Future<bool> _saveToIOS(Uint8List zipData) async {
    try {
      // Use file_picker to let user choose save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: _backupFileName,
        bytes: zipData,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        print('Backup saved to $result');
        return true;
      } else {
        print('User cancelled file picker');
        return false;
      }
    } catch (e) {
      print('Error saving to iOS: $e');
      return false;
    }
  }

  // Upload/Import functionality
  Future<List<CreateRecordRequest>?> uploadAndExtractRecords() async {
    try {
      // Pick ZIP file based on platform
      String? filePath;
      if (Platform.isAndroid) {
        filePath = await _pickFileFromAndroid();
      } else if (Platform.isIOS) {
        filePath = await _pickFileFromIOS();
      } else {
        print('Unsupported platform');
        return null;
      }

      if (filePath == null) {
        print('No file selected');
        return null;
      }

      // Extract and parse records from ZIP
      return await _extractRecordsFromZip(filePath);
    } catch (e) {
      print('Error in uploadAndExtractRecords: $e');
      return null;
    }
  }

  // Android: Pick ZIP file from Documents external directory
  Future<String?> _pickFileFromAndroid() async {
    try {
      // Check storage permission using the helper
      if (!await StoragePermissionHelper.checkStoragePermission()) {
        print('Storage permission not available');
        return null;
      }

      // Use file_picker to select from Documents directory
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Verify it's a ZIP file
          if (file.extension?.toLowerCase() == 'zip') {
            print('Android: File selected, cached at: ${file.path}');

            // Check if it's our expected backup file
            if (file.name == _backupFileName) {
              print(
                'Confirmed: This is our backup file, original will be deleted after processing',
              );
            } else {
              print(
                'Note: Different filename detected, original file deletion may not work',
              );
            }

            return file.path;
          } else {
            print('Selected file is not a ZIP file');
            return null;
          }
        }
      }

      print('No file selected');
      return null;
    } catch (e) {
      print('Error picking file from Android: $e');
      return null;
    }
  }

  // iOS: Pick ZIP file from Downloads folder
  Future<String?> _pickFileFromIOS() async {
    try {
      // Use file_picker to select ZIP file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Verify it's a ZIP file
          if (file.extension?.toLowerCase() == 'zip') {
            print(
              'iOS: File selected from Files app, copied to temp location: ${file.path}',
            );
            print(
              'Note: Original file in Files app will remain (iOS limitation)',
            );
            return file.path;
          } else {
            print('Selected file is not a ZIP file');
            return null;
          }
        }
      }

      print('No file selected');
      return null;
    } catch (e) {
      print('Error picking file from iOS: $e');
      return null;
    }
  }

  // Extract records from ZIP file
  Future<List<CreateRecordRequest>?> _extractRecordsFromZip(
    String zipFilePath,
  ) async {
    try {
      final zipFile = File(zipFilePath);
      if (!await zipFile.exists()) {
        print('ZIP file does not exist: $zipFilePath');
        return null;
      }

      // Create temp directory for extraction
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(
        path.join(
          tempDir.path,
          'extracted_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      if (!await extractDir.exists()) {
        await extractDir.create(recursive: true);
      }

      // Extract ZIP file
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: extractDir,
      );

      // Look for JSON file in extracted contents
      final jsonFile = await _findJsonFile(extractDir);
      if (jsonFile == null) {
        print('No JSON file found in ZIP archive');
        // Clean up temp directory on error
        await extractDir.delete(recursive: true);
        return null;
      }

      // Read and parse JSON
      final jsonString = await jsonFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert to CreateRecordRequest objects
      final List<CreateRecordRequest> records = jsonList
          .map((json) => CreateRecordRequest.fromJson(json))
          .toList();

      // Clean up temp directory
      await extractDir.delete(recursive: true);

      // Delete the temporary ZIP file after successful extraction
      try {
        await zipFile.delete();
        print('Temporary ZIP file deleted successfully: $zipFilePath');

        // On Android, also try to delete the original file from Documents directory
        // if (Platform.isAndroid) {
        //   await _deleteOriginalAndroidFile();
        // }
        //
        // On iOS, explain that original file in Files app remains
        if (Platform.isIOS) {
          print(
            'Note: Original file in Files app/iCloud remains untouched (iOS security limitation)',
          );
          print(
            'Users can manually delete the original file from Files app if desired',
          );
        }
      } catch (deleteError) {
        print('Warning: Could not delete temporary ZIP file: $deleteError');
        print('File path: $zipFilePath');

        // On iOS, this might happen due to sandbox restrictions
        if (Platform.isIOS) {
          print('Note: iOS may restrict file deletion in certain directories');
        }

        // Don't fail the operation if file deletion fails
      }

      print('Successfully extracted ${records.length} records from ZIP file');
      return records;
    } catch (e) {
      print('Error extracting records from ZIP: $e');
      return null;
    }
  }

  // Find JSON file in extracted directory
  Future<File?> _findJsonFile(Directory directory) async {
    try {
      final files = directory
          .listSync(recursive: true)
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      if (files.isNotEmpty) {
        return files.first; // Return the first JSON file found
      }
      return null;
    } catch (e) {
      print('Error finding JSON file: $e');
      return null;
    }
  }

  // Delete original file from Android Documents directory
  Future<Either<String, bool>> deleteOriginalAndroidFile() async {
    try {
      // Construct the path to the original file in Documents directory
      final documentsDir = Directory('/storage/emulated/0/Documents');
      final originalFilePath = path.join(documentsDir.path, _backupFileName);
      final originalFile = File(originalFilePath);

      // Check if the original file exists
      if (await originalFile.exists()) {
        await originalFile.delete();
        print('Original Android file deleted successfully: $originalFilePath');
        return Right(true);
      } else {
        print('Original Android file not found: $originalFilePath');
        return Left('Original Android file not found');
      }
    } catch (e) {
      print('Warning: Could not delete original Android file: $e');
      return Left('Could not delete original Android file');
      // Don't fail the operation if original file deletion fails
    }
  }
}
