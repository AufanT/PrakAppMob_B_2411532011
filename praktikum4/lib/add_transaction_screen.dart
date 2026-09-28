import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(); // TUGAS: controller tanggal

  // Batas tanggal yang bisa dipilih
  final DateTime _firstDate = DateTime(2000);
  final DateTime _lastDate = DateTime(2100);

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Mengubah DateTime menjadi teks DD/MM/YYYY
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  // Mengubah teks DD/MM/YYYY menjadi DateTime (null jika tidak valid)
  DateTime? _parseDate(String input) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(input);
    if (match == null) return null;

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);

    // Menolak tanggal yang tidak ada, misalnya 31/02/2026
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  // Validasi: wajib diisi + format benar
  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Tanggal wajib diisi";
    }
    final date = _parseDate(value.trim());
    if (date == null) {
      return "Format tanggal harus DD/MM/YYYY";
    }
    if (date.isBefore(_firstDate) || date.isAfter(_lastDate)) {
      return "Tanggal di luar rentang yang diizinkan";
    }
    return null;
  }

  // TUGAS (PLUS): memilih tanggal dengan showDatePicker
  Future<void> _pickDate() async {
    final current = _parseDate(_dateController.text.trim());
    final bool currentValid = current != null &&
        !current.isBefore(_firstDate) &&
        !current.isAfter(_lastDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentValid ? current : DateTime.now(),
      firstDate: _firstDate,
      lastDate: _lastDate,
    );

    if (picked != null) {
      _dateController.text = _formatDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catat Transaksi"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nominal", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              // TUGAS: Input Tanggal Transaksi
              TextFormField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: "Tanggal Transaksi",
                  hintText: "DD/MM/YYYY",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip: "Pilih tanggal",
                    onPressed: _pickDate,
                  ),
                ),
                validator: _validateDate,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaksi Berhasil Disimpan!'), backgroundColor: Colors.green),
                    );
                    // NAVIGASI POP: Kembali ke halaman sebelumnya (Dashboard)
                    Navigator.pop(context);
                  }
                },
                child: const Text("Simpan", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}