// lib/services/face_recognition.dart
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as imglib;

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
    _loadModel().then((_) {
      // Test the model after loading
      Future.delayed(Duration(seconds: 2), () {
        testTFLiteModel();
      });
    });
  }

  Future<void> _loadModel() async {
    try {
      final options = tfl.InterpreterOptions()..threads = 4;
      print('Attempting to load TFLite model...');
      
      // Try multiple asset paths
      List<String> assetPaths = [
        'assets/mobile_face_net.tflite',
        'mobile_face_net.tflite',
        'assets/mobile_face_net.tflite'
      ];
      
      for (String path in assetPaths) {
        try {
          print('Trying path: $path');
          _interpreter = await tfl.Interpreter.fromAsset(path, options: options);
          print('✅ TFLite model loaded successfully from: $path');
          return; // Exit if successful
        } catch (e) {
          print('❌ Failed to load from $path: $e');
        }
      }
      
      print('❌ All asset paths failed. Model not loaded.');
    } catch (e) {
      print('❌ Critical error in _loadModel: $e');
    }
  }

  List<double>? extractEmbedding(imglib.Image image) {
    if (_interpreter == null) return null;
    var input = _preProcess(image);
    var output = List.generate(1, (_) => List.filled(outputSize, 0.0));
    _interpreter!.run(input, output);
    return output[0];
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
      print('❌ Failed to extract embedding from image');
      return null;
    }
    
    var nearest = _findNearest(embedding);
    if (nearest != null) {
      double distance = nearest.$2;
      print('🔍 Nearest face found - Distance: ${distance.toStringAsFixed(3)}');
      
      // Balanced threshold for good security and usability
      if (distance < 1.2) { // Adjusted to 1.2 for better usability while maintaining security
        print('✅ Face recognized with high confidence');
        return Recognition(nearest.$1.id, nearest.$1.name, distance, []);
      } else {
        print('❌ Face distance too high: ${distance.toStringAsFixed(3)} (threshold: 1.2)');
      }
    } else {
      print('❌ No registered faces found for comparison');
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
    print('📝 Adding face for: $name (ID: $id)');
    
    var embedding = extractEmbedding(image);
    if (embedding != null) {
      // Validate embedding quality
      if (_isValidEmbedding(embedding)) {
        // Check for duplicate faces
        if (!_hasDuplicateFace(id)) {
          registered.add(Recognition(id, name, -1.0, embedding));
          print('✅ Face added successfully for: $name');
          return true;
        } else {
          print('❌ Face already registered for ID: $id');
        }
      } else {
        print('❌ Embedding quality too low for: $name');
      }
    } else {
      print('❌ Failed to extract embedding for: $name');
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
    print('📊 Face Registration Statistics:');
    print('   Total registered faces: ${registered.length}');
    print('   TFLite interpreter loaded: ${_interpreter != null}');
    print('   Output size: $outputSize');
    
    for (var rec in registered) {
      print('   - ID: ${rec.id}, Name: ${rec.name}');
    }
  }
  
  // Test method to verify TFLite is working
  void testTFLiteModel() {
    print('🧪 Testing TFLite Model...');
    if (_interpreter == null) {
      print('❌ Interpreter is null');
      return;
    }
    
    // Create a test image (112x112 pixels)
    var testImage = imglib.Image(width: 112, height: 112);
    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        testImage.setPixelRgb(x, y, 128, 128, 128); // Gray color
      }
    }
    
    print('📸 Test image created: ${testImage.width}x${testImage.height}');
    
    try {
      var embedding = extractEmbedding(testImage);
      if (embedding != null) {
        print('✅ TFLite embedding extraction successful!');
        print('   Embedding length: ${embedding.length}');
        print('   First 5 values: ${embedding.take(5).toList()}');
      } else {
        print('❌ TFLite embedding extraction failed');
      }
    } catch (e) {
      print('❌ Error during TFLite test: $e');
    }
  }

  void removeFace() {
    // Clear last embedding if needed
  }
}