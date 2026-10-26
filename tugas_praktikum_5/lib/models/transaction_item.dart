import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class TransactionItem {
  static const String tipePemasukan = 'pemasukan';
  static const String tipePengeluaran = 'pengeluaran';

  static const List<String> kategoriPengeluaran = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Belanja',
    'Transfer',
    'Lainnya',
  ];

  static const List<String> kategoriPemasukan = [
    'Gaji',
    'Freelance',
    'Bonus',
    'Transfer',
    'Lainnya',
  ];

  static List<String> kategoriUntuk(String tipe) {
    return tipe == tipePemasukan ? kategoriPemasukan : kategoriPengeluaran;
  }

  final int? id;
  final int userId;
  final String title;
  final int amount;
  final String type;
  final String category;
  final DateTime date;

  const TransactionItem({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isPengeluaran => type == tipePengeluaran;

  String get jenisLabel => isPengeluaran ? 'Pengeluaran' : 'Pemasukan';

  IconData get icon {
    switch (category) {
      case 'Makanan':
        return Icons.fastfood;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Hiburan':
        return Icons.movie;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Gaji':
        return Icons.attach_money;
      case 'Freelance':
        return Icons.laptop;
      case 'Bonus':
        return Icons.card_giftcard;
      case 'Transfer':
        return Icons.swap_horiz;
      default:
        return Icons.receipt_long;
    }
  }

  Color get color {
    switch (category) {
      case 'Makanan':
        return Colors.orange;
      case 'Transportasi':
        return Colors.blueAccent;
      case 'Hiburan':
        return Colors.purple;
      case 'Belanja':
        return Colors.deepOrange;
      case 'Gaji':
      case 'Bonus':
        return Colors.green;
      case 'Freelance':
        return Colors.teal;
      case 'Transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': formatTanggalDatabase(date),
    };
  }

  factory TransactionItem.fromMap(Map<String, Object?> map) {
    return TransactionItem(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      amount: map['amount'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
