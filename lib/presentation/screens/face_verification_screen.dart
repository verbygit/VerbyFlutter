
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';
import 'package:verby_flutter/presentation/providers/reposiory/face_repo_provider.dart';
import '../../data/service/face_recognition.dart';
import '../../domain/entities/face/recognition.dart';

class Range {
  final double start;
  final double end;

  Range(this.start, this.end);

  bool contains(double value) {
    return value >= start && value <= end;
  }
}

 class FaceVerificationScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const FaceVerificationScreen({super.key, required this.employee});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FaceVerificationScreenState();
 
  }
}

enum EyeState { eyesOpen, eyesClosed, blinkDetected, none }

class _FaceVerificationScreenState extends ConsumerState<FaceVerificationScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _faceDetector;
  final FaceRecognition _faceRecognition = FaceRecognition();
  bool _isProcessing = false;
  bool _isFaceRecognized = false;
  bool _isBlinkDetected = false;
  double _progress = 0.0;
  int _frameCounter = 0;
  final int _frameInterval = 2;
  final int _maxFrames = 30; // Reduced from 60 to 30 for faster timeout
  int _numberOfFrames = 0;
  int _eyesClosedFrames = 0;
  final int _closedThreshold = 1; // Reduced from 2 to 1 for faster verification
  EyeState _currentEyeState = EyeState.none;
  String _status = 'Loading registered face...';
  int _retryCount = 0;
  final int _maxRetries = 3; // Example
  bool _isFaceOrientationCentered = false;
  List<({Range x, Range y, Range z})> _faceOrientationPoints = [];

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initOrientationPoints();
    _initializeControllerFuture = _initCamera();
    _loadRegisteredFaces();
  }

  Future<void> _loadRegisteredFaces() async {
    try {
      final faceRepo = ref.read(faceRepoProvider);
      final result = await faceRepo.getFaceByEmployeeId(widget.employee.id.toString());
      
      result.fold(
        (error) {
          print('❌ Failed to load face from database: $error');
          _updateStatus('Failed to load registered face');
        },
        (faceModel) {
          if (faceModel != null) {
            // Convert FaceModel to Recognition entity and add to face recognition service
            final recognition = Recognition(
              int.parse(faceModel.employeeId),
              faceModel.employeeName,
              0.0,
              faceModel.faceEmbedding,
            );
            _faceRecognition.setRegistered([recognition]);
            print('✅ Loaded registered face for employee: ${faceModel.employeeName}');
            _updateStatus('Registered face loaded - ready for verification');
          } else {
            print('❌ No registered face found for employee: ${widget.employee.id}');
            _updateStatus('No registered face found for this employee');
          }
        },
      );
    } catch (e) {
      print('❌ Error loading registered faces: $e');
      _updateStatus('Error loading registered face');
    }
  }

  void _initFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
    );
    _faceDetector = FaceDetector(options: options);
  }

  void _initOrientationPoints() {
    // Define acceptable face orientation ranges for verification
    // X: pitch (nodding up/down), Y: yaw (turning left/right), Z: roll (tilting left/right)
    _faceOrientationPoints.add((
      x: Range(-20, 20),  // Allow more up/down movement
      y: Range(-20, 20),  // Allow more left/right movement
      z: Range(-95, -60), // More flexible Z range based on actual detection data
    ));
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

  Future<void> _processImage(CameraImage image) async {
    _frameCounter++;
    if (_frameCounter % _frameInterval != 0) return;
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _updateStatus('No face detected - please look at camera');
      } else if (faces.length > 1) {
        _updateStatus('Multiple faces detected - please ensure only one person is in frame');
      } else {
        final face = faces.first;
        final boundingBox = face.boundingBox;
        final width = boundingBox.width;
        final height = boundingBox.height;

        if (width < 200 || height < 200) {
          _updateStatus('Move closer to camera - face too small');
          print('📏 Face too small: ${width.toInt()}x${height.toInt()} (need >200x200)');
        } else {
          // Check face orientation for centering
          final orientation = [
            face.headEulerAngleX ?? 0.0,
            face.headEulerAngleY ?? 0.0,
            face.headEulerAngleZ ?? 0.0,
          ];

          print(
            '🎯 Face detected - Size: ${width.toInt()}x${height.toInt()}, Orientation: [${orientation[0].toStringAsFixed(1)}, ${orientation[1].toStringAsFixed(1)}, ${orientation[2].toStringAsFixed(1)}]',
          );

          bool isCentered = _checkIfFaceIsCentered(orientation);
          if (isCentered) {
            _updateStatus('Face centered! Verifying...');
            final croppedFace = await _cropFace(image, face);
            if (croppedFace != null) {
              final recognition = _faceRecognition.recognize(croppedFace);
              if (recognition != null) {
                print('🔍 Face recognition result: ID=${recognition.id}, Distance=${recognition.distance.toStringAsFixed(3)}, Name=${recognition.name}');
                print('🎯 Expected employee ID: ${widget.employee.id}');
                _analyzeFace(face, recognition);
              } else {
                _updateStatus('Face not recognized - please ensure you are the registered person');
              }
            } else {
              _updateStatus('Failed to process face - please try again');
            }
          } else {
            _updateStatus('Please center your face in the frame');
          }
        }
      }

      _numberOfFrames++;
      if (_numberOfFrames >= _maxFrames && !_isFaceRecognized) {
        _updateStatus('Verification timeout - please try again');
        _retryCount++;
        if (_retryCount >= _maxRetries) {
          _updateStatus('Maximum retries reached - verification failed');
          Future.delayed(Duration(seconds: 2), () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context, false);
            }
          });
        }
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      _updateStatus('Error processing image');
    }

    _isProcessing = false;
  }

  void _analyzeFace(Face face, Recognition recognition) {
    final leftEyeProb = face.leftEyeOpenProbability ?? 0.0;
    final rightEyeProb = face.rightEyeOpenProbability ?? 0.0;
    final eyesClosed = leftEyeProb < 0.85 && rightEyeProb < 0.85; // More sensitive eye detection

    // Check if face matches the registered employee
    if (recognition.id == widget.employee.id) {
      if (!_isFaceRecognized && recognition.distance < 1.5) {
        _isFaceRecognized = true;
        setState(() => _progress += 50);
        _updateStatus('Face recognized! Please blink to verify');
      }

      switch (_currentEyeState) {
        case EyeState.eyesOpen:
          if (eyesClosed) {
            _currentEyeState = EyeState.eyesClosed;
            _eyesClosedFrames = 1;
          }
          break;
        case EyeState.eyesClosed:
          if (eyesClosed) {
            _eyesClosedFrames++;
            if (_eyesClosedFrames >= _closedThreshold) {
              _currentEyeState = EyeState.blinkDetected;
              _updateStatus('Blink detected! Verification successful');
            }
          } else {
            _currentEyeState = EyeState.eyesOpen;
            _eyesClosedFrames = 0;
          }
          break;
        case EyeState.blinkDetected:
          if (!eyesClosed) {
            setState(() => _progress += 50);
            _updateStatus('Verification successful!');
            // Update last used timestamp in database
            _updateLastUsedTimestamp();
            // Success, navigate back
            Future.delayed(Duration(seconds: 1), () {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context, true);
              }
            });
          }
          break;
        case EyeState.none:
          _currentEyeState = eyesClosed ? EyeState.eyesClosed : EyeState.eyesOpen;
          break;
      }
    } else {
      _updateStatus('Face does not match registered employee');
    }
  }

  Future<void> _updateLastUsedTimestamp() async {
    try {
      final faceRepo = ref.read(faceRepoProvider);
      await faceRepo.updateLastUsed(widget.employee.id.toString());
      print('✅ Updated last used timestamp for employee: ${widget.employee.id}');
    } catch (e) {
      print('❌ Error updating last used timestamp: $e');
    }
  }

  void _updateStatus(String message) {
    if (_status != message && mounted) {
      setState(() => _status = message);
      print('📱 Verification Status: $message');
    }
  }

  bool _checkIfFaceIsCentered(List<double> orientation) {
    bool wasCentered = _isFaceOrientationCentered;
    
    if (_faceOrientationPoints.isNotEmpty) {
      final target = _faceOrientationPoints.first;
      print('🎯 Checking orientation: X=${orientation[0].toStringAsFixed(1)} (range: ${target.x.start} to ${target.x.end}), Y=${orientation[1].toStringAsFixed(1)} (range: ${target.y.start} to ${target.y.end}), Z=${orientation[2].toStringAsFixed(1)} (range: ${target.z.start} to ${target.z.end})');
      
      if (target.x.contains(orientation[0]) &&
          target.y.contains(orientation[1]) &&
          target.z.contains(orientation[2])) {
        if (!wasCentered) {
          _isFaceOrientationCentered = true;
          if (mounted) setState(() {});
          print('🟢 Face centered! Container should turn GREEN');
        }
        return true;
      } else {
        if (wasCentered) {
          _isFaceOrientationCentered = false;
          if (mounted) setState(() {});
          print('🔴 Face not centered! Container should turn RED');
        }
        print('❌ Face not centered - X: ${target.x.contains(orientation[0])}, Y: ${target.y.contains(orientation[1])}, Z: ${target.z.contains(orientation[2])}');
      }
    }
    return false;
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    // Same as registration
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final rotation =
        InputImageRotationValue.fromRawValue(0) ??
        InputImageRotation.rotation0deg;
    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<imglib.Image?> _cropFace(CameraImage cameraImage, Face face) async {
    // Same as registration
    final fullImage = convertYUV420toImageColor(cameraImage);
    var boundingBox = face.boundingBox;
    var cropped = imglib.copyCrop(
      fullImage,
      x: boundingBox.left.toInt(),
      y: boundingBox.top.toInt(),
      width: boundingBox.width.toInt(),
      height: boundingBox.height.toInt(),
    );
    cropped = imglib.flipHorizontal(cropped);
    return imglib.copyResize(cropped, width: 112, height: 112);
  }

  imglib.Image convertYUV420toImageColor(CameraImage image) {
    // Same as in registration
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

    return imglib.copyRotate(img, angle: 90);
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
      appBar: AppBar(title: const Text('Face Verification')),
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
