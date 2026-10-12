import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/expense_provider.dart';
import '../../core/app_theme.dart';

class FinancialSummaryStrip extends StatelessWidget {
  const FinancialSummaryStrip({super.key});

  String _formatAmount(double val) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(val)} ج.م';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final income = provider.totalIncome;
        final expense = provider.totalSpent;
        final dailyAllowance = provider.dailyRemainingAllowance;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // 1. Total Income Mini Card
              Expanded(
                child: _buildMetricCard(
                  title: 'إجمالي الدخل',
                  amount: _formatAmount(income),
                  icon: Icons.trending_up_rounded,
                  iconColor: AppTheme.greenSafe,
                  iconBg: AppTheme.greenSafe.withAlpha(25),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),

              // 2. Total Expense Mini Card
              Expanded(
                child: _buildMetricCard(
                  title: 'المصروفات',
                  amount: _formatAmount(expense),
                  icon: Icons.trending_down_rounded,
                  iconColor: AppTheme.redCoral,
                  iconBg: AppTheme.redCoral.withAlpha(25),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),

              // 3. Daily Allowance Mini Card
              Expanded(
                child: _buildMetricCard(
                  title: 'المتبقي اليومي',
                  amount: dailyAllowance > 0
                      ? _formatAmount(dailyAllowance)
                      : (provider.monthlyBudget > 0 ? '0 ج.م' : 'غير محدد'),
                  icon: Icons.calendar_view_day_rounded,
                  iconColor: AppTheme.goldAccent,
                  iconBg: AppTheme.goldAccent.withAlpha(25),
                  isDark: isDark,
                  subtitle: '${provider.daysLeftInMonth} يوم باقٍ',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool isDark,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
