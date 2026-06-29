// widgets/stat_chip.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  valueColor;

  const StatChip({super.key, required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.statLabel),
          const SizedBox(height: 6),
          Text(value, style: AppText.statValue.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}