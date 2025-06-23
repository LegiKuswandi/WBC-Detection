import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../helper/image_detection_helper.dart';
import 'homepage.dart';

class AnalysisResultPage extends StatelessWidget {
  final Uint8List imageBytes;
  final List<DetectionResult> results;

  const AnalysisResultPage({
    super.key,
    required this.imageBytes,
    required this.results,
  });

  String _generateRecommendation(int count) {
    if (count == 0) {
      return "Tidak ada WBC terdeteksi.\nLakukan monitoring rutin tiap minggu.";
    } else if (count < 5) {
      return "Populasi rendah ($count ekor).\nGunakan musuh alami seperti Beauveria bassiana atau Metarhizium sp.";
    } else if (count >= 5 && count < 10) {
      return "Populasi sedang ($count ekor).\nGunakan insektisida sistemik berbahan pymetrozin atau triflumezopyrim.";
    } else {
      return "Populasi tinggi ($count ekor).\nGunakan insektisida sistemik atau kontak seperti dinotefuran.\nJika masih nimfa, gunakan buprofezin.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final int wbcCount = results.length;
    final recommendation = _generateRecommendation(wbcCount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Hasil Deteksi",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "$wbcCount objek WBC terdeteksi",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                recommendation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Selesai",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
