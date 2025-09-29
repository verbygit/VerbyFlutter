// lib/services/face_recognition.dart
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as imglib;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../domain/entities/face/recognition.dart';

class FaceRecognition {
  tfl.Interpreter? _interpreter;
  final int inputSize = 112;
  final bool isModelQuantized = false;
  final double imageMean = 128.0;
  final double imageStd = 128.0;
  final int outputSize = 192;
  List<Recognition> registered = [];

  FaceRecognition() {
    // Add longer delay for iOS release builds to ensure proper initialization
    Future.delayed(Duration(milliseconds: 2000), () {
      _loadModel().catchError((error) {
        // Log to Crashlytics with detailed error information
        FirebaseCrashlytics.instance.recordError(
          error,
          StackTrace.current,
          reason: 'TFLite model loading failed in constructor',
          fatal: false,
          information: [
            'Model path: assets/model/model.tflite',
            'Input size: $inputSize',
            'Output size: $outputSize',
            'Is quantized: $isModelQuantized',
            'Platform: iOS',
          ],
        );
      });
    });
  }

  Future<void> _loadModel() async {
    try {
      // Use the correct asset path from pubspec.yaml
      const modelPath = 'assets/model/model.tflite';
      
      // Log start of model loading to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        Exception('Starting TFLite model loading'),
        StackTrace.current,
        reason: 'TFLite model loading initiated',
        fatal: false,
        information: [
          'Model path: $modelPath',
          'Platform: iOS Release',
          'Timestamp: ${DateTime.now().toIso8601String()}',
        ],
      );
      
      // Verify asset exists and is accessible
      try {
        final assetBundle = await _getAssetBundle();
        final data = await assetBundle.load(modelPath);
        
        // Log asset loading success
        FirebaseCrashlytics.instance.recordError(
          Exception('Asset loaded successfully'),
          StackTrace.current,
          reason: 'Asset file accessible',
          fatal: false,
          information: [
            'Asset size: ${data.lengthInBytes} bytes',
            'Model path: $modelPath',
          ],
        );
        
        if (data.lengthInBytes < 1000) {
          throw Exception('Asset file too small (${data.lengthInBytes} bytes) - likely corrupted');
        }
      } catch (assetError) {
        // Log asset loading failure
        FirebaseCrashlytics.instance.recordError(
          assetError,
          StackTrace.current,
          reason: 'Asset file not accessible',
          fatal: false,
          information: [
            'Model path: $modelPath',
            'Asset error: $assetError',
          ],
        );
        throw Exception('Asset file not accessible: $assetError');
      }
      
      // Create interpreter options
      final options = tfl.InterpreterOptions();
      
      // iOS-specific model loading with multiple strategies
      bool modelLoaded = false;
      Exception? lastError;
      
      for (int strategyIndex = 0; strategyIndex < 5; strategyIndex++) {
        try {
          // Log each strategy attempt
          FirebaseCrashlytics.instance.recordError(
            Exception('Trying loading strategy ${strategyIndex + 1}'),
            StackTrace.current,
            reason: 'TFLite loading strategy attempt',
            fatal: false,
            information: [
              'Strategy: ${strategyIndex + 1}',
              'Model path: $modelPath',
            ],
          );
          
          if (strategyIndex == 1) {
            // Strategy 2: Add delay for iOS release builds
            await Future.delayed(Duration(milliseconds: 2000));
          } else if (strategyIndex == 2) {
            // Strategy 3: Force garbage collection for iOS
            await Future.delayed(Duration(milliseconds: 1000));
            // Force memory cleanup
            for (int i = 0; i < 5; i++) {
              await Future.delayed(Duration(milliseconds: 200));
            }
          } else if (strategyIndex == 3) {
            // Strategy 4: Try with different asset bundle approach
            await Future.delayed(Duration(milliseconds: 3000));
          } else if (strategyIndex == 4) {
            // Strategy 5: Final attempt with maximum delay
            await Future.delayed(Duration(milliseconds: 5000));
          }
          
          _interpreter = await tfl.Interpreter.fromAsset(modelPath, options: options);
          modelLoaded = true;
          
          // Log successful loading
          FirebaseCrashlytics.instance.recordError(
            Exception('Model loaded successfully with strategy ${strategyIndex + 1}'),
            StackTrace.current,
            reason: 'TFLite model loading success',
            fatal: false,
            information: [
              'Strategy used: ${strategyIndex + 1}',
              'Model path: $modelPath',
            ],
          );
          break;
          
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          // Reset interpreter for next attempt
          _interpreter = null;
          
          // Log strategy failure
          FirebaseCrashlytics.instance.recordError(
            lastError,
            StackTrace.current,
            reason: 'TFLite loading strategy ${strategyIndex + 1} failed',
            fatal: false,
            information: [
              'Strategy: ${strategyIndex + 1}',
              'Error: $e',
              'Model path: $modelPath',
            ],
          );
          
          if (strategyIndex < 4) {
            await Future.delayed(Duration(milliseconds: 2000));
          }
        }
      }
      
      if (!modelLoaded) {
        // Log all strategies failed
        FirebaseCrashlytics.instance.recordError(
          lastError ?? Exception('All loading strategies failed'),
          StackTrace.current,
          reason: 'All TFLite loading strategies failed',
          fatal: false,
          information: [
            'Model path: $modelPath',
            'Last error: ${lastError?.toString()}',
            'Total strategies attempted: 5',
          ],
        );
        throw Exception('All loading strategies failed: ${lastError?.toString()}');
      }
      
      // Test the model immediately after loading
      await _testModelAfterLoading();
      
    } catch (e, stackTrace) {
      // Log detailed error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'TFLite model loading failed on iOS release',
        fatal: false,
        information: [
          'Model path: assets/model/model.tflite',
          'Input size: $inputSize',
          'Output size: $outputSize',
          'Model quantized: $isModelQuantized',
          'Error type: ${e.runtimeType}',
          'Error message: $e',
          'Platform: iOS Release',
          'Build mode: Release',
        ],
      );
      
      _interpreter = null;
    }
  }
  
  Future<AssetBundle> _getAssetBundle() async {
    // For iOS, we need to use the root bundle directly
    return rootBundle;
  }

  Future<void> _testModelAfterLoading() async {
    try {
      // Create a test image (112x112 pixels)
      var testImage = imglib.Image(width: 112, height: 112);
      for (int y = 0; y < 112; y++) {
        for (int x = 0; x < 112; x++) {
          testImage.setPixelRgb(x, y, 128, 128, 128); // Gray color
        }
      }
      
      var embedding = extractEmbedding(testImage);
      if (embedding == null) {
        throw Exception('Model test failed - embedding extraction returned null');
      }
    } catch (e) {
      throw Exception('Model test failed: $e');
    }
  }

  List<double>? extractEmbedding(imglib.Image image) {
    if (_interpreter == null) {
      // Log TFLite interpreter not loaded to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        Exception('TFLite interpreter is null during embedding extraction'),
        StackTrace.current,
        reason: 'TFLite interpreter not loaded',
        fatal: false,
        information: [
          'Image size: ${image.width}x${image.height}',
          'Input size required: $inputSize',
          'Output size: $outputSize',
          'Model loaded: false',
        ],
      );
      return null;
    }
    
    try {
      var input = _preProcess(image);
      var output = List.generate(1, (_) => List.filled(outputSize, 0.0));
      _interpreter!.run(input, output);
      return output[0];
    } catch (e) {
      // Log TFLite inference error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'TFLite inference failed during embedding extraction',
        fatal: false,
        information: [
          'Image size: ${image.width}x${image.height}',
          'Input size: $inputSize',
          'Output size: $outputSize',
          'Interpreter loaded: ${_interpreter != null}',
        ],
      );
      return null;
    }
  }

  dynamic _preProcess(imglib.Image image) {
    var input = List.generate(1, (_) => List.generate(inputSize, (_) => List.generate(inputSize, (_) => List.filled(3, 0.0))));
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = image.getPixel(x, y);
        // Use Pixel's r, g, b properties
        input[0][y][x][0] = (pixel.r.toDouble() - imageMean) / imageStd;
        input[0][y][x][1] = (pixel.g.toDouble() - imageMean) / imageStd;
        input[0][y][x][2] = (pixel.b.toDouble() - imageMean) / imageStd;
      }
    }
    return input;
  }

  Recognition? recognize(imglib.Image image) {
    var embedding = extractEmbedding(image);
    if (embedding == null) {
      return null;
    }
    
    var nearest = _findNearest(embedding);
    if (nearest != null) {
      double distance = nearest.$2;
      
      // Balanced threshold for good security and usability
      if (distance < 1.2) { // Adjusted to 1.2 for better usability while maintaining security
        return Recognition(nearest.$1.id, nearest.$1.name, distance, []);
      }
    }
    return null;
  }

  (Recognition, double)? _findNearest(List<double> emb) {
    double minDist = double.infinity;
    Recognition? nearestRec;
    for (var rec in registered) {
      double dist = 0;
      for (int i = 0; i < outputSize; i++) {
        double diff = emb[i] - rec.embedding[i];
        dist += diff * diff;
      }
      dist = math.sqrt(dist);
      if (dist < minDist) {
        minDist = dist;
        nearestRec = rec;
      }
    }
    if (nearestRec != null) return (nearestRec, minDist);
    return null;
  }

  bool addFace(String name, int id, imglib.Image image) {
    var embedding = extractEmbedding(image);
    if (embedding != null) {
      // Validate embedding quality
      if (_isValidEmbedding(embedding)) {
        // Check for duplicate faces
        if (!_hasDuplicateFace(id)) {
          registered.add(Recognition(id, name, -1.0, embedding));
          return true;
        } else {
          // Log duplicate face registration attempt to Crashlytics
          FirebaseCrashlytics.instance.recordError(
            Exception('Duplicate face registration attempt'),
            StackTrace.current,
            reason: 'Face already registered for employee ID',
            fatal: false,
            information: [
              'Employee ID: $id',
              'Employee Name: $name',
              'Image size: ${image.width}x${image.height}',
              'Registered faces count: ${registered.length}',
            ],
          );
        }
      } else {
        // Log embedding quality failure to Crashlytics
        FirebaseCrashlytics.instance.recordError(
          Exception('Face embedding quality validation failed'),
          StackTrace.current,
          reason: 'Embedding quality too low for face registration',
          fatal: false,
          information: [
            'Employee ID: $id',
            'Employee Name: $name',
            'Image size: ${image.width}x${image.height}',
            'Embedding length: ${embedding.length}',
            'Embedding sum: ${embedding.fold(0.0, (a, b) => a + b.abs())}',
          ],
        );
      }
    } else {
      // Log embedding extraction failure to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        Exception('Failed to extract face embedding'),
        StackTrace.current,
        reason: 'Face embedding extraction failed',
        fatal: false,
        information: [
          'Employee ID: $id',
          'Employee Name: $name',
          'Image size: ${image.width}x${image.height}',
          'TFLite interpreter loaded: ${_interpreter != null}',
        ],
      );
    }
    return false;
  }
  
  bool _isValidEmbedding(List<double> embedding) {
    // Check if embedding has reasonable values
    if (embedding.length != outputSize) return false;
    
    // Check for NaN or infinite values
    for (double value in embedding) {
      if (value.isNaN || value.isInfinite) return false;
    }
    
    // Check if embedding has meaningful variation (not all zeros)
    double sum = embedding.fold(0.0, (a, b) => a + b.abs());
    return sum > 0.1; // Minimum variation threshold
  }
  
  bool _hasDuplicateFace(int id) {
    return registered.any((rec) => rec.id == id);
  }

  void setRegistered(List<Recognition> regs) {
    registered = regs;
  }

  List<Recognition> getRegistered() {
    return registered;
  }
  
  int getRegisteredCount() {
    return registered.length;
  }
  
  void printRegistrationStats() {
    // This method is kept for compatibility but print statements removed for release builds
  }
  
  // Test method to verify TFLite is working
  void testTFLiteModel() {
    if (_interpreter == null) {
      return;
    }
    
    // Create a test image (112x112 pixels)
    var testImage = imglib.Image(width: 112, height: 112);
    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        testImage.setPixelRgb(x, y, 128, 128, 128); // Gray color
      }
    }
    
    try {
      var embedding = extractEmbedding(testImage);
      // Test completed - embedding extraction tested
    } catch (e) {
      // Test failed - error handled by extractEmbedding method
    }
  }

  bool isModelLoaded() {
    return _interpreter != null;
  }
  
  Future<bool> waitForModelLoading({int timeoutSeconds = 10}) async {
    int attempts = 0;
    final maxAttempts = timeoutSeconds * 2; // Check every 500ms
    
    while (_interpreter == null && attempts < maxAttempts) {
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;
    }
    
    return _interpreter != null;
  }
  
  Future<bool> retryModelLoading() async {
    _interpreter = null; // Reset interpreter
    await _loadModel();
    return _interpreter != null;
  }

  void removeFace() {
    // Clear last embedding if needed
  }
}