import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasil UI Widgets',
      home: const WidgetsDemoPage(),
    );
  }
}

class WidgetsDemoPage extends StatelessWidget {
  const WidgetsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------- APPBAR ----------------
      appBar: AppBar(
        title: const Text('Judul Aplikasi'),
        backgroundColor: Colors.blue,
        leading: const Icon(Icons.menu),
        actions: const [Icon(Icons.search), SizedBox(width: 12)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- TEXT ----------------
            const SizedBox(height: 20),
            const Text(
              'Teks ini tebal dan berwarna merah!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Teks ini miring dan rata tengah.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
            ),

            // ---------------- IMAGE ----------------
            // CATATAN: ukuran diperkecil (150x150, dari 200/250 di
            // snippet asli) supaya kedua gambar muat rapi berdampingan
            // dalam satu layar yang di-scroll. Kalau kamu tidak siapkan
            // assets/images/flutter_logo.png, hapus blok Image.asset ini.
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/flutter_logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 150,
                  height: 150,
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.network(
                'https://picsum.photos/700',
                width: 150,
                height: 150,
              ),
            ),

            // ---------------- ICON ----------------
            const SizedBox(height: 20),
            const Center(
              child: Icon(Icons.favorite, color: Colors.pink, size: 50.0),
            ),

            // ---------------- ELEVATED BUTTON ----------------
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // ignore: avoid_print
                  print('Tombol dengan gaya kustom ditekan!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Tombol Kustom'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
