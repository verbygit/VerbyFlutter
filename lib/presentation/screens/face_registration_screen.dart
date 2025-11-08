import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  String _status = 'center_your_face'.tr();
  double _progress = 0.0;
  bool _isFaceOrientationCentered = false;

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initializeControllerFuture = _initCamera();
  }
  
  Future<void> _checkModelLoading() async {
    // Wait for model to load with longer timeout for iOS release builds
    final modelLoaded = await _faceRecognition.waitForModelLoading(timeoutSeconds: 30);
    
    if (!modelLoaded) {
      if (mounted) {
        setState(() {
          _status = 'tensorflow_model_failed'.tr();
        });
        
        // Log model loading failure to Crashlytics
        FirebaseCrashlytics.instance.recordError(
          Exception('TensorFlow model failed to load in face registration'),
          StackTrace.current,
          reason: 'TFLite model loading timeout in face registration screen',
          fatal: false,
          information: [
            'Employee ID: ${widget.employee.id}',
            'Employee Name: ${widget.employee.name}',
            'Timeout: 30 seconds',
            'Model loaded: false',
            'Platform: iOS Release',
          ],
        );
      }
    } else {
      // TensorFlow model loaded successfully
      if (mounted) {
        setState(() {
          _status = 'camera_ready_center_face'.tr();
        });
        
        // Log successful model loading
        FirebaseCrashlytics.instance.recordError(
          Exception('TensorFlow model loaded successfully in face registration'),
          StackTrace.current,
          reason: 'TFLite model loading success in face registration screen',
          fatal: false,
          information: [
            'Employee ID: ${widget.employee.id}',
            'Employee Name: ${widget.employee.name}',
            'Model loaded: true',
            'Platform: iOS Release',
          ],
        );
      }
    }
  }
  
  Future<void> _retryModelLoading() async {
    setState(() {
      _status = 'retrying_model_loading'.tr();
    });
    
    final success = await _faceRecognition.retryModelLoading();
    
    if (success) {
      setState(() {
        _status = 'model_loaded_successfully'.tr();
      });
    } else {
      setState(() {
        _status = 'model_loading_failed'.tr();
      });
    }
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
    // Face detector initialized with accurate mode and minFaceSize: 0.05 for registration
  }

  Future<void> _initCamera() async {
    try {
      // Request camera permission only
      final hasPermission = await CameraPermissionHelper.requestCameraPermissionOnly(context);
      if (!hasPermission) {
        setState(() {
          _status = 'camera_permission_denied_only'.tr();
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _status = 'no_cameras_available'.tr();
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback to any camera if front camera not available
      );
      
      _controller = CameraController(frontCamera, ResolutionPreset.low,enableAudio: false);
      await _controller!.initialize();
      
      // Add a small delay before starting image stream to prevent iOS crashes
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if controller is still initialized before starting stream
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.startImageStream(_processImage);
        
        // Initialize orientation points after camera is ready
        _initOrientationPoints();
        
        // Check model loading only after camera permission is granted
        _checkModelLoading();
      } else {
        setState(() {
          _status = 'camera_controller_failed'.tr();
        });
      }
    } catch (e) {
      // Log camera initialization error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Camera initialization failed in face registration',
        fatal: false,
        information: [
          'Employee ID: ${widget.employee.id}',
          'Employee Name: ${widget.employee.name}',
          'Platform: ${Platform.isIOS ? "iOS" : "Android"}',
          'Permission granted: ${_controller?.value.isInitialized ?? false}',
        ],
      );
      
      setState(() {
        _status = 'failed_to_initialize_camera'.tr() + ' ${e.toString()}';
      });
      if (kDebugMode) {
        // Camera initialization error logged to Crashlytics
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
    
    // Device type and orientation ranges configured
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || _faceDetector == null) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        _updateStatus('no_face_detected'.tr());
      } else if (faces.length > 1) {
        _updateStatus('multiple_faces_detected'.tr());
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
          _updateStatus('move_closer'.tr());
        } else {
          final orientation = [
            face.headEulerAngleX ?? 0.0,
            face.headEulerAngleY ?? 0.0,
            face.headEulerAngleZ ?? 0.0,
          ];

          bool start = _checkIfFaceIsCentered(face);
          if (start) {
            _updateStatus('face_centered_capturing'.tr());
            final croppedFace = await _cropFace(image, face);
            if (croppedFace != null) {
              // Check if TensorFlow model is loaded before processing
              if (!_faceRecognition.isModelLoaded()) {
                _updateStatus('tensorflow_model_not_loaded'.tr());
                
                // Log model not loaded error to Crashlytics
                FirebaseCrashlytics.instance.recordError(
                  Exception('TensorFlow model not loaded during face processing'),
                  StackTrace.current,
                  reason: 'TFLite model not available for face processing',
                  fatal: false,
                  information: [
                    'Employee ID: ${widget.employee.id}',
                    'Employee Name: ${widget.employee.name}',
                    'Cropped face size: ${croppedFace.width}x${croppedFace.height}',
                    'Model loaded: false',
                  ],
                );
                return;
              }
              
              final success = _faceRecognition.addFace(
                widget.employee.name!,
                widget.employee.id!,
                croppedFace,
              );

              if (success) {
                _updateStatus('face_registration_successful'.tr());
                await Future.delayed(Duration(seconds: 1));
                _updateStatus('saving_to_database'.tr());
                
                // Save face to database
                await _saveFaceToDatabase(croppedFace);
                
                await Future.delayed(Duration(seconds: 1));
                Navigator.pop(context,true);
              } else {
                // Log the face processing failure to Crashlytics
                FirebaseCrashlytics.instance.recordError(
                  Exception('Face processing failed - addFace returned false'),
                  StackTrace.current,
                  reason: 'Face recognition addFace method failed',
                  fatal: false,
                  information: [
                    'Employee ID: ${widget.employee.id}',
                    'Employee Name: ${widget.employee.name}',
                    'Cropped face size: ${croppedFace.width}x${croppedFace.height}',
                    'Face bounding box: ${face.boundingBox}',
                    'Face orientation: X=${face.headEulerAngleX}, Y=${face.headEulerAngleY}, Z=${face.headEulerAngleZ}',
                    'TFLite interpreter loaded: ${_faceRecognition.getRegisteredCount() > 0 ? "Unknown" : "Likely not loaded"}',
                    'Registered faces count: ${_faceRecognition.getRegisteredCount()}',
                  ],
                );
                
                _updateStatus('failed_to_process_face_retry'.tr());
              }
            } else {
              // Log face cropping failure to Crashlytics
              FirebaseCrashlytics.instance.recordError(
                Exception('Face cropping failed - croppedFace is null'),
                StackTrace.current,
                reason: 'Face cropping process failed',
                fatal: false,
                information: [
                  'Employee ID: ${widget.employee.id}',
                  'Employee Name: ${widget.employee.name}',
                  'Face bounding box: ${face.boundingBox}',
                  'Camera image format: ${image.format}',
                  'Camera image planes: ${image.planes.length}',
                  'Face orientation: X=${face.headEulerAngleX}, Y=${face.headEulerAngleY}, Z=${face.headEulerAngleZ}',
                ],
              );
              
              _updateStatus('failed_to_crop_face'.tr());
            }
          }
        }
      }
    } catch (e) {
      
      // Log to Crashlytics with context
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Face registration image processing failed',
        fatal: false,
        information: [
          'Employee ID: ${widget.employee.id}',
          'Employee Name: ${widget.employee.name}',
          'Camera initialized: ${_controller?.value.isInitialized ?? false}',
          'Face detector initialized: ${_faceDetector != null}',
          'Processing state: $_isProcessing',
        ],
      );
      
      if (mounted) {
        setState(() {
          _status = 'error_processing_image'.tr();
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
          _updateStatus(faceCenterX < frameCenterX ? 'move_face_right'.tr() : 'move_face_left'.tr());
        } else {
          _updateStatus(faceCenterY < frameCenterY ? 'move_face_down'.tr() : 'move_face_up'.tr());
        }
      } else if (!isOrientationCentered) {
        if (!_faceOrientationPoints.first.x.contains(orientation[0])) {
          _updateStatus(orientation[0] < _faceOrientationPoints.first.x.start ? 'move_face_down'.tr() : 'move_face_up'.tr());
        } else if (!_faceOrientationPoints.first.y.contains(orientation[1])) {
          _updateStatus(orientation[1] < _faceOrientationPoints.first.y.start ? 'turn_head_right'.tr() : 'turn_head_left'.tr());
        } else {
        _updateStatus('adjust_head_tilt'.tr());
        }
      }
      
      _isFaceOrientationCentered = isCentered;
      if (wasCentered != _isFaceOrientationCentered) {
        setState(() {});
      }
      
      return isCentered;
    } catch (e) {
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
          employeeName: widget.employee.name ?? 'unknown'.tr(),
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
            _updateStatus('database_save_failed'.tr() + ' $error');
          },
          (_) {
            _updateStatus('face_saved_to_database'.tr());
          },
        );
      } else {
        _updateStatus('no_face_data_to_save'.tr());
      }
    } catch (e) {
      _updateStatus('error_saving_to_database'.tr() + ' $e');
    }
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
      
      // Camera image converted to InputImage
      
    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
        format: format,
        bytesPerRow: image.planes.isNotEmpty ? (image.planes[0].bytesPerRow ?? image.width) : image.width,
      );
      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
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
      // Fallback conversion with 90 degree rotation
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
      }
  }

  Future<imglib.Image?> _cropFace(CameraImage cameraImage, Face face) async {
    try {
    final fullImage = convertYUV420toImageColor(cameraImage);
      if (fullImage == null) {
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
      
      // Log face cropping error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Face cropping method failed with exception',
        fatal: false,
        information: [
          'Employee ID: ${widget.employee.id}',
          'Employee Name: ${widget.employee.name}',
          'Camera image format: ${cameraImage.format}',
          'Camera image planes: ${cameraImage.planes.length}',
          'Face bounding box: ${face.boundingBox}',
          'Camera resolution: ${_controller?.value.previewSize}',
        ],
      );
      
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
      
      // Log image conversion error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Camera image format conversion failed',
        fatal: false,
        information: [
          'Employee ID: ${widget.employee.id}',
          'Employee Name: ${widget.employee.name}',
          'Platform: ${Platform.isIOS ? "iOS" : "Android"}',
          'Image format: ${image.format}',
          'Image dimensions: ${image.width}x${image.height}',
          'Image planes: ${image.planes.length}',
        ],
      );
      
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
      appBar: AppBar(
        backgroundColor: MColors().darkGrey,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
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
                    child: GestureDetector(
                      onTap: _status.contains('tensorflow_model_failed'.tr()) ? _retryModelLoading : null,
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: _status.contains('tensorflow_model_failed'.tr()) ? Colors.blue : Colors.black,
                          decoration: _status.contains('tensorflow_model_failed'.tr()) ? TextDecoration.underline : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
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