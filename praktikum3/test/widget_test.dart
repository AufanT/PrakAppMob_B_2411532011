// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum3/main.dart';

void main() {
  testWidgets('AddTransactionScreen form validation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify fields exist
    expect(find.text('Catat Transaksi Baru'), findsOneWidget);
    expect(find.text('Judul Transaksi'), findsOneWidget);
    expect(find.text('Nominal (Rp)'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Tanggal Transaksi'), findsOneWidget);
    expect(find.text('Simpan Transaksi'), findsOneWidget);

    // Tap 'Simpan Transaksi' without filling to trigger validation
    await tester.tap(find.text('Simpan Transaksi'));
    await tester.pump();

    // Verify validation errors appear
    expect(find.text('Judul transaksi tidak boleh kosong'), findsOneWidget);
    expect(find.text('Nominal wajib diisi'), findsOneWidget);
    expect(find.text('Tanggal transaksi wajib diisi'), findsOneWidget);
  });

  testWidgets('Selecting date via showDatePicker populates DD/MM/YYYY', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap on the date picker icon / field
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    // Verify date picker dialog is shown (it has 'OK' button)
    expect(find.text('OK'), findsOneWidget);

    // Tap 'OK' to select current date
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify the date field is no longer empty
    final now = DateTime.now();
    final expectedDate =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    expect(find.text(expectedDate), findsOneWidget);
  });
}
