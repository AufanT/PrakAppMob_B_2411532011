import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/transaction_item.dart';
import 'services/auth_service.dart';
import 'transaction_detail_screen.dart';
import 'utils/formatters.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionItem> _daftarRiwayat = [];
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatRiwayat();
  }

  Future<void> _muatRiwayat() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final List<TransactionItem> data =
        await DatabaseHelper.instance.getTransactions(user.id!);
    if (!mounted) return;
    setState(() {
      _daftarRiwayat = data;
      _sedangMemuat = false;
    });
  }

  Future<void> _bukaDetail(TransactionItem item) async {
    final bool berubah = await TransactionDetailScreen.open(context, item);
    if (berubah) _muatRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_sedangMemuat) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (_daftarRiwayat.isEmpty) {
      return RefreshIndicator(
        onRefresh: _muatRiwayat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Belum ada riwayat transaksi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _muatRiwayat,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _daftarRiwayat.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final TransactionItem item = _daftarRiwayat[index];
          final Color warna = item.isPengeluaran ? Colors.red : Colors.green;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  item.isPengeluaran ? Colors.red[50] : Colors.green[50],
              child: Icon(item.icon, color: warna),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${formatTanggalPendek(item.date)} • ${item.category}'),
            trailing: Text(
              formatRupiahBertanda(item.amount, item.isPengeluaran),
              style: TextStyle(color: warna, fontWeight: FontWeight.bold),
            ),
            onTap: () => _bukaDetail(item),
          );
        },
      ),
    );
  }
}
