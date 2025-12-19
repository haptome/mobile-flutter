// Purpose: ID Card Camera Capture Screen
// Author: Auto-generated
// Linked Spec Section: Verification - ID Card Capture

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'id_card_confirmation_view.dart';

class IdCardCameraView extends StatefulWidget {
  final String verificationMethod;

  const IdCardCameraView({
    super.key,
    required this.verificationMethod,
  });

  @override
  State<IdCardCameraView> createState() => _IdCardCameraViewState();
}

class _IdCardCameraViewState extends State<IdCardCameraView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
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
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        // Navigate to confirmation screen
        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (_) => IdCardConfirmationView(
              imagePath: image.path,
              verificationMethod: widget.verificationMethod,
            ),
          ),
        );
        
        // Return result to previous screen
        if (mounted && result != null) {
          Navigator.of(context).pop(result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (_) => IdCardConfirmationView(
              imagePath: image.path,
              verificationMethod: widget.verificationMethod,
            ),
          ),
        );
        
        // Return result to previous screen
        if (mounted && result != null) {
          Navigator.of(context).pop(result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _toggleFlash() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final frameWidth = 342.0;
    final frameHeight = 305.0;
    final frameRadius = 32.0;
    
    // Calculate frame position (centered in available space)
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;
    final frameLeft = safeArea.left + (availableWidth - frameWidth) / 2;
    final frameTop = safeArea.top + (availableHeight - frameHeight) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera preview
          if (_isInitialized && _controller != null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            Positioned.fill(
              child: Container(
                color: AppColors.backgroundLightGray,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          
          // Blurred background overlay (everything except the frame)
          Positioned.fill(
            child: ClipPath(
              clipper: _FrameClipper(
                frameLeft: frameLeft,
                frameTop: frameTop,
                frameWidth: frameWidth,
                frameHeight: frameHeight,
                frameRadius: frameRadius,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Frame border overlay
          Positioned(
            left: frameLeft,
            top: frameTop,
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(frameRadius),
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
              ),
            ),
          ),
          
          // Header and controls overlay
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                'Photo ID Card',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please point the camera at the ID card',
                                style: AppTextStyles.bodyMedium(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action icons row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Refresh/Redo icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: AppColors.black,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Refresh camera
                                  _initializeCamera();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // History/Clock icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.history,
                                  color: AppColors.black,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Show history (placeholder)
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
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
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Capture button (large circular button with yellow fill and dark border)
                        GestureDetector(
                          onTap: _captureImage,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade800,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Upload from gallery button
                        GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.upload_file,
                              color: AppColors.black,
                              size: 28,
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

// Custom clipper to create a hole in the overlay for the frame
class _FrameClipper extends CustomClipper<Path> {
  final double frameLeft;
  final double frameTop;
  final double frameWidth;
  final double frameHeight;
  final double frameRadius;

  _FrameClipper({
    required this.frameLeft,
    required this.frameTop,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Create rounded rectangle hole for the frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        frameLeft,
        frameTop,
        frameWidth,
        frameHeight,
      ),
      Radius.circular(frameRadius),
    );
    
    // Subtract the frame area from the path
    final framePath = Path()
      ..addRRect(frameRect);
    
    return Path.combine(
      PathOperation.difference,
      path,
      framePath,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

