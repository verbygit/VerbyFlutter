import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  Future<Uint8List> _createSimpleZip(
    List<Map<String, dynamic>> records,
  ) async {
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
      // Request storage permission
      if (!await Permission.storage.request().isGranted) {
        print('Storage permission denied');
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
}


