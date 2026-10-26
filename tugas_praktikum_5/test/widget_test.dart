import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_praktikum_5/utils/formatters.dart';

void main() {
  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(5000000), 'Rp 5.000.000');
    expect(formatRupiah(500), 'Rp 500');
    expect(formatRupiah(-50000), '- Rp 50.000');
  });

  test('formatRupiahBertanda memberi tanda sesuai jenis', () {
    expect(formatRupiahBertanda(50000, true), '- Rp 50.000');
    expect(formatRupiahBertanda(50000, false), '+ Rp 50.000');
  });

  test('format tanggal', () {
    final tanggal = DateTime(2026, 9, 3);
    expect(formatTanggalPanjang(tanggal), '3 September 2026');
    expect(formatTanggalPendek(tanggal), '03 Sep 2026');
    expect(formatTanggalDatabase(tanggal), '2026-09-03');
  });
}
