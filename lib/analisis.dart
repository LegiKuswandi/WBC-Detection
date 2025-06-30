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
      return '''
Tidak ada Wereng Batang Coklat (WBC) terdeteksi.
Lakukan monitoring rutin setiap minggu, mulai sejak masa pembibitan.

Rekomendasi Pencegahan (Tindakan Preventif):
1. Tanaman:
   - Gunakan varietas tahan WBC seperti Inpari 33 atau Inpari 47.
   - Lakukan rotasi tanaman dan pergiliran varietas antar musim tanam.
2. Pupuk dan tanah:
   - Berikan pupuk secara berimbang sesuai hasil uji tanah atau peta status hara.
3. Lingkungan:
   - Terapkan sistem pengairan basah-kering dan jaga sanitasi lahan.
4. Aspek sosial:
   - Laksanakan tanam serempak di satu hamparan dengan perbedaan waktu maksimal 7–14 hari antar petani.
''';
    } else if (count < 5) {
      return '''
Populasi WBC rendah ($count ekor per gambar).
Lakukan pemantauan rutin setiap minggu.

Pengendalian yang disarankan:
- Gunakan musuh alami seperti agensia hayati Beauveria bassiana, Metarhizium sp., atau Hirsutella sp.
- Lakukan penyemprotan secara merata dan serempak dalam satu hamparan pertanaman.
''';
    } else if (count >= 5 && count < 10) {
      return '''
Populasi WBC sedang ($count ekor per gambar).
Lakukan pengendalian untuk mencegah peningkatan populasi.

Pengendalian yang disarankan:
- Gunakan insektisida sistemik berbahan aktif pymetrozin atau triflumezopyrim.
- Jika wereng masih berupa nimfa, gunakan insektisida berbahan aktif buprofezin.
- Lakukan penyemprotan secara serempak dalam satu hamparan.
''';
    } else {
      return '''
Populasi WBC tinggi ($count ekor per gambar).
Pengendalian intensif harus segera dilakukan untuk mencegah kerusakan parah.

Pengendalian yang disarankan:
- Gunakan insektisida sistemik seperti pymetrozin atau triflumezopyrim.
- Gunakan insektisida kontak seperti dinotefuran.
- Jika wereng masih berupa nimfa, gunakan insektisida berbahan aktif buprofezin.
- Lakukan penyemprotan serempak dalam satu hamparan.
- Jika sudah terjadi hopper burn, pertimbangkan untuk melakukan panen lebih awal (eradikasi).
''';
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
              const Text(
                "Hasil Deteksi",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                textAlign: TextAlign.left,
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
