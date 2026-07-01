// widgets/dcu_detail_dialog.dart
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_theme.dart';

enum _FeederFilter { all, main, check, active, inactive }

class DcuDetailDialog extends StatefulWidget {
  final DcuData   dcu;
  final PowerUnit powerUnit;
  const DcuDetailDialog({super.key, required this.dcu, required this.powerUnit});

  @override
  State<DcuDetailDialog> createState() => _DcuDetailDialogState();
}

class _DcuDetailDialogState extends State<DcuDetailDialog> {
  _FeederFilter _filter = _FeederFilter.all;

  List<MeterReading> get _filtered {
    final all = widget.dcu.meters;
    switch (_filter) {
      case _FeederFilter.all:      return all;
      case _FeederFilter.main:     return all.where((m) => m.meterRole == MeterRole.main).toList();
      case _FeederFilter.check:    return all.where((m) => m.meterRole == MeterRole.check).toList();
      case _FeederFilter.active:   return all.where((m) => m.isActive).toList();
      case _FeederFilter.inactive: return all.where((m) => !m.isActive).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.of(context).size;
    final maxW     = size.width > 520 ? 480.0 : size.width * 0.94;
    final maxH     = size.height * 0.85;
    final filtered = _filtered;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterChips(),
                      const SizedBox(height: 14),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No meters match this filter.',
                                style: AppText.label),
                          ),
                        )
                      else
                        ...filtered.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MeterCard(meter: m, powerUnit: widget.powerUnit),
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dcu = widget.dcu;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.bgCardHover,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status dot
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dcu.isOnline ? AppColors.online : AppColors.offline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(dcu.dcuName,
                    style: AppText.heading.copyWith(fontSize: 17)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.bgBase,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close,
                      color: AppColors.textSecondary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Last sync: ${dcu.lastSeenLabel}', style: AppText.subheading),
          const SizedBox(height: 14),
          // Mini stats
          Row(
            children: [
              _miniStat('Total Meters',   '${dcu.totalMeters}',   AppColors.textPrimary),
              _divider(),
              _miniStat('Active',         '${dcu.activeMeters}',  AppColors.online),
              _divider(),
              _miniStat('Inactive',       '${dcu.offlineMeters}', AppColors.offline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.statLabel),
          const SizedBox(height: 3),
          Text(value,
              style: AppText.statValue.copyWith(
                  fontSize: 18, color: valueColor)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 30, color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8));

  Widget _buildFilterChips() {
    const chips = [
      (_FeederFilter.all,      'All'),
      (_FeederFilter.main,     'Main'),
      (_FeederFilter.check,    'Check'),
      (_FeederFilter.active,   'Active'),
      (_FeederFilter.inactive, 'Inactive'),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (value, label) = chips[i];
          final sel = _filter == value;
          return GestureDetector(
            onTap: () => setState(() => _filter = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.bgChipSel : AppColors.bgChipUnsel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Text(label,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textSecondary,
                  )),
            ),
          );
        },
      ),
    );
  }
}

class _MeterCard extends StatelessWidget {
  final MeterReading meter;
  final PowerUnit    powerUnit;
  const _MeterCard({required this.meter, required this.powerUnit});

  @override
  Widget build(BuildContext context) {
    final active      = meter.isActive;
    final statusColor = active ? AppColors.online : AppColors.offline;
    final roleLabel   = meter.meterRole == MeterRole.main ? 'MAIN' : 'CHECK';

    final activeLabel = meter.isExporting ? 'Export' : 'Import';
    final activeValue = active
        ? formatPower(meter.primaryPowerW.abs(), powerUnit)
        : '—';

    final reactiveLabel = meter.isLagging ? 'Lag' : 'Lead';
    final reactiveValue = active
        ? '${(meter.primaryPowerVAR.abs() / 1_000_000).toStringAsFixed(3)} MVAR'
        : '—';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: status dot, feeder name, role badge
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(meter.feederName,
                    style: AppText.cardTitle.copyWith(fontSize: 15)),
              ),
              _tag(roleLabel),
            ],
          ),
          const SizedBox(height: 12),

          // PH table
          Row(
            children: [
              Expanded(flex: 2, child: Text('PH', style: AppText.statLabel)),
              Expanded(flex: 3, child: Text('CURR (A)', style: AppText.statLabel, textAlign: TextAlign.center)),
              Expanded(flex: 3, child: Text('VOLT', style: AppText.statLabel, textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 6),
          _phRow('R', meter.currentR, meter.voltageR),
          _phRow('Y', meter.currentY, meter.voltageY),
          _phRow('B', meter.currentB, meter.voltageB),

          const SizedBox(height: 12),

          // Active / Reactive boxes
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardHover,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(left: BorderSide(color: AppColors.accent, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTIVE', style: AppText.statLabel),
                      const SizedBox(height: 3),
                      Text('$activeValue · $activeLabel',
                          style: AppText.cardTitle.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardHover,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REACTIVE', style: AppText.statLabel),
                      const SizedBox(height: 3),
                      Text('$reactiveValue · $reactiveLabel',
                          style: AppText.cardTitle.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _phRow(String label, double curr, double volt) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: AppText.statLabel)),
        Expanded(flex: 3, child: Text(curr.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: AppText.cardTitle.copyWith(fontSize: 13))),
        Expanded(flex: 3, child: Text(volt.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: AppText.cardTitle.copyWith(fontSize: 13))),
      ],
    ),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.bgChipUnsel,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5,
        )),
  );
}