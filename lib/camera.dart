import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'analisis.dart';
import '../helper/image_detection_helper.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;

  final ImageDetectionHelper _detectionHelper = ImageDetectionHelper();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _detectionHelper.initHelper();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detectionHelper.close();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();
        final decoded = img.decodeImage(bytes);

        if (decoded != null) {
          final results = await _detectionHelper.inferenceImage(decoded);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisResultPage(
                imageBytes: bytes,
                results: results,
              ),
            ),
          );
        }
      } catch (e) {
        print("Gagal mengambil gambar: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cameraSize = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "Arahkan ke objek",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: cameraSize,
                    height: cameraSize,
                    color: Colors.black,
                    child: _controller != null && _controller!.value.isInitialized
                        ? CameraPreview(_controller!)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _analyzeImage,
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Lakukan Analisis",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
