// Purpose: Liveness Video Recording Screen
// Author: Auto-generated
// Linked Spec Section: KYC Liveness Detection

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../../core/services/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LivenessVideoView extends StatefulWidget {
  const LivenessVideoView({super.key});

  @override
  State<LivenessVideoView> createState() => _LivenessVideoViewState();
}

class _LivenessVideoViewState extends State<LivenessVideoView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isFlashOn = false;
  String? _videoPath;
  int _recordingDuration = 0;
  int _maxDuration = 10; // Maximum 10 seconds

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitializeCamera();
  }

  Future<void> _requestPermissionsAndInitializeCamera() async {
    try {
      // Use permission service to request necessary permissions
      final permissionService = Get.find<PermissionService>();
      final permissionsGranted = await permissionService.requestKycPermissions();
      
      if (!permissionsGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('camera_storage_video_permissions'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Initialize camera after permissions are granted
      await _initializeCamera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('permission_error'.tr + ': ' + e.toString())),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera for liveness
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: true, // Enable audio for video
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_initializing_camera'.tr + ': $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Start timer
      _startTimer();

      // Auto-stop after max duration
      Future.delayed(Duration(seconds: _maxDuration), () {
        if (_isRecording) {
          _stopRecording();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error_starting_recording'.tr + ': $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });

      // Return video path to previous screen
      if (mounted) {
        Navigator.of(context).pop({'videoPath': _videoPath});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error_stopping_recording'.tr + ': $e')));
      }
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration++;
        });
        if (_recordingDuration >= _maxDuration) {
          _stopRecording();
          return false;
        }
        return true;
      }
      return false;
    });
  }

  void _toggleFlash() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera preview
          if (_isInitialized && _controller != null)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            Positioned.fill(
              child: Container(
                color: AppColors.backgroundLightGray,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),

          // Header and controls overlay
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'liveness_check'.tr,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isRecording
                                    ? 'recording_follow_instructions'.tr
                                    : 'record_short_video'.tr,
                                style: AppTextStyles.bodyMedium(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Flash icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: AppColors.black,
                              size: 20,
                            ),
                            onPressed: _toggleFlash,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Instructions overlay
                  if (!_isRecording)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Instructions',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Look directly at the camera\n'
                            '• Smile naturally\n'
                            '• Turn your head slowly left and right\n'
                            '• Blink your eyes a few times\n'
                            '• Video will auto-stop after 10 seconds',
                            style: AppTextStyles.bodySmall(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Recording timer
                  if (_isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recording ${_maxDuration - _recordingDuration}s',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isRecording)
                          // Start recording button
                          GestureDetector(
                            onTap: _startRecording,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          )
                        else
                          // Stop recording button
                          GestureDetector(
                            onTap: _stopRecording,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
