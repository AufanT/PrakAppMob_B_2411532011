import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/transaction_item.dart';
import 'services/auth_service.dart';
import 'utils/formatters.dart';

class TransactionDetailScreen extends StatelessWidget {
  // Deklarasi variabel penampung data (harus final karena StatelessWidget)
  final String title;
  final String amount;
  final String category;
  final String date;
  final int? id;
  final String jenis;
  final bool isPengeluaran;

  // Constructor yang mewajibkan pengisian data (required)
  const TransactionDetailScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.id,
    this.jenis = 'Pengeluaran',
    this.isPengeluaran = true,
  });

  // Membuka halaman detail dengan passing data via constructor.
  // Mengembalikan true jika transaksi dihapus.
  static Future<bool> open(BuildContext context, TransactionItem item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          id: item.id,
          title: item.title,
          amount: formatRupiahBertanda(item.amount, item.isPengeluaran),
          category: item.category,
          date: formatTanggalPanjang(item.date),
          jenis: item.jenisLabel,
          isPengeluaran: item.isPengeluaran,
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _konfirmasiHapus(BuildContext context) async {
    final bool? yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yakin != true || id == null) return;

    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await DatabaseHelper.instance.deleteTransaction(id!, user.id!);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi dihapus')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (id != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus transaksi',
              onPressed: () => _konfirmasiHapus(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPengeluaran ? Colors.red : Colors.green,
              ),
            ),
            const Divider(height: 40, thickness: 2),
            _buildDetailRow('Jenis', jenis),
            const SizedBox(height: 16),
            _buildDetailRow('Kategori', category),
            const SizedBox(height: 16),
            _buildDetailRow('Tanggal', date),
            const SizedBox(height: 16),
            _buildDetailRow('Status', 'Berhasil'),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk merapikan layout baris detail
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
