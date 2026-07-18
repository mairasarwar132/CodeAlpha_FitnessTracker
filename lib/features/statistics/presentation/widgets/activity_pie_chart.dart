import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';

class ActivityPieChart extends StatelessWidget {
  const ActivityPieChart({super.key, required this.distribution});

  final ActivityDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = distribution.counts.entries.toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = const [
      AppColors.accent,
      AppColors.secondary,
      Color(0xFF0EA5E9),
      AppColors.warning,
      Color(0xFF8B5CF6),
      AppColors.error,
    ];

    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity mix',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // ── Donut Chart ──
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: entries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final mapEntry = entry.value;
                          final pct = total > 0
                              ? (mapEntry.value / total * 100)
                              : 0.0;
                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: mapEntry.value.toDouble(),
                            title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
                            radius: 55,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 3,
                        centerSpaceRadius: 38,
                      ),
                    ),
                  ),
                  // ── Legend ──
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: entries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final mapEntry = entry.value;
                          final pct = total > 0
                              ? (mapEntry.value / total * 100)
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _LegendItem(
                              color: colors[index % colors.length],
                              label: mapEntry.key,
                              percentage: '${pct.toStringAsFixed(0)}%',
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}