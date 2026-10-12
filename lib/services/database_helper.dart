import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../core/default_categories.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mizan_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // 3. Monthly Budgets Table
    await db.execute('''
      CREATE TABLE monthly_budgets (
        month_year TEXT PRIMARY KEY,
        budget_amount REAL NOT NULL DEFAULT 0.0
      )
    ''');

    // Seed default categories
    for (final category in DefaultCategories.categories) {
      await db.insert('categories', category.toMap());
    }
  }

  // --- Transactions Operations ---

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionModel>> getTransactionsByMonth(String monthYear) async {
    final db = await instance.database;
    // monthYear is in format 'YYYY-MM', e.g. '2026-10'
    final result = await db.rawQuery('''
      SELECT 
        t.id,
        t.title,
        t.amount,
        t.type,
        t.category_id,
        t.date,
        t.note,
        c.name AS category_name,
        c.icon_code AS category_icon_code,
        c.color_value AS category_color_value
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE strftime('%Y-%m', t.date) = ?
      ORDER BY t.date DESC, t.id DESC
    ''', [monthYear]);

    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // --- Monthly Budgets Operations ---

  Future<void> setMonthlyBudget(String monthYear, double amount) async {
    final db = await instance.database;
    await db.insert(
      'monthly_budgets',
      {
        'month_year': monthYear,
        'budget_amount': amount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> getMonthlyBudget(String monthYear) async {
    final db = await instance.database;
    final result = await db.query(
      'monthly_budgets',
      columns: ['budget_amount'],
      where: 'month_year = ?',
      whereArgs: [monthYear],
    );

    if (result.isNotEmpty) {
      return (result.first['budget_amount'] as num).toDouble();
    }
    return 0.0;
  }

  // --- Categories Operations ---

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'id ASC');
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  // --- Backup & Restore Operations ---

  Future<Map<String, dynamic>> getAllDataForBackup() async {
    final db = await instance.database;
    final categories = await db.query('categories');
    final transactions = await db.query('transactions');
    final budgets = await db.query('monthly_budgets');

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'categories': categories,
      'transactions': transactions,
      'monthly_budgets': budgets,
    };
  }

  Future<void> restoreBackupData(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('monthly_budgets');
      await txn.delete('categories');

      final categories = (data['categories'] as List?) ?? [];
      for (final cat in categories) {
        await txn.insert('categories', Map<String, dynamic>.from(cat));
      }

      final transactions = (data['transactions'] as List?) ?? [];
      for (final tx in transactions) {
        await txn.insert('transactions', Map<String, dynamic>.from(tx));
      }

      final budgets = (data['monthly_budgets'] as List?) ?? [];
      for (final b in budgets) {
        await txn.insert('monthly_budgets', Map<String, dynamic>.from(b));
      }
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
