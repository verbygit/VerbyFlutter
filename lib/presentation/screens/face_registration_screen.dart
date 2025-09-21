import 'dart:io';
import 'dart:math';
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
import '../../utils/camera_permission_helper.dart';


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
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  FaceDetector? _faceDetector;
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
  }

  void _initFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: false,
      enableLandmarks: false, // Not needed for registration
      enableClassification: false, // Not needed for registration
      enableTracking: false,
      minFaceSize: 0.05, // Even smaller minimum face size
    );
    _faceDetector = FaceDetector(options: options);
    print('🔧 Face detector initialized with accurate mode and minFaceSize: 0.05 for registration');
  }

  Future<void> _initCamera() async {
    try {
      // Request camera permission first
      final hasPermission = await CameraPermissionHelper.requestCameraPermission(context);
      if (!hasPermission) {
        setState(() {
          _status = 'Camera permission denied. Please enable camera access in settings.';
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _status = 'No cameras available on this device.';
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback to any camera if front camera not available
      );
      
      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      await _controller!.initialize();
      
      // Add a small delay before starting image stream to prevent iOS crashes
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if controller is still initialized before starting stream
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.startImageStream(_processImage);
        
        // Initialize orientation points after camera is ready
        _initOrientationPoints();
      
      setState(() {
        _status = 'Camera initialized successfully. Center your face.';
      });
      } else {
        setState(() {
          _status = 'Camera controller failed to initialize properly.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize camera: ${e.toString()}';
      });
      if (kDebugMode) {
        print('Camera initialization error: $e');
      }
    }
  }

  void _initOrientationPoints() {
    // Dynamic orientation ranges that adapt to device type and screen size
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));
    final isTablet = screenDiagonal > 1000; // Tablets typically have diagonal > 1000 logical pixels
    final isLargeScreen = screenSize.width > 600; // Large screens (tablets, foldables)
    
    // Base ranges that work for most devices
    double xRange = 20.0;
    double yRange = 20.0;
    double zRangeStart, zRangeEnd;
    
    if (Platform.isIOS) {
      // iOS face detection typically returns Z-axis values between -15 and +15
      zRangeStart = -15.0;
      zRangeEnd = 15.0;
    } else {
      // Android face detection typically returns Z-axis values between -90 and -60
      zRangeStart = -90.0;
      zRangeEnd = -60.0;
    }
    
    // Adjust ranges based on device type
    if (isTablet) {
      // Tablets: More relaxed ranges since users are typically further away
      xRange = 30.0;  // More tolerance for up/down movement
      yRange = 30.0;  // More tolerance for left/right movement
      if (Platform.isIOS) {
        zRangeStart = -20.0;  // Slightly more relaxed for tablets
        zRangeEnd = 20.0;
      } else {
        zRangeStart = -95.0;  // Slightly more relaxed for tablets
        zRangeEnd = -55.0;
      }
    } else if (isLargeScreen) {
      // Large phones/foldables: Moderate ranges
      xRange = 25.0;
      yRange = 25.0;
      if (Platform.isIOS) {
        zRangeStart = -18.0;
        zRangeEnd = 18.0;
      } else {
        zRangeStart = -92.0;
        zRangeEnd = -58.0;
      }
    }
    
    _faceOrientationPoints.add((
      x: Range(-xRange, xRange),
      y: Range(-yRange, yRange),
      z: Range(zRangeStart, zRangeEnd),
    ));
    
    print('📱 Device type: ${isTablet ? "Tablet" : isLargeScreen ? "Large Screen" : "Phone"}');
    print('📏 Screen size: ${screenSize.width.toInt()}x${screenSize.height.toInt()} (diagonal: ${screenDiagonal.toInt()})');
    print('🎯 Orientation ranges: X:±${xRange.toInt()}, Y:±${yRange.toInt()}, Z:${zRangeStart.toInt()} to ${zRangeEnd.toInt()}');
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || _faceDetector == null) return;
    _isProcessing = true;

    print('🔄 Processing image frame...');
    try {
      final inputImage = _convertCameraImageToInputImage(image);
      print('🔍 Processing input image: ${inputImage.metadata?.size}');
      final faces = await _faceDetector!.processImage(inputImage);
      print('👤 Faces detected: ${faces.length}');

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

        // Calculate dynamic face size thresholds based on device type and screen size
        final screenSize = MediaQuery.of(context).size;
        final cameraResolution = _controller!.value.previewSize;
        final screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));
        final isTablet = screenDiagonal > 1000;
        final isLargeScreen = screenSize.width > 600;
        
        // Dynamic face size thresholds based on device type
        double minPixelSizeRatio;
        double minFaceSizeRatio;
        
        if (isTablet) {
          // Tablets: More relaxed thresholds since users are further away
          minPixelSizeRatio = 0.20; // 20% of screen width (was 25%)
          minFaceSizeRatio = 0.12;  // 12% of camera frame (was 15%)
        } else if (isLargeScreen) {
          // Large phones/foldables: Moderate thresholds
          minPixelSizeRatio = 0.22; // 22% of screen width
          minFaceSizeRatio = 0.13;  // 13% of camera frame
        } else {
          // Regular phones: Standard thresholds
          minPixelSizeRatio = 0.25; // 25% of screen width
          minFaceSizeRatio = 0.15;  // 15% of camera frame
        }
        
        final minPixelSize = (screenSize.width * minPixelSizeRatio).toInt().clamp(120, 400);
        
        // Check if camera resolution is available for ratio calculation
        double faceSizeRatio = 0.0;
        if (cameraResolution != null) {
          faceSizeRatio = (width * height) / (cameraResolution.height * cameraResolution.width);
        }
        
        if (width < minPixelSize || height < minPixelSize || (cameraResolution != null && faceSizeRatio < minFaceSizeRatio)) {
          _updateStatus('Move closer to camera - face too small');
          print('📏 Face size check: ${width.toInt()}x${height.toInt()} (min: ${minPixelSize}px), ratio: ${(faceSizeRatio * 100).toStringAsFixed(1)}% (min: ${(minFaceSizeRatio * 100).toInt()}%)');
        } else {
          final orientation = [
            face.headEulerAngleX ?? 0.0,
            face.headEulerAngleY ?? 0.0,
            face.headEulerAngleZ ?? 0.0,
          ];

          print(
            '🎯 Face detected - Size: ${width.toInt()}x${height.toInt()}, Orientation: [${orientation[0].toStringAsFixed(1)}, ${orientation[1].toStringAsFixed(1)}, ${orientation[2].toStringAsFixed(1)}]',
          );

          bool start = _checkIfFaceIsCentered(face);
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
      if (mounted) {
        setState(() {
          _status = 'Error processing image. Please try again.';
        });
      }
    }

    _isProcessing = false;
  }

  bool _checkIfFaceIsCentered(Face face) {
    bool wasCentered = _isFaceOrientationCentered;
    
    try {
      // Get face bounding box
      final boundingBox = face.boundingBox;
      final faceCenterX = boundingBox.left + (boundingBox.width / 2);
      final faceCenterY = boundingBox.top + (boundingBox.height / 2);
      
      // Get camera frame dimensions
      final cameraResolution = _controller?.value.previewSize;
      if (cameraResolution == null) {
        _isFaceOrientationCentered = false;
        return false;
      }
      
      final frameCenterX = cameraResolution.width / 2;
      final frameCenterY = cameraResolution.height / 2;
      
      // Calculate distance from center
      final deltaX = (faceCenterX - frameCenterX).abs();
      final deltaY = (faceCenterY - frameCenterY).abs();
      
      // Dynamic thresholds based on device type
      final screenSize = MediaQuery.of(context).size;
      final screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));
      final isTablet = screenDiagonal > 1000;
      final isLargeScreen = screenSize.width > 600;
      
      double thresholdX, thresholdY;
      if (isTablet) {
        thresholdX = cameraResolution.width * 0.20;  // 20% for tablets
        thresholdY = cameraResolution.height * 0.20;
      } else if (isLargeScreen) {
        thresholdX = cameraResolution.width * 0.18;  // 18% for large screens
        thresholdY = cameraResolution.height * 0.18;
      } else {
        thresholdX = cameraResolution.width * 0.15;  // 15% for phones
        thresholdY = cameraResolution.height * 0.15;
      }
      
      // Check if face is centered
      final isPositionCentered = deltaX <= thresholdX && deltaY <= thresholdY;
      
      // Also check head orientation for better accuracy
      final orientation = [
        face.headEulerAngleX ?? 0.0,
        face.headEulerAngleY ?? 0.0,
        face.headEulerAngleZ ?? 0.0,
      ];
      
      bool isOrientationCentered = false;
      if (_faceOrientationPoints.isNotEmpty) {
        final target = _faceOrientationPoints.first;
        isOrientationCentered = target.x.contains(orientation[0]) &&
                               target.y.contains(orientation[1]) &&
                               target.z.contains(orientation[2]);
      }
      
      // Face is centered if both position and orientation are good
      final isCentered = isPositionCentered && isOrientationCentered;
      
      if (!isPositionCentered) {
        if (deltaX > thresholdX) {
          _updateStatus(faceCenterX < frameCenterX ? 'Move face right' : 'Move face left');
        } else {
          _updateStatus(faceCenterY < frameCenterY ? 'Move face down' : 'Move face up');
        }
      } else if (!isOrientationCentered) {
        if (!_faceOrientationPoints.first.x.contains(orientation[0])) {
          _updateStatus(orientation[0] < _faceOrientationPoints.first.x.start ? 'Move face down' : 'Move face up');
        } else if (!_faceOrientationPoints.first.y.contains(orientation[1])) {
          _updateStatus(orientation[1] < _faceOrientationPoints.first.y.start ? 'Turn head right' : 'Turn head left');
        } else {
        _updateStatus('Adjust head tilt');
        }
      }
      
      _isFaceOrientationCentered = isCentered;
      if (wasCentered != _isFaceOrientationCentered) {
        if (isCentered) {
        print('🟢 Face centered! Container should turn GREEN');
        } else {
          print('🔴 Face not centered! Container should turn RED');
        }
        setState(() {});
      }
      
      print('🎯 Face centering: Position(${isPositionCentered ? "✅" : "❌"}) Orientation(${isOrientationCentered ? "✅" : "❌"}) Overall(${isCentered ? "✅" : "❌"})');
      print('📍 Face center: (${faceCenterX.toInt()}, ${faceCenterY.toInt()}) Frame center: (${frameCenterX.toInt()}, ${frameCenterY.toInt()})');
      print('📏 Delta: (${deltaX.toInt()}, ${deltaY.toInt()}) Threshold: (${thresholdX.toInt()}, ${thresholdY.toInt()})');
      
      return isCentered;
    } catch (e) {
      print('❌ Error in face centering check: $e');
    _isFaceOrientationCentered = false;
      return false;
    }
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
    try {
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final size = Size(image.width.toDouble(), image.height.toDouble());
      
      // Platform-specific handling
      InputImageRotation rotation;
      InputImageFormat format;
      
      if (Platform.isIOS) {
        rotation = InputImageRotation.rotation90deg; // iOS camera is rotated
        format = InputImageFormat.bgra8888; // iOS uses BGRA format
      } else {
        // Android - try 0 degree rotation first
        rotation = InputImageRotation.rotation0deg; // Try 0 degrees for Android
        format = InputImageFormat.nv21; // Android uses NV21 format
      }
      
      print('📸 Camera image: ${image.width}x${image.height}, format: ${image.format}, planes: ${image.planes.length}');
      print('🔄 Converted to: ${size.width.toInt()}x${size.height.toInt()}, rotation: $rotation, format: $format');
      
    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
        format: format,
        bytesPerRow: image.planes.isNotEmpty ? (image.planes[0].bytesPerRow ?? image.width) : image.width,
      );
      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      print('Error converting camera image: $e');
      // Fallback to basic conversion
      final allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final size = Size(image.width.toDouble(), image.height.toDouble());
      final metadata = InputImageMetadata(
        size: size,
        rotation: InputImageRotation.rotation90deg, // Try 90 degrees as fallback
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.isNotEmpty ? (image.planes[0].bytesPerRow ?? image.width) : image.width,
      );
      print('🔄 Fallback conversion with 90 degree rotation');
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
      }
  }

  Future<imglib.Image?> _cropFace(CameraImage cameraImage, Face face) async {
    try {
    final fullImage = convertYUV420toImageColor(cameraImage);
      if (fullImage == null) {
        print('❌ Failed to convert camera image to color image');
        return null;
      }
      
    var boundingBox = face.boundingBox;
      
      // Ensure bounding box is within image bounds
      final x = boundingBox.left.toInt().clamp(0, fullImage.width - 1);
      final y = boundingBox.top.toInt().clamp(0, fullImage.height - 1);
      final width = boundingBox.width.toInt().clamp(1, fullImage.width - x);
      final height = boundingBox.height.toInt().clamp(1, fullImage.height - y);
      
    var cropped = imglib.copyCrop(
      fullImage,
        x: x,
        y: y,
        width: width,
        height: height,
    );
    cropped = imglib.flipHorizontal(cropped); // flipX for front camera
    return imglib.copyResize(cropped, width: 112, height: 112);
    } catch (e) {
      print('❌ Error cropping face: $e');
      return null;
    }
  }

  imglib.Image? convertYUV420toImageColor(CameraImage image) {
    try {
      if (Platform.isIOS) {
        // iOS uses BGRA format, so we need to handle it differently
        return _convertIOSImageToColor(image);
      } else {
        // Android YUV420 format
        return _convertAndroidYUV420toImageColor(image);
      }
    } catch (e) {
      print('❌ Error converting image: $e');
      return null;
    }
  }

  imglib.Image _convertIOSImageToColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    
    // iOS camera image is already in BGRA format
    var img = imglib.Image(width: width, height: height);
    
    final bytesPerRow = image.planes[0].bytesPerRow;
    final bytes = image.planes[0].bytes;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * bytesPerRow + x * 4; // BGRA = 4 bytes per pixel
        
        if (index + 3 < bytes.length) {
          final b = bytes[index];
          final g = bytes[index + 1];
          final r = bytes[index + 2];
          // final a = bytes[index + 3]; // Alpha channel, not needed
          
          img.setPixelRgb(x, y, r, g, b);
        }
      }
    }
    
    return img;
  }

  imglib.Image _convertAndroidYUV420toImageColor(CameraImage image) {
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

        if (index < image.planes[0].bytes.length && 
            uvIndex < image.planes[1].bytes.length && 
            uvIndex < image.planes[2].bytes.length) {

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
    }

    return imglib.copyRotate(img, angle: 90);
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
                      child: _controller != null && _controller!.value.isInitialized
                          ? CameraPreview(_controller!)
                          : Container(
                              color: Colors.black,
                              child: Center(
                                child: Text(
                                  _status,
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
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