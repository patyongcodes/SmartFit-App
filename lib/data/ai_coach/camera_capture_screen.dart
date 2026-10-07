import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCapturing = false;
  int? _countdown;
  Timer? _countdownTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _errorMessage = 'No camera found on this device.');
        return;
      }
      _selectedCameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
      await _startController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() => _errorMessage = 'Could not access the camera. Please check camera permissions.');
    }
  }

  Future<void> _startController(CameraDescription description) async {
    final controller = CameraController(description, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final oldController = _controller;
    setState(() => _controller = null);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await oldController?.dispose();
    await _startController(_cameras[_selectedCameraIndex]);
  }

  void _startCountdownAndCapture() {
    if (_controller == null || _isCapturing || _countdown != null) return;
    setState(() => _countdown = 3);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == null) return;
      if (_countdown! <= 1) {
        timer.cancel();
        setState(() => _countdown = null);
        _capturePhoto();
      } else {
        setState(() => _countdown = _countdown! - 1);
      }
    });
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      Navigator.pop<Uint8List>(context, bytes);
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to capture photo. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isReady)
            CameraPreview(controller)
          else
            Center(
              child: _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          if (isReady)
            const IgnorePointer(
              child: CustomPaint(size: Size.infinite, painter: _BodyGuidePainter()),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                    if (_cameras.length > 1)
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 26),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_countdown != null)
            Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(color: Colors.white, fontSize: 96, fontWeight: FontWeight.bold),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Stand inside the outline, full body visible', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _startCountdownAndCapture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: _isCapturing
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Container(
                                margin: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyGuidePainter extends CustomPainter {
  const _BodyGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final centerX = size.width / 2;
    final top = size.height * 0.12;
    final bottom = size.height * 0.92;
    final headRadius = size.width * 0.09;
    final headCenterY = top + headRadius;

    canvas.drawCircle(Offset(centerX, headCenterY), headRadius, paint);

    final shoulderY = headCenterY + headRadius + size.height * 0.03;
    final hipY = shoulderY + (bottom - shoulderY) * 0.42;
    final shoulderWidth = size.width * 0.28;
    final hipWidth = size.width * 0.20;
    final ankleWidth = size.width * 0.14;

    final path = Path()
      ..moveTo(centerX - shoulderWidth / 2, shoulderY)
      ..lineTo(centerX + shoulderWidth / 2, shoulderY)
      ..lineTo(centerX + hipWidth / 2, hipY)
      ..lineTo(centerX + ankleWidth / 2, bottom)
      ..moveTo(centerX - shoulderWidth / 2, shoulderY)
      ..lineTo(centerX - hipWidth / 2, hipY)
      ..lineTo(centerX - ankleWidth / 2, bottom);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}