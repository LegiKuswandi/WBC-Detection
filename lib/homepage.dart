import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'helper/image_detection_helper.dart';
import '../db/db_helper.dart';


class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, this.username = "Legi"});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  img.Image? _image;
  bool _isLoading = false;

  late final ImageDetectionHelper _imageDetectionHelper;

  @override
  void initState() {
    super.initState();
    _imageDetectionHelper = ImageDetectionHelper();
    _imageDetectionHelper.initHelper();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
      });

      final imageData = await _selectedImage!.readAsBytes();
      _image = img.decodeImage(imageData);

      final results = await _imageDetectionHelper.inferenceImage(_image!);
      _isLoading = false;
      setState(() {});

      if (results.isNotEmpty) {
        for (final result in results) {
          final now = DateTime.now().toIso8601String();
          await DBHelper().insertHistory({
            'image_path': _selectedImage!.path,
            'result': result.label,
            'confidence': result.confidence,
            'timestamp': now,
          });
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hasil Deteksi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 120),
                const SizedBox(height: 12),
                ...results.map((e) => Text(
                      "Objek: ${e.label} (${(e.confidence * 100).toStringAsFixed(2)}%)",
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada objek terdeteksi.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _imageDetectionHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/bawahm.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFF008705),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: Image.asset('assets/images/logow.png', height: 100)),
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    'Mulai Deteksi Objek',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        icon: Icons.camera_alt,
                        label: 'Ambil Gambar',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      _actionButton(
                        icon: Icons.upload,
                        label: 'Unggah Gambar',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'Ambil dan unggah gambar wereng batang coklat',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF008705),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
