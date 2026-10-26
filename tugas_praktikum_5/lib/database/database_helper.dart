import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/app_user.dart';
import '../models/transaction_item.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _namaDatabase = 'expense_tracker.db';
  static const int _versiDatabase = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _bukaDatabase();
    return _database!;
  }

  Future<Database> _bukaDatabase() async {
    final String lokasi = join(await getDatabasesPath(), _namaDatabase);
    return openDatabase(
      lokasi,
      version: _versiDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _buatTabel,
    );
  }

  Future<void> _buatTabel(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertUser(AppUser user) async {
    final Database db = await database;
    return db.insert('users', user.toMap());
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<int> insertTransaction(TransactionItem item) async {
    final Database db = await database;
    return db.insert('transactions', {
      ...item.toMap(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<TransactionItem>> getTransactions(int userId, {int? limit}) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map(TransactionItem.fromMap).toList();
  }

  Future<int> getSaldo(int userId) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COALESCE(SUM(CASE WHEN type = ? THEN amount ELSE -amount END), 0) AS saldo '
      'FROM transactions WHERE user_id = ?',
      [TransactionItem.tipePemasukan, userId],
    );
    return (rows.first['saldo'] as num?)?.toInt() ?? 0;
  }

  Future<int> deleteTransaction(int id, int userId) async {
    final Database db = await database;
    return db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}
