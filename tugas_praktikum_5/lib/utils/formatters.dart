const List<String> _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatRupiah(int nominal) {
  final String angka = nominal.abs().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
  return nominal < 0 ? '- Rp $angka' : 'Rp $angka';
}

String formatRupiahBertanda(int nominal, bool pengeluaran) {
  return '${pengeluaran ? '-' : '+'} ${formatRupiah(nominal)}';
}

String formatTanggalPanjang(DateTime tanggal) {
  return '${tanggal.day} ${_namaBulan[tanggal.month - 1]} ${tanggal.year}';
}

String formatTanggalPendek(DateTime tanggal) {
  final String hari = tanggal.day.toString().padLeft(2, '0');
  final String bulan = _namaBulan[tanggal.month - 1].substring(0, 3);
  return '$hari $bulan ${tanggal.year}';
}

String formatTanggalDatabase(DateTime tanggal) {
  final String bulan = tanggal.month.toString().padLeft(2, '0');
  final String hari = tanggal.day.toString().padLeft(2, '0');
  return '${tanggal.year}-$bulan-$hari';
}
