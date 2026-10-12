import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/expense_provider.dart';
import '../../core/app_theme.dart';

class CategoryChart extends StatefulWidget {
  const CategoryChart({super.key});

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int touchedIndex = -1;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(amount)} ج.م';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final spendings = provider.categorySpendings;

        if (spendings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      Icons.pie_chart_outline_rounded,
                      size: 48,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مصروفات مسجلة في هذا الشهر',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'قم بإضافة معاملاتك اليومية لتوليد تحليلات التوزيع البياني الذكية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final total = provider.totalSpent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chart Card Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDarkElevated : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'توزيع النفقات حسب التصنيف',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldPrimary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${spendings.length} تصنيفات نشطة',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Donut Chart with Center Cutout
                  SizedBox(
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: spendings.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isTouched = index == touchedIndex;
                              final radius = isTouched ? 48.0 : 38.0;

                              return PieChartSectionData(
                                color: item.category.color,
                                value: item.amount,
                                title: '${item.percentage.toStringAsFixed(0)}%',
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: isTouched ? 14 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Center Cutout Info
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              touchedIndex >= 0 && touchedIndex < spendings.length
                                  ? spendings[touchedIndex].category.name
                                  : 'إجمالي المصاريف',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              touchedIndex >= 0 && touchedIndex < spendings.length
                                  ? _formatCurrency(spendings[touchedIndex].amount)
                                  : _formatCurrency(total),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: touchedIndex >= 0 && touchedIndex < spendings.length
                                    ? spendings[touchedIndex].category.color
                                    : (isDark ? Colors.white : AppTheme.textDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ranking & Categories Breakdown Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard_rounded, size: 18, color: AppTheme.goldAccent),
                  const SizedBox(width: 8),
                  Text(
                    'تفصيل النفقات والترتيب',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Category Breakdown List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: spendings.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = spendings[index];
                final isTouched = index == touchedIndex;

                Color rankColor = AppTheme.textMuted;
                if (index == 0) rankColor = AppTheme.goldAccent;
                if (index == 1) rankColor = const Color(0xFF94A3B8); // Silver
                if (index == 2) rankColor = const Color(0xFFD97706); // Bronze

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isTouched
                          ? item.category.color
                          : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      width: isTouched ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank Number Badge
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rankColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Category Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.category.color.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.category.iconData,
                          color: item.category.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name & Mini Bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${item.transactionCount} حركات)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppTheme.textMutedDark
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: item.percentage / 100,
                                backgroundColor: isDark
                                    ? AppTheme.borderDark
                                    : Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  item.category.color,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Amount & Percentage
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(item.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.textMutedDark
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
