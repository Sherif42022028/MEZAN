import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../services/backup_service.dart';

class CategorySpending {
  final CategoryModel category;
  final double amount;
  final double percentage;
  final int transactionCount;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

class ExpenseProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  double _monthlyBudget = 0.0;
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  double get monthlyBudget => _monthlyBudget;
  bool get isLoading => _isLoading;

  String get monthYearKey => DateFormat('yyyy-MM').format(_selectedDate);

  String get formattedMonthYear {
    try {
      return DateFormat('MMMM yyyy', 'ar').format(_selectedDate);
    } catch (_) {
      return DateFormat('yyyy-MM').format(_selectedDate);
    }
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return _selectedDate.year == now.year && _selectedDate.month == now.month;
  }

  // --- Calculations ---

  double get totalSpent {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => totalIncome - totalSpent;

  double get remainingBudget => _monthlyBudget - totalSpent;

  /// Number of days left in the selected month
  int get daysLeftInMonth {
    final now = DateTime.now();
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    if (isCurrentMonth) {
      final days = lastDay - now.day + 1;
      return days > 0 ? days : 1;
    } else if (_selectedDate.isBefore(DateTime(now.year, now.month, 1))) {
      return 1; // Month has ended
    } else {
      return lastDay; // Future month
    }
  }

  /// Calculated daily safe spending budget
  double get dailyRemainingAllowance {
    if (_monthlyBudget <= 0 || remainingBudget <= 0) return 0.0;
    return remainingBudget / daysLeftInMonth;
  }

  /// Safe ratio [0.0 - 1.0] for progress bars without division by zero
  double get spendingRatio {
    if (_monthlyBudget <= 0) {
      return totalSpent > 0 ? 1.0 : 0.0;
    }
    final ratio = totalSpent / _monthlyBudget;
    return ratio > 1.0 ? 1.0 : (ratio < 0.0 ? 0.0 : ratio);
  }

  /// Real percentage (e.g. 75.5%)
  double get spendingPercentage {
    if (_monthlyBudget <= 0) return 0.0;
    return (totalSpent / _monthlyBudget) * 100;
  }

  /// Dynamic color depending on spending threshold
  Color get budgetStatusColor {
    if (_monthlyBudget <= 0) return AppTheme.textMuted;
    final ratio = totalSpent / _monthlyBudget;
    if (ratio < 0.75) return AppTheme.greenSafe;
    if (ratio <= 0.90) return AppTheme.goldAccent;
    return AppTheme.redCoral;
  }

  String get budgetStatusMessage {
    if (_monthlyBudget <= 0) {
      return 'اضغط على زر التعديل لتحديد سقف ميزانية هذا الشهر';
    }
    if (remainingBudget < 0) {
      return 'تنبيه: تجاوزت سقف الميزانية المحدد لهذا الشهر!';
    }
    final ratio = totalSpent / _monthlyBudget;
    if (ratio >= 0.90) {
      return 'تحذير: استهلكت أكثر من 90% من الميزانية، اضبط الصرف';
    }
    if (ratio >= 0.75) {
      return 'استهلكت 75% من الميزانية، حافظ على معدلك اليومي';
    }
    return 'وضعك المالي مستقر وممتاز، أنت في النطاق الأخضر';
  }

  /// Spending breakdown grouped by Category
  List<CategorySpending> get categorySpendings {
    if (_transactions.isEmpty || totalSpent == 0) return [];

    final Map<int, double> amounts = {};
    final Map<int, int> counts = {};

    for (final tx in _transactions.where((t) => t.isExpense)) {
      amounts[tx.categoryId] = (amounts[tx.categoryId] ?? 0.0) + tx.amount;
      counts[tx.categoryId] = (counts[tx.categoryId] ?? 0) + 1;
    }

    final List<CategorySpending> list = [];
    final total = totalSpent;

    for (final entry in amounts.entries) {
      final category = _categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(
          id: entry.key,
          name: 'أخرى',
          iconCode: Icons.category.codePoint,
          colorValue: 0xFF94A3B8,
        ),
      );

      final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
      list.add(CategorySpending(
        category: category,
        amount: entry.value,
        percentage: percentage,
        transactionCount: counts[entry.key] ?? 1,
      ));
    }

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  /// Transactions grouped by Human-Friendly Date Header
  Map<String, List<TransactionModel>> get transactionsGroupedByDay {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();

    for (final tx in _transactions) {
      String dateHeader;
      final txDate = tx.date;

      if (txDate.year == now.year && txDate.month == now.month && txDate.day == now.day) {
        dateHeader = 'اليوم • ${DateFormat('d MMMM', 'ar').format(txDate)}';
      } else if (txDate.year == now.year && txDate.month == now.month && txDate.day == now.day - 1) {
        dateHeader = 'أمس • ${DateFormat('d MMMM', 'ar').format(txDate)}';
      } else {
        dateHeader = DateFormat('EEEE، d MMMM', 'ar').format(txDate);
      }

      groups.putIfAbsent(dateHeader, () => []).add(tx);
    }

    return groups;
  }

  // --- Actions ---

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await loadCategories();
    await loadMonthData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await DatabaseHelper.instance.getAllCategories();
  }

  Future<void> loadMonthData() async {
    _transactions = await DatabaseHelper.instance.getTransactionsByMonth(monthYearKey);
    _monthlyBudget = await DatabaseHelper.instance.getMonthlyBudget(monthYearKey);
    notifyListeners();
  }

  void nextMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    loadMonthData();
  }

  void previousMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    loadMonthData();
  }

  void resetToCurrentMonth() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, 1);
    loadMonthData();
  }

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, 1);
    loadMonthData();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadMonthData();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadMonthData();
  }

  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    await DatabaseHelper.instance.setMonthlyBudget(monthYearKey, amount);
    notifyListeners();
  }

  Future<String?> exportBackup() async {
    return await BackupService.instance.exportBackup();
  }

  Future<bool> importBackup() async {
    final success = await BackupService.instance.importBackup();
    if (success) {
      await loadCategories();
      await loadMonthData();
    }
    return success;
  }
}
