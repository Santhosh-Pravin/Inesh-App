// widgets/stat_chip.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  valueColor;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    // Scale chip padding and font size relative to screen width so it
    // never overflows on small phones or looks too tiny on tablets.
    final sw         = MediaQuery.of(context).size.width;
    final hPad       = sw < 360 ? 10.0 : 14.0;
    final vPad       = sw < 360 ?  8.0 : 11.0;
    final labelSize  = sw < 360 ?  9.0 : 10.0;
    final valueSize  = sw < 360 ? 18.0 : 22.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppText.statLabel.copyWith(fontSize: labelSize),
          ),
          SizedBox(height: sw < 360 ? 4 : 6),
          Text(
            value,
            style: AppText.statValue.copyWith(
              color: valueColor,
              fontSize: valueSize,
            ),
          ),
        ],
      ),
    );
  }
}