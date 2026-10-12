import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/expense_provider.dart';
import '../../core/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddExpenseSheet(),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  String _transactionType = 'expense'; // 'expense' or 'income'
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<double> _quickAmounts = [50, 100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      if (provider.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = provider.categories.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double val) {
    final current = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final updated = current + val;
    _amountController.text = updated.toStringAsFixed(0);
  }

  void _saveTransaction() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة مبلغ صحيح'),
          backgroundColor: AppTheme.redCoral,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار التصنيف'),
          backgroundColor: AppTheme.goldAccent,
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _selectedCategory!.name
        : _titleController.text.trim();

    final tx = TransactionModel(
      title: title,
      amount: amount,
      type: _transactionType,
      categoryId: _selectedCategory!.id ?? 1,
      date: _selectedDate,
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    provider.addTransaction(tx);

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ExpenseProvider>(context);
    final isExpense = _transactionType == 'expense';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Type Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تسجيل حركة مالية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  // Segmented Switcher (Expense / Income)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDarkElevated : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _transactionType = 'expense'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isExpense ? AppTheme.redCoral : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: isExpense ? Colors.white : AppTheme.redCoral,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مصروف',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isExpense
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _transactionType = 'income'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: !isExpense ? AppTheme.emeraldPrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 14,
                                  color: !isExpense ? Colors.white : AppTheme.emeraldLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'دخل',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !isExpense
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Huge Amount Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDarkElevated : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpense
                        ? AppTheme.redCoral.withAlpha(90)
                        : AppTheme.emeraldPrimary.withAlpha(90),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'ج.م',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? AppTheme.redCoral : AppTheme.emeraldPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: isExpense ? AppTheme.redCoral : AppTheme.emeraldPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                    ),
                    if (_amountController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () => setState(() => _amountController.clear()),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Quick Amount Increments Chips (+50, +100, +200, +500)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickAmounts.map((q) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ActionChip(
                        label: Text(
                          '+${q.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        backgroundColor: isDark
                            ? AppTheme.cardDarkElevated
                            : const Color(0xFFF1F5F9),
                        side: BorderSide(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        ),
                        onPressed: () => _addQuickAmount(q),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Category Selector Grid
              const Text(
                'اختر التصنيف:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.categories.map((cat) {
                  final isSelected = _selectedCategory?.id == cat.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withAlpha(35)
                            : (isDark ? AppTheme.cardDarkElevated : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? cat.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.iconData,
                            size: 18,
                            color: cat.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? cat.color
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Title and Date Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'تفاصيل المعاملة (اختياري)',
                        prefixIcon: const Icon(Icons.edit_note_rounded, size: 22),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? AppTheme.cardDarkElevated : const Color(0xFFF1F5F9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDarkElevated : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 18, color: AppTheme.emeraldPrimary),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('d/M').format(_selectedDate),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Big Save Button (Rule of 3 Seconds)
              ElevatedButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  isExpense ? 'تسجيل المصروف الآن' : 'تسجيل الإيراد الآن',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpense ? AppTheme.emeraldPrimary : AppTheme.emeraldAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: isExpense
                      ? AppTheme.emeraldPrimary.withAlpha(120)
                      : AppTheme.emeraldAccent.withAlpha(120),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
