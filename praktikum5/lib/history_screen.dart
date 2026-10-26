import 'package:flutter/material.dart';

class _RiwayatItem {
  final String judul;
  final String tanggal;
  final int nominal;
  final bool pengeluaran;
  final IconData ikon;

  const _RiwayatItem({
    required this.judul,
    required this.tanggal,
    required this.nominal,
    required this.pengeluaran,
    required this.ikon,
  });
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const List<_RiwayatItem> _daftarRiwayat = [
    _RiwayatItem(
      judul: 'Makan Siang',
      tanggal: '26 Okt 2026',
      nominal: 50000,
      pengeluaran: true,
      ikon: Icons.restaurant,
    ),
    _RiwayatItem(
      judul: 'Gaji Bulanan',
      tanggal: '25 Okt 2026',
      nominal: 5000000,
      pengeluaran: false,
      ikon: Icons.account_balance_wallet,
    ),
    _RiwayatItem(
      judul: 'Transportasi',
      tanggal: '24 Okt 2026',
      nominal: 25000,
      pengeluaran: true,
      ikon: Icons.directions_car,
    ),
    _RiwayatItem(
      judul: 'Belanja Bulanan',
      tanggal: '23 Okt 2026',
      nominal: 350000,
      pengeluaran: true,
      ikon: Icons.shopping_cart,
    ),
    _RiwayatItem(
      judul: 'Transfer Masuk',
      tanggal: '22 Okt 2026',
      nominal: 200000,
      pengeluaran: false,
      ikon: Icons.swap_horiz,
    ),
  ];

  String _formatRupiah(int nominal) {
    final String angka = nominal.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return 'Rp $angka';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _daftarRiwayat.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final _RiwayatItem item = _daftarRiwayat[index];
          final Color warna = item.pengeluaran ? Colors.red : Colors.green;
          final String tanda = item.pengeluaran ? '-' : '+';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  item.pengeluaran ? Colors.red[50] : Colors.green[50],
              child: Icon(item.ikon, color: warna),
            ),
            title: Text(
              item.judul,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item.tanggal),
            trailing: Text(
              '$tanda ${_formatRupiah(item.nominal)}',
              style: TextStyle(color: warna, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}