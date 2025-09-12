import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import '../../data/models/remote/employee.dart';
import '../../data/models/local/face_model.dart';
import '../../data/service/face_recognition.dart';
import '../providers/reposiory/face_repo_provider.dart';


class Range {
  final double start;
  final double end;

  Range(this.start, this.end);

  bool contains(double value) {
    return value >= start && value <= end;
  }
}

class FaceRegistrationScreen extends ConsumerStatefulWidget {
  const FaceRegistrationScreen({super.key, required this.employee});

  final Employee employee;

  @override
  ConsumerState<FaceRegistrationScreen> createState() =>
      _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState
    extends ConsumerState<FaceRegistrationScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _faceDetector;
  final FaceRecognition _faceRecognition = FaceRecognition();
  bool _isProcessing = false;
  List<({Range x, Range y, Range z})> _faceOrientationPoints = [];
  String _status = 'Center your face';
  double _progress = 0.0;
  bool _isFaceOrientationCentered = false;

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initializeControllerFuture = _initCamera();
    _initOrientationPoints();
  }

  void _initFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller.initialize();
    await _controller.startImageStream(_processImage);
  }

  void _initOrientationPoints() {
    // Realistic orientation ranges based on actual face detection data
    // X: pitch (looking up/down) - allow more range
    // Y: yaw (turning left/right) - allow more range  
    // Z: roll (head tilt) - based on actual data showing -75 to -85 range
    
    // Create single capture point with realistic ranges
    _faceOrientationPoints.add((
      x: Range(-20, 20),  // Allow more up/down movement
      y: Range(-20, 20),  // Allow more left/right movement
      z: Range(-90, -60), // Based on actual face detection data
    ));
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    print('🔄 Processing image frame...');
    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _updateStatus('No face detected - please look at camera');
      } else if (faces.length > 1) {
        _updateStatus(
          'Multiple faces detected - please ensure only one person is in frame',
        );
      } else {
        final face = faces.first;
        final boundingBox = face.boundingBox;
        final width = boundingBox.width;
        final height = boundingBox.height;

        if (width < 200 || height < 200) {
          _updateStatus('Move closer to camera - face too small');
        } else {
          final orientation = [
            face.headEulerAngleX ?? 0.0,
            face.headEulerAngleY ?? 0.0,
            face.headEulerAngleZ ?? 0.0,
          ];

          print(
            '🎯 Face detected - Size: ${width.toInt()}x${height.toInt()}, Orientation: [${orientation[0].toStringAsFixed(1)}, ${orientation[1].toStringAsFixed(1)}, ${orientation[2].toStringAsFixed(1)}]',
          );

          bool start = _checkIfFaceIsCentered(orientation);
          if (start) {
            _updateStatus('Face centered! Capturing...');
            final croppedFace = await _cropFace(image, face);
            if (croppedFace != null) {
              final success = _faceRecognition.addFace(
                widget.employee.name!,
                widget.employee.id!,
                croppedFace,
              );

              if (success) {
                _updateStatus('Face registration successful!');
                await Future.delayed(Duration(seconds: 1));
                _updateStatus('Saving to database...');
                
                // Save face to database
                await _saveFaceToDatabase(croppedFace);
                
                await Future.delayed(Duration(seconds: 1));
                Navigator.pop(context);
              } else {
                _updateStatus('Failed to process face - please try again');
              }
            } else {
              _updateStatus('Failed to crop face - please try again');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      _updateStatus('Error: $e');
    }

    _isProcessing = false;
  }

  bool _checkIfFaceIsCentered(List<double> orientation) {
    bool wasCentered = _isFaceOrientationCentered;
    
    if (_faceOrientationPoints.isNotEmpty) {
      final target = _faceOrientationPoints.first;
      
      if (!target.x.contains(orientation[0])) {
        _updateStatus(
          orientation[0] < target.x.start ? 'Move face down' : 'Move face up',
        );
        _isFaceOrientationCentered = false;
        if (wasCentered != _isFaceOrientationCentered) {
          print('🔴 Face not centered! Container should turn RED');
          setState(() {});
        }
        return false;
      }
      if (!target.y.contains(orientation[1])) {
        _updateStatus(
          orientation[1] < target.y.start
              ? 'Turn head right'
              : 'Turn head left',
        );
        _isFaceOrientationCentered = false;
        if (wasCentered != _isFaceOrientationCentered) {
          print('🔴 Face not centered! Container should turn RED');
          setState(() {});
        }
        return false;
      }
      if (!target.z.contains(orientation[2])) {
        _updateStatus('Adjust head tilt');
        _isFaceOrientationCentered = false;
        if (wasCentered != _isFaceOrientationCentered) {
          print('🔴 Face not centered! Container should turn RED');
          setState(() {});
        }
        return false;
      }
      _isFaceOrientationCentered = true;
      if (wasCentered != _isFaceOrientationCentered) {
        print('🟢 Face centered! Container should turn GREEN');
        setState(() {});
      }
      return true;
    }
    _isFaceOrientationCentered = false;
    if (wasCentered != _isFaceOrientationCentered) {
      print('🔴 Face not centered! Container should turn RED');
      setState(() {});
    }
    return false;
  }

  bool _checkIfAreValidPoints(List<double> orientation) {
    if (_faceOrientationPoints.isNotEmpty) {
      final points = _faceOrientationPoints.first;
      if (points.x.contains(orientation[0]) &&
          points.y.contains(orientation[1]) &&
          points.z.contains(orientation[2])) {
        return true;
      }
    }
    return false;
  }


  void _updateStatus(String message) {
    if (_status != message) {
      setState(() => _status = message);
      print('📱 Status updated: $message');
    }
  }

  Future<void> _saveFaceToDatabase(imglib.Image croppedFace) async {
    try {
      // Get the face embedding from the face recognition service
      final registeredFaces = _faceRecognition.getRegistered();
      if (registeredFaces.isNotEmpty) {
        final lastRegisteredFace = registeredFaces.last;
        
        // Create FaceModel
        final faceModel = FaceModel(
          employeeId: widget.employee.id.toString(),
          employeeName: widget.employee.name ?? 'Unknown',
          faceEmbedding: lastRegisteredFace.embedding,
          registeredAt: DateTime.now(),
          lastUsedAt: DateTime.now(),
          confidenceThreshold: 0.6,
          isActive: true,
          faceOrientation: null, // Can be added later if needed
          metadata: {
            'face_size': '${croppedFace.width}x${croppedFace.height}',
            'registration_method': 'camera_capture',
          },
        );

        // Save to database using repository
        final faceRepo = ref.read(faceRepoProvider);
        final result = await faceRepo.saveFace(faceModel);
        
        result.fold(
          (error) {
            print('❌ Failed to save face to database: $error');
            _updateStatus('Database save failed: $error');
          },
          (_) {
            print('✅ Face saved to database successfully');
            _updateStatus('Face saved to database!');
          },
        );
      } else {
        print('❌ No registered faces found in face recognition service');
        _updateStatus('No face data to save');
      }
    } catch (e) {
      print('❌ Error saving face to database: $e');
      _updateStatus('Error saving to database: $e');
    }
  }

  void _setFaceState(bool state) {
    // Update UI background or indicator for face detected
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final rotation =
        InputImageRotationValue.fromRawValue(0) ??
        InputImageRotation.rotation0deg; // Adjust
    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<imglib.Image?> _cropFace(CameraImage cameraImage, Face face) async {
    final fullImage = convertYUV420toImageColor(cameraImage);
    var boundingBox = face.boundingBox;
    var cropped = imglib.copyCrop(
      fullImage,
      x: boundingBox.left.toInt(),
      y: boundingBox.top.toInt(),
      width: boundingBox.width.toInt(),
      height: boundingBox.height.toInt(),
    );
    cropped = imglib.flipHorizontal(cropped); // flipX for front camera
    return imglib.copyResize(cropped, width: 112, height: 112);
  }

  imglib.Image convertYUV420toImageColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;
    final int bytesPerRowY = image.planes[0].bytesPerRow;

    var img = imglib.Image(width: width, height: height);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * bytesPerRowY + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        img.setPixelRgb(x, y, r, g, b);
      }
    }

    return imglib.copyRotate(img, angle: 90); // Adjust rotation if needed
  }

  @override
  void dispose() {
    _controller.stopImageStream();
    _controller.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MColors().darkGrey,
        centerTitle: true,
        title: Text(
          "Face Registration",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Container(
                      width: 340.w,
                      height: 340.w,
                      color: _isFaceOrientationCentered?Colors.green:Colors.red,
                      child: Container(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: SizedBox(
                      width: 320.w,
                      height: 320.w,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
