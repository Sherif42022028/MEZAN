import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_provider.dart';
import '../core/app_theme.dart';
import '../models/transaction_model.dart';
import 'widgets/add_expense_sheet.dart';
import 'widgets/budget_card.dart';
import 'widgets/category_chart.dart';
import 'widgets/financial_summary_strip.dart';
import 'widgets/mizan_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0; // 0 = المعاملات, 1 = الإحصائيات, 2 = التصنيفات

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(amount)} ج.م';
  }

  void _handleMenuAction(String value, BuildContext context) async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    if (value == 'export') {
      final path = await provider.exportBackup();
      if (!mounted) return;
      if (path != null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم تصدير النسخة الاحتياطية بنجاح'),
            backgroundColor: AppTheme.emeraldPrimary,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('فشل تصدير النسخة الاحتياطية'),
            backgroundColor: AppTheme.redCoral,
          ),
        );
      }
    } else if (value == 'import') {
      final success = await provider.importBackup();
      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تمت استعادة البيانات بنجاح!'),
            backgroundColor: AppTheme.emeraldPrimary,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الاستيراد أو حدث خطأ في الملف'),
            backgroundColor: AppTheme.goldAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const MizanLogo(size: 36),
            actions: [
              if (!provider.isCurrentMonth)
                IconButton(
                  icon: const Icon(Icons.today_rounded, size: 22, color: AppTheme.goldAccent),
                  tooltip: 'العودة للشهر الحالي',
                  onPressed: provider.resetToCurrentMonth,
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (val) => _handleMenuAction(val, context),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.share_rounded, size: 20, color: AppTheme.emeraldPrimary),
                        SizedBox(width: 10),
                        Text('تصدير نسخة احتياطية (JSON)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        Icon(Icons.restore_page_rounded, size: 20, color: AppTheme.goldAccent),
                        SizedBox(width: 10),
                        Text('استعادة نسخة احتياطية'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.loadMonthData(),
                  child: CustomScrollView(
                    slivers: [
                      // Month Selector Pill
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDarkElevated : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded, size: 26),
                                onPressed: provider.nextMonth,
                                tooltip: 'الشهر القادم',
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    size: 18,
                                    color: AppTheme.emeraldPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider.formattedMonthYear,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded, size: 26),
                                onPressed: provider.previousMonth,
                                tooltip: 'الشهر السابق',
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Emerald Luxury Budget Card
                      const SliverToBoxAdapter(
                        child: BudgetCard(),
                      ),

                      // 3-Metric Financial Summary Strip
                      const SliverToBoxAdapter(
                        child: FinancialSummaryStrip(),
                      ),

                      // Segmented Tab Switcher (3 Tabs)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDarkElevated : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildTabItem(0, 'المعاملات (${provider.transactions.length})', isDark),
                              _buildTabItem(1, 'الإحصائيات', isDark),
                              _buildTabItem(2, 'التصنيفات (${provider.categories.length})', isDark),
                            ],
                          ),
                        ),
                      ),

                      // Main Content based on Selected Tab
                      if (_selectedTabIndex == 1)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 90),
                            child: CategoryChart(),
                          ),
                        )
                      else if (_selectedTabIndex == 2)
                        _buildCategoriesOverview(provider, isDark)
                      else ...[
                        // Transactions Feed Grouped by Human Date Headers
                        if (provider.transactions.isEmpty)
                          SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppTheme.cardDarkElevated : Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.receipt_long_rounded,
                                        size: 48,
                                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد حركات مسجلة في ${provider.formattedMonthYear}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'اضغط على الزر الذهبي (+) لإضافة أول معاملة في 3 ثوانٍ فقط',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, groupIndex) {
                                  final groups = provider.transactionsGroupedByDay.entries.toList();
                                  final group = groups[groupIndex];
                                  final dayTxs = group.value;

                                  // Calculate day total
                                  final dayExpense = dayTxs
                                      .where((t) => t.isExpense)
                                      .fold(0.0, (s, t) => s + t.amount);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Day Header & Subtotal
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              group.key,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                              ),
                                            ),
                                            if (dayExpense > 0)
                                              Text(
                                                'الصرف: ${_formatCurrency(dayExpense)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Transactions in this day
                                      ...dayTxs.map((tx) => _buildTransactionItem(
                                            context,
                                            tx,
                                            provider,
                                            isDark,
                                          )),
                                    ],
                                  );
                                },
                                childCount: provider.transactionsGroupedByDay.length,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldCardGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.emeraldPrimary.withAlpha(120),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => AddExpenseSheet.show(context),
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.goldBright, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'إضافة حركة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(int index, String label, bool isDark) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.cardDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? AppTheme.emeraldPrimary
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesOverview(ExpenseProvider provider, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cat = provider.categories[index];
            final spent = provider.transactions
                .where((t) => t.isExpense && t.categoryId == cat.id)
                .fold(0.0, (s, t) => s + t.amount);

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDarkElevated : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cat.color.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cat.iconData, color: cat.color, size: 20),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cat.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spent > 0 ? _formatCurrency(spent) : '0 ج.م',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: spent > 0 ? AppTheme.redCoral : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: provider.categories.length,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel tx,
    ExpenseProvider provider,
    bool isDark,
  ) {
    final catColor = tx.categoryColorValue != null
        ? Color(tx.categoryColorValue!)
        : AppTheme.emeraldPrimary;
    final catIcon = tx.categoryIconCode != null
        ? IconData(tx.categoryIconCode!, fontFamily: 'MaterialIcons')
        : Icons.category_rounded;

    final timeStr = DateFormat('hh:mm a', 'ar').format(tx.date);

    return Dismissible(
      key: Key('tx_${tx.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.redCoral,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (tx.id != null) {
          provider.deleteTransaction(tx.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف معاملة "${tx.title}"'),
              backgroundColor: AppTheme.redCoral,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: catColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(catIcon, color: catColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Title & Category Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tx.categoryName ?? 'عام',
                          style: TextStyle(
                            fontSize: 10,
                            color: catColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tx.isExpense
                    ? AppTheme.redCoral.withAlpha(15)
                    : AppTheme.greenSafe.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tx.isExpense ? '-' : '+'}${_formatCurrency(tx.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: tx.isExpense ? AppTheme.redCoral : AppTheme.greenSafe,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
