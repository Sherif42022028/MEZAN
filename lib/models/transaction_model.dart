class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'expense' or 'income'
  final int categoryId;
  final String? categoryName;
  final int? categoryIconCode;
  final int? categoryColorValue;
  final DateTime date;
  final String? note;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.categoryIconCode,
    this.categoryColorValue,
    required this.date,
    this.note,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String? ?? 'expense',
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String?,
      categoryIconCode: map['category_icon_code'] as int?,
      categoryColorValue: map['category_color_value'] as int?,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? type,
    int? categoryId,
    String? categoryName,
    int? categoryIconCode,
    int? categoryColorValue,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
