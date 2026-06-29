
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_theme.dart';

class DcuCard extends StatelessWidget {
  final DcuData      dcu;
  final String       powerLabel;
  final VoidCallback onTap;

  const DcuCard({super.key, required this.dcu, required this.powerLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOnline    = dcu.isOnline;
    final statusColor = isOnline ? AppColors.online : AppColors.offline;
    final badgeBg     = isOnline ? AppColors.onlineBg : AppColors.offlineBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.45),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dcu.dcuName, style: AppText.cardTitle),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.settings_remote_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _formattedDate(dcu.lastCommunication),
                            style: AppText.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

          
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOnline ? 'ONLINE' : 'OFFLINE',
                    style: AppText.badge.copyWith(color: statusColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  String _formattedDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h  = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m  = dt.minute.toString().padLeft(2, '0');
    final am = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}  $h:$m $am';
  }
}