import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';
import 'package:verby_flutter/presentation/providers/reposiory/face_repo_provider.dart';
import 'package:verby_flutter/presentation/screens/select_operation_screen.dart';
import 'package:verby_flutter/presentation/widgets/pulse_animation.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';
import '../../data/service/face_recognition.dart';
import '../../domain/entities/face/recognition.dart';
import '../../utils/camera_permission_helper.dart';

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

class _FaceVerificationScreenState
    extends ConsumerState<FaceVerificationScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  FaceDetector? _faceDetector;
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
  int _maxRetries = 6; // Reduced for testing
  bool _isFaceOrientationCentered = false;
  bool isNavigatedForward = false;
  List<({Range x, Range y, Range z})> _faceOrientationPoints = [];
  bool isRetryFinished = false;

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initializeControllerFuture = _initCamera();
    _loadRegisteredFaces();
    _setMaxTries();
  }

  void _setMaxTries() async {
    final tries =await SharedPreferencesHelper(
      await SharedPreferences.getInstance(),
    ).getFaceTries();
    _maxRetries = tries?.toInt()??6;
    print("_maxRetries==================> $tries");
  }

  Future<void> _loadRegisteredFaces() async {
    try {
      final faceRepo = ref.read(faceRepoProvider);
      final result = await faceRepo.getFaceByEmployeeId(
        widget.employee.id.toString(),
      );

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
            print(
              '✅ Loaded registered face for employee: ${faceModel.employeeName}',
            );
            _updateStatus('Registered face loaded - ready for verification');
          } else {
            print(
              '❌ No registered face found for employee: ${widget.employee.id}',
            );
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
      enableContours: false,
      enableLandmarks: true,
      // Enable landmarks for better eye detection
      enableClassification: true,
      // Enable classification for eye detection
      enableTracking: false,
      minFaceSize: 0.05, // Even smaller minimum face size
    );
    _faceDetector = FaceDetector(options: options);
    print(
      '🔧 Face detector initialized with accurate mode, minFaceSize: 0.05, landmarks and classification enabled',
    );
  }

  void _initOrientationPoints() {
    // Dynamic orientation ranges that adapt to device type and screen size
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    final isTablet =
        screenDiagonal >
        1000; // Tablets typically have diagonal > 1000 logical pixels
    final isLargeScreen =
        screenSize.width > 600; // Large screens (tablets, foldables)

    // Base ranges that work for most devices
    double xRange = 20.0;
    double yRange = 20.0;
    double zRangeStart, zRangeEnd;

    if (Platform.isIOS) {
      // iOS face detection typically returns Z-axis values between -15 and +15
      zRangeStart = -15.0;
      zRangeEnd = 15.0;
    } else {
      // Android face detection typically returns Z-axis values between -95 and -60
      zRangeStart = -95.0;
      zRangeEnd = -60.0;
    }

    // Adjust ranges based on device type
    if (isTablet) {
      // Tablets: More relaxed ranges since users are typically further away
      xRange = 30.0; // More tolerance for up/down movement
      yRange = 30.0; // More tolerance for left/right movement
      if (Platform.isIOS) {
        zRangeStart = -20.0; // Slightly more relaxed for tablets
        zRangeEnd = 20.0;
      } else {
        zRangeStart = -100.0; // Slightly more relaxed for tablets
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
        zRangeStart = -97.0;
        zRangeEnd = -58.0;
      }
    }

    _faceOrientationPoints.add((
      x: Range(-xRange, xRange),
      y: Range(-yRange, yRange),
      z: Range(zRangeStart, zRangeEnd),
    ));

    print(
      '📱 Device type: ${isTablet
          ? "Tablet"
          : isLargeScreen
          ? "Large Screen"
          : "Phone"}',
    );
    print(
      '📏 Screen size: ${screenSize.width.toInt()}x${screenSize.height.toInt()} (diagonal: ${screenDiagonal.toInt()})',
    );
    print(
      '🎯 Orientation ranges: X:±${xRange.toInt()}, Y:±${yRange.toInt()}, Z:${zRangeStart.toInt()} to ${zRangeEnd.toInt()}',
    );
  }

  Future<void> _initCamera() async {
    try {
      // Request camera and audio permissions first
      final hasPermission =
          await CameraPermissionHelper.requestCameraAndAudioPermissions(
            context,
          );
      if (!hasPermission) {
        setState(() {
          _status =
              'Camera or microphone permission denied. Please enable both permissions in settings.';
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
        orElse: () => cameras
            .first, // Fallback to any camera if front camera not available
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
          _status =
              'Camera initialized successfully. Loading registered face...';
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

  Future<void> _processImage(CameraImage image) async {
    _frameCounter++;
    if (_frameCounter % _frameInterval != 0) return;
    if (_isProcessing || _faceDetector == null) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        // Only update status if face verification hasn't passed yet
        if (!_isFaceRecognized) {
          _updateStatus('No face detected - please look at camera');
        }
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
        final screenDiagonal = sqrt(
          pow(screenSize.width, 2) + pow(screenSize.height, 2),
        );
        final isTablet = screenDiagonal > 1000;
        final isLargeScreen = screenSize.width > 600;

        // Dynamic face size thresholds based on device type
        double minPixelSizeRatio;
        double minFaceSizeRatio;

        if (isTablet) {
          // Tablets: More relaxed thresholds since users are further away
          minPixelSizeRatio = 0.20; // 20% of screen width (was 25%)
          minFaceSizeRatio = 0.12; // 12% of camera frame (was 15%)
        } else if (isLargeScreen) {
          // Large phones/foldables: Moderate thresholds
          minPixelSizeRatio = 0.22; // 22% of screen width
          minFaceSizeRatio = 0.13; // 13% of camera frame
        } else {
          // Regular phones: Standard thresholds
          minPixelSizeRatio = 0.25; // 25% of screen width
          minFaceSizeRatio = 0.15; // 15% of camera frame
        }

        final minPixelSize = (screenSize.width * minPixelSizeRatio)
            .toInt()
            .clamp(120, 400);

        // Check if camera resolution is available for ratio calculation
        double faceSizeRatio = 0.0;
        if (cameraResolution != null) {
          faceSizeRatio =
              (width * height) /
              (cameraResolution.height * cameraResolution.width);
        }

        if (width < minPixelSize ||
            height < minPixelSize ||
            (cameraResolution != null && faceSizeRatio < minFaceSizeRatio)) {
          // Only update status if face verification hasn't passed yet
          if (!_isFaceRecognized) {
            _updateStatus('Move closer to camera - face too small');
          }
          print(
            '📏 Face size check: ${width.toInt()}x${height.toInt()} (min: ${minPixelSize}px), ratio: ${(faceSizeRatio * 100).toStringAsFixed(1)}% (min: ${(minFaceSizeRatio * 100).toInt()}%)',
          );
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

          bool isCentered = _checkIfFaceIsCentered(face);
          if (isCentered) {
            // Only update status if face verification hasn't passed yet
            if (!_isFaceRecognized) {
              _updateStatus('Face centered! Verifying...');
            }
            final croppedFace = await _cropFace(image, face);
            if (croppedFace != null) {
              final recognition = _faceRecognition.recognize(croppedFace);
              if (recognition != null) {
                print(
                  '🔍 Face recognition result: ID=${recognition.id}, Distance=${recognition.distance.toStringAsFixed(3)}, Name=${recognition.name}',
                );
                print('🎯 Expected employee ID: ${widget.employee.id}');
                _analyzeFace(face, recognition);
              } else {
                // Face not recognized - increment retry count
                _retryCount++;
                print(
                  '🔄 Face not recognized. Retry count: $_retryCount/$_maxRetries',
                );

                if (_retryCount >= _maxRetries) {
                  print(
                    '🚨 MAXIMUM RETRIES REACHED (face not recognized)! Setting isRetryFinished = true',
                  );
                  _updateStatus(
                    'Maximum retries reached - verification failed',
                  );
                  setState(() {
                    isRetryFinished = true;
                  });
                  print('🚨 isRetryFinished is now: $isRetryFinished');
                  // Stop camera processing and preview
                  _stopCameraProcessing();
                } else {
                  // Only update status if face verification hasn't passed yet
                  if (!_isFaceRecognized) {
                    _updateStatus(
                      'Face not recognized - please ensure you are the registered person',
                    );
                  }
                }
              }
            } else {
              // Face cropping failed - increment retry count
              _retryCount++;
              print(
                '🔄 Face cropping failed. Retry count: $_retryCount/$_maxRetries',
              );

              if (_retryCount >= _maxRetries) {
                print(
                  '🚨 MAXIMUM RETRIES REACHED (face cropping failed)! Setting isRetryFinished = true',
                );
                _updateStatus('Maximum retries reached - verification failed');
                setState(() {
                  isRetryFinished = true;
                });
                print('🚨 isRetryFinished is now: $isRetryFinished');
                // Stop camera processing and preview
                _stopCameraProcessing();
              } else {
                // Only update status if face verification hasn't passed yet
                if (!_isFaceRecognized) {
                  _updateStatus('Failed to process face - please try again');
                }
              }
            }
          } else {
            // Only update status if face verification hasn't passed yet
            if (!_isFaceRecognized) {
              _updateStatus('Please center your face in the frame');
            }
          }
        }
      }

      _numberOfFrames++;
      if (_numberOfFrames >= _maxFrames && !_isFaceRecognized) {
        _updateStatus('Verification timeout - please try again');
        _retryCount++;
        if (_retryCount >= _maxRetries) {
          print('🚨 MAXIMUM RETRIES REACHED! Setting isRetryFinished = true');
          _updateStatus('Maximum retries reached - verification failed');
          setState(() {
            isRetryFinished = true;
          });
          print('🚨 isRetryFinished is now: $isRetryFinished');
          // Stop camera processing and preview
          _stopCameraProcessing();
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

  void _analyzeFace(Face face, Recognition recognition) {
    final leftEyeProb = face.leftEyeOpenProbability;
    final rightEyeProb = face.rightEyeOpenProbability;

    // More robust eye detection logic
    bool eyesClosed = false;

    if (leftEyeProb != null && rightEyeProb != null) {
      // Treat blink if either eye closes below threshold (more permissive)
      const double closedThreshold = 0.35;
      final bool leftClosed = leftEyeProb < closedThreshold;
      final bool rightClosed = rightEyeProb < closedThreshold;
      eyesClosed = leftClosed || rightClosed;
      print(
        '👁️ Eye detection: Left=${leftEyeProb.toStringAsFixed(2)} (closed=$leftClosed), Right=${rightEyeProb.toStringAsFixed(2)} (closed=$rightClosed), Closed=$eyesClosed',
      );
    } else if (leftEyeProb != null) {
      // Only left eye probability available
      eyesClosed = leftEyeProb < 0.35;
      print(
        '👁️ Eye detection: Left=${leftEyeProb.toStringAsFixed(2)}, Right=null, Closed=$eyesClosed',
      );
    } else if (rightEyeProb != null) {
      // Only right eye probability available
      eyesClosed = rightEyeProb < 0.35;
      print(
        '👁️ Eye detection: Left=null, Right=${rightEyeProb.toStringAsFixed(2)}, Closed=$eyesClosed',
      );
    } else {
      // No eye probabilities available - assume eyes are open (don't trigger blink detection)
      eyesClosed = false;
      print(
        '👁️ Eye detection: No probabilities available, assuming eyes open',
      );
    }

    print(
      '👁️ Current eye state: $_currentEyeState, Closed frames: $_eyesClosedFrames',
    );

    // CRITICAL FIX: Check if face matches the registered employee AND has sufficient similarity
    print('🔍 Face verification check:');
    print('   - Recognition ID: ${recognition.id}');
    print('   - Expected Employee ID: ${widget.employee.id}');
    print('   - Face distance: ${recognition.distance.toStringAsFixed(3)}');
    print('   - Distance threshold: 1.2 (balanced)');

    // Use stricter distance threshold for better security
    const double strictDistanceThreshold =
        1.2; // Adjusted to 1.2 for better usability while maintaining security

    if (recognition.id == widget.employee.id &&
        recognition.distance < strictDistanceThreshold) {
      print(
        '✅ Face verification PASSED: ID matches and distance is acceptable',
      );
      print(
        '🔍 Face recognized flag: $_isFaceRecognized, Distance: ${recognition.distance}',
      );
      if (!_isFaceRecognized) {
        _isFaceRecognized = true;
        setState(() => _progress += 50);

        _updateStatus('Face recognized! Verifying...');
        print('✅ Face recognized! Starting liveness verification');
      }

      switch (_currentEyeState) {
        case EyeState.eyesOpen:
          if (eyesClosed) {
            _currentEyeState = EyeState.eyesClosed;
            _eyesClosedFrames = 1;
            print('👁️ Eye state: Open -> Closed (frames: $_eyesClosedFrames)');
          }
          break;
        case EyeState.eyesClosed:
          if (eyesClosed) {
            _eyesClosedFrames++;
            print(
              '👁️ Eye state: Closed (frames: $_eyesClosedFrames/$_closedThreshold)',
            );
            if (_eyesClosedFrames >= _closedThreshold) {
              _currentEyeState = EyeState.blinkDetected;
              _updateStatus('Verification successful!');
              print('✅ Liveness verification completed!');
            }
          } else {
            _currentEyeState = EyeState.eyesOpen;
            _eyesClosedFrames = 0;
            print('👁️ Eye state: Closed -> Open');
          }
          break;
        case EyeState.blinkDetected:
          if (!eyesClosed) {
            setState(() => _progress += 50);
            _updateStatus('Access granted!');
            print('✅ Verification successful! Navigating...');
            // Update last used timestamp in database
            _updateLastUsedTimestamp();
            // Success, navigate back
            if (!isNavigatedForward) {
              isNavigatedForward = true;
              navigatePushAndRemoveUntil(
                context,
                SelectOperationScreen(employee: widget.employee),
                true,
              );
            }
          }
          break;
        case EyeState.none:
          _currentEyeState = eyesClosed
              ? EyeState.eyesClosed
              : EyeState.eyesOpen;
          print('👁️ Eye state: None -> ${_currentEyeState}');
          break;
      }
    } else {
      // Face verification failed - either wrong person or insufficient similarity
      _retryCount++;
      print(
        '🔄 Face verification failed. Retry count: $_retryCount/$_maxRetries',
      );

      if (_retryCount >= _maxRetries) {
        print(
          '🚨 MAXIMUM RETRIES REACHED (face verification failed)! Setting isRetryFinished = true',
        );
        _updateStatus('Maximum retries reached - verification failed');
        setState(() {
          isRetryFinished = true;
        });
        print('🚨 isRetryFinished is now: $isRetryFinished');
        // Stop camera processing and preview
        _stopCameraProcessing();
      } else {
        if (recognition.id != widget.employee.id) {
          print('❌ Face verification FAILED: Wrong person (ID mismatch)');
          _updateStatus('Face does not match registered employee');
        } else if (recognition.distance >= strictDistanceThreshold) {
          print(
            '❌ Face verification FAILED: Distance too high (${recognition.distance.toStringAsFixed(3)} >= $strictDistanceThreshold)',
          );
          _updateStatus('Face similarity too low - please try again');
        } else {
          print('❌ Face verification FAILED: Unknown reason');
          _updateStatus('Face verification failed - please try again');
        }
      }
    }
  }

  Future<void> _updateLastUsedTimestamp() async {
    try {
      final faceRepo = ref.read(faceRepoProvider);
      await faceRepo.updateLastUsed(widget.employee.id.toString());
      print(
        '✅ Updated last used timestamp for employee: ${widget.employee.id}',
      );
    } catch (e) {
      print('❌ Error updating last used timestamp: $e');
    }
  }

  void _stopCameraProcessing() {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.stopImageStream();
        print('📹 Camera processing stopped');
      }
    } catch (e) {
      print('❌ Error stopping camera processing: $e');
    }
  }

  void _restartVerification() {
    print('🔄 RESTART VERIFICATION CALLED! Resetting all state...');
    setState(() {
      // Reset all verification state variables
      _isProcessing = false;
      _isFaceRecognized = false;
      _isBlinkDetected = false;
      _progress = 0.0;
      _frameCounter = 0;
      _numberOfFrames = 0;
      _eyesClosedFrames = 0;
      _currentEyeState = EyeState.none;
      _retryCount = 0;
      _isFaceOrientationCentered = false;
      isNavigatedForward = false;
      isRetryFinished = false;
      _status = 'Loading registered face...';
    });
    print('🔄 isRetryFinished reset to: $isRetryFinished');

    // Restart camera processing
    _restartCameraProcessing();

    // Reload registered faces and restart the process
    _loadRegisteredFaces();
    print('🔄 Verification process restarted');
  }

  void _restartCameraProcessing() {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.startImageStream(_processImage);
        print('📹 Camera processing restarted');
      }
    } catch (e) {
      print('❌ Error restarting camera processing: $e');
    }
  }

  void _updateStatus(String message) {
    if (_status != message && mounted) {
      setState(() => _status = message);
      print('📱 Verification Status: $message');
    }
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
      final screenDiagonal = sqrt(
        pow(screenSize.width, 2) + pow(screenSize.height, 2),
      );
      final isTablet = screenDiagonal > 1000;
      final isLargeScreen = screenSize.width > 600;

      double thresholdX, thresholdY;
      if (isTablet) {
        thresholdX = cameraResolution.width * 0.20; // 20% for tablets
        thresholdY = cameraResolution.height * 0.20;
      } else if (isLargeScreen) {
        thresholdX = cameraResolution.width * 0.18; // 18% for large screens
        thresholdY = cameraResolution.height * 0.18;
      } else {
        thresholdX = cameraResolution.width * 0.15; // 15% for phones
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
        isOrientationCentered =
            target.x.contains(orientation[0]) &&
            target.y.contains(orientation[1]) &&
            target.z.contains(orientation[2]);
      }

      // Face is centered if both position and orientation are good
      final isCentered = isPositionCentered && isOrientationCentered;

      if (!isPositionCentered) {
        if (deltaX > thresholdX) {
          _updateStatus(
            faceCenterX < frameCenterX ? 'Move face right' : 'Move face left',
          );
        } else {
          _updateStatus(
            faceCenterY < frameCenterY ? 'Move face down' : 'Move face up',
          );
        }
      } else if (!isOrientationCentered) {
        if (!_faceOrientationPoints.first.x.contains(orientation[0])) {
          _updateStatus(
            orientation[0] < _faceOrientationPoints.first.x.start
                ? 'Move face down'
                : 'Move face up',
          );
        } else if (!_faceOrientationPoints.first.y.contains(orientation[1])) {
          _updateStatus(
            orientation[1] < _faceOrientationPoints.first.y.start
                ? 'Turn head right'
                : 'Turn head left',
          );
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
        if (mounted) setState(() {});
      }

      print(
        '🎯 Face centering: Position(${isPositionCentered ? "✅" : "❌"}) Orientation(${isOrientationCentered ? "✅" : "❌"}) Overall(${isCentered ? "✅" : "❌"})',
      );
      print(
        '📍 Face center: (${faceCenterX.toInt()}, ${faceCenterY.toInt()}) Frame center: (${frameCenterX.toInt()}, ${frameCenterY.toInt()})',
      );
      print(
        '📏 Delta: (${deltaX.toInt()}, ${deltaY.toInt()}) Threshold: (${thresholdX.toInt()}, ${thresholdY.toInt()})',
      );

      return isCentered;
    } catch (e) {
      print('❌ Error in face centering check: $e');
      _isFaceOrientationCentered = false;
      return false;
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

      // Platform-specific rotation handling
      InputImageRotation rotation;
      if (Platform.isIOS) {
        rotation = InputImageRotation.rotation90deg; // iOS camera is rotated
      } else {
        rotation = InputImageRotation.rotation0deg; // Try 0 degrees for Android
      }

      // iOS-specific format handling
      InputImageFormat format;
      if (Platform.isIOS) {
        format = InputImageFormat.bgra8888; // iOS uses BGRA format
      } else {
        format = InputImageFormat.nv21; // Android uses NV21 format
      }

      final metadata = InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow ?? image.width,
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
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow ?? image.width,
      );
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
      cropped = imglib.flipHorizontal(cropped);
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
        // Android YUV420 format - keep existing working code
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
    // Keep the original Android working code
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
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 20.w,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: isRetryFinished ? _restartVerification : null,
                      child: Column(
                        children: [
                          if (!isRetryFinished)
                            Pulse(
                              child: SvgPicture.asset(
                                "assets/svg/ic_face.svg",
                                width: 80.w,
                                height: 80.w,
                              ),
                            ),
                          if (isRetryFinished) ...[
                            SvgPicture.asset(
                              "assets/svg/ic_syncing.svg",
                              width: 80.w,
                              height: 80.w,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "click_here_to_repeat".tr(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: IgnorePointer(
                      child: CircularSeekBar(
                        width: 360.w,
                        height: 360.w,
                        trackColor: Colors.grey,
                        progress: _progress,
                        barWidth: 8,
                        startAngle: 0,
                        sweepAngle: 360,
                        strokeCap: StrokeCap.butt,
                        progressColor: Colors.green,
                        innerThumbRadius: 0,
                        innerThumbStrokeWidth: 0,
                        innerThumbColor: Colors.white,
                        outerThumbRadius: 0,
                        outerThumbStrokeWidth: 0,
                        outerThumbColor: Colors.blueAccent,
                        dashWidth: 1,
                        dashGap: 2,
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: ClipOval(
                            child: Container(
                              width: 340.w,
                              height: 340.w,
                              color: _isFaceOrientationCentered
                                  ? Colors.green
                                  : Colors.red,
                              child: Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: SizedBox(
                        width: 320.w,
                        height: 320.w,
                        child: isRetryFinished
                            ? Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 60.w,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : _controller != null &&
                                  _controller!.value.isInitialized
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
      ),
    );
  }
}
