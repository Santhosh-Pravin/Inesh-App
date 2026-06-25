import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterTabChip extends StatelessWidget{
  final String label;
  final int count;
  final bool selected;
  final Color countColor;
  final VoidCallback onTap;

  const FilterTabChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.countColor,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.bgChipSel : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white70 : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ), 
      ),
    );
  }
}