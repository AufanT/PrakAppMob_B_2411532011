import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/transaction_item.dart';
import 'services/auth_service.dart';
import 'transaction_detail_screen.dart';
import 'utils/formatters.dart';
import 'widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _saldo = 0;
  List<TransactionItem> _transaksiTerakhir = [];
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final int saldo = await DatabaseHelper.instance.getSaldo(user.id!);
    final List<TransactionItem> transaksi =
        await DatabaseHelper.instance.getTransactions(user.id!, limit: 5);
    if (!mounted) return;
    setState(() {
      _saldo = saldo;
      _transaksiTerakhir = transaksi;
      _sedangMemuat = false;
    });
  }

  Future<void> _bukaFormTransaksi([Map<String, String>? preset]) async {
    // Memanggil Rute yang sudah didaftarkan di main.dart
    final result = await Navigator.pushNamed(context, '/add', arguments: preset);
    if (result == true) _muatData();
  }

  Future<void> _bukaDetail(TransactionItem item) async {
    final bool berubah = await TransactionDetailScreen.open(context, item);
    if (berubah) _muatData();
  }

  @override
  Widget build(BuildContext context) {
    final String nama = AuthService.instance.currentUser?.name ?? 'Pengguna';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      // Tombol mengambang (FAB) untuk tambah transaksi
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _bukaFormTransaksi(),
      ),
      body: RefreshIndicator(
        onRefresh: _muatData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingWidget(name: nama),
              const SizedBox(height: 20),
              BalanceCardWidget(saldo: _saldo),
              const SizedBox(height: 20),
              ActionButtonsWidget(
                onPemasukan: () => _bukaFormTransaksi(
                  {'type': TransactionItem.tipePemasukan},
                ),
                onPengeluaran: () => _bukaFormTransaksi(
                  {'type': TransactionItem.tipePengeluaran},
                ),
                onTransfer: () => _bukaFormTransaksi(
                  {'type': TransactionItem.tipePengeluaran, 'category': 'Transfer'},
                ),
              ),
              const SizedBox(height: 20),
              const Text('Transaksi Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_sedangMemuat) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_transaksiTerakhir.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Belum ada transaksi.\nTekan tombol + untuk mencatat transaksi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final List<Widget> daftar = [];
    for (int i = 0; i < _transaksiTerakhir.length; i++) {
      final TransactionItem item = _transaksiTerakhir[i];
      if (i > 0) daftar.add(const Divider(height: 1));
      daftar.add(
        ListTile(
          leading: CircleAvatar(backgroundColor: item.color, child: Icon(item.icon, color: Colors.white)),
          title: Text(item.title),
          subtitle: Text(formatTanggalPendek(item.date)),
          trailing: Text(
            formatRupiahBertanda(item.amount, item.isPengeluaran),
            style: TextStyle(
              color: item.isPengeluaran ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _bukaDetail(item),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(children: daftar),
    );
  }
}
