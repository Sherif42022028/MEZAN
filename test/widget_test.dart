import 'package:flutter_test/flutter_test.dart';
import 'package:mizan_app/core/app_theme.dart';
import 'package:mizan_app/models/category_model.dart';
import 'package:mizan_app/models/transaction_model.dart';

void main() {
  test('CategoryModel and TransactionModel serialization test', () {
    final cat = CategoryModel(
      id: 1,
      name: 'طعام ومشروبات',
      iconCode: 12345,
      colorValue: 0xFFEF4444,
      isDefault: true,
    );

    final map = cat.toMap();
    final restoredCat = CategoryModel.fromMap(map);
    expect(restoredCat.name, 'طعام ومشروبات');
    expect(restoredCat.isDefault, true);

    final tx = TransactionModel(
      title: 'وجبة غداء',
      amount: 150.0,
      type: 'expense',
      categoryId: 1,
      date: DateTime(2026, 10, 12),
    );

    final txMap = tx.toMap();
    final restoredTx = TransactionModel.fromMap(txMap);
    expect(restoredTx.amount, 150.0);
    expect(restoredTx.isExpense, true);
  });

  test('AppTheme colors sanity test', () {
    expect(AppTheme.emeraldPrimary.toARGB32(), 0xFF065F46);
    expect(AppTheme.goldAccent.toARGB32(), 0xFFF59E0B);
    expect(AppTheme.redCoral.toARGB32(), 0xFFEF4444);
  });
}
