import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/database_helper.dart';
import 'models/transaction_item.dart';
import 'services/auth_service.dart';

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

  // Dari Modul 3: jenis dan kategori transaksi
  String _selectedType = TransactionItem.tipePengeluaran;
  String _selectedCategory = TransactionItem.kategoriPengeluaran.first;
  bool _argumenSudahDibaca = false;
  bool _sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumenSudahDibaca) return;
    _argumenSudahDibaca = true;

    // Membaca preset dari tombol Pemasukan / Pengeluaran / Transfer di Dashboard
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, String>) {
      final String? tipe = args['type'];
      if (tipe == TransactionItem.tipePemasukan ||
          tipe == TransactionItem.tipePengeluaran) {
        _selectedType = tipe!;
      }
      final List<String> kategori = TransactionItem.kategoriUntuk(_selectedType);
      final String? kategoriPreset = args['category'];
      _selectedCategory = (kategoriPreset != null && kategori.contains(kategoriPreset))
          ? kategoriPreset
          : kategori.first;
    }
  }

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

  // Menyimpan transaksi ke database SQLite
  Future<void> _simpanTransaksi() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService.instance.currentUser;
    if (user == null) return;

    setState(() => _sedangMenyimpan = true);
    final TransactionItem item = TransactionItem(
      userId: user.id!,
      title: _titleController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      type: _selectedType,
      category: _selectedCategory,
      date: _parseDate(_dateController.text.trim())!,
    );

    try {
      await DatabaseHelper.instance.insertTransaction(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi Berhasil Disimpan!'), backgroundColor: Colors.green),
      );
      // NAVIGASI POP: Kembali ke halaman sebelumnya (Dashboard)
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sedangMenyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> kategori = TransactionItem.kategoriUntuk(_selectedType);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catat Transaksi"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "Nominal", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tidak boleh kosong";
                  }
                  final int? nominal = int.tryParse(value);
                  if (nominal == null) {
                    return "Harus berupa angka bulat yang valid";
                  }
                  if (nominal <= 0) {
                    return "Nominal harus lebih dari 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Jenis transaksi: menentukan saldo bertambah atau berkurang
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: "Jenis Transaksi", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: TransactionItem.tipePengeluaran,
                    child: Text('Pengeluaran'),
                  ),
                  DropdownMenuItem(
                    value: TransactionItem.tipePemasukan,
                    child: Text('Pemasukan'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedType = value;
                    final List<String> kategoriBaru = TransactionItem.kategoriUntuk(value);
                    if (!kategoriBaru.contains(_selectedCategory)) {
                      _selectedCategory = kategoriBaru.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // Dari Modul 3: Kategori Dropdown
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedType),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori", border: OutlineInputBorder()),
                items: kategori.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
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
                onPressed: _sedangMenyimpan ? null : _simpanTransaksi,
                child: const Text("Simpan", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
