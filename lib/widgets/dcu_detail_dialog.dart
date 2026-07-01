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
    final badgeBg     = active ? AppColors.onlineBg : AppColors.offlineBg;
    final roleLabel   = meter.meterRole == MeterRole.main ? 'MAIN' : 'CHECK';

    final vKV    = active ? '${meter.avgPrimaryVoltagekV.toStringAsFixed(2)} kV' : '—';
    final pLabel = active
        ? '${meter.isExporting ? '−' : ''}${formatPower(meter.primaryPowerW.abs(), powerUnit)}'
        : '—';
    final rMVAR  = active
        ? '${(meter.primaryPowerVAR / 1_000_000).toStringAsFixed(3)} MVAR' : '—';
    final iR = active ? '${meter.primaryCurrentR.toStringAsFixed(0)} A' : '—';
    final iY = active ? '${meter.primaryCurrentY.toStringAsFixed(0)} A' : '—';
    final iB = active ? '${meter.primaryCurrentB.toStringAsFixed(0)} A' : '—';

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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(meter.feederName,
                    style: AppText.cardTitle.copyWith(fontSize: 14)),
              ),
              _tag(roleLabel),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg, borderRadius: BorderRadius.circular(6),
                ),
                child: Text(active ? 'ACTIVE' : 'INACTIVE',
                    style: AppText.badge.copyWith(color: statusColor)),
              ),
            ],
          ),

          if (meter.isExporting) ...[
            const SizedBox(height: 8),
            _exportBanner(),
          ],

          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 10),

          Row(children: [
            Expanded(child: _metric('Voltage', vKV)),
            Expanded(child: _metric('Active Power', pLabel)),
            Expanded(child: _metric('Reactive', rMVAR)),
          ]),

          const SizedBox(height: 12),

          // Phase row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgCardHover,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Expanded(child: _phase('R', iR, const Color(0xFFEF4444))),
              Expanded(child: _phase('Y', iY, const Color(0xFFF59E0B))),
              Expanded(child: _phase('B', iB, const Color(0xFF3B82F6))),
            ]),
          ),

          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _metric('MF', '${meter.multiplicationFactor}')),
            Expanded(child: _metric('CT', (meter.ctPrimary / meter.ctSecondary).toStringAsFixed(0))),
            Expanded(child: _metric('PT', (meter.ptPrimary / meter.ptSecondary).toStringAsFixed(0))),
          ]),
        ],
      ),
    );
  }

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

  Widget _exportBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF451A03),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF92400E)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt, size: 12, color: Color(0xFFFBBF24)),
        SizedBox(width: 4),
        Text('Export direction',
            style: TextStyle(color: Color(0xFFFBBF24),
                fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _divider() => Container(
      height: 1, color: AppColors.border);

  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.statLabel),
      const SizedBox(height: 3),
      Text(value,
          style: AppText.cardTitle.copyWith(fontSize: 13)),
    ],
  );

  Widget _phase(String label, String value, Color color) => Row(
    children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary,
                    fontSize: 9, fontWeight: FontWeight.bold)),
            Text(value,
                style: const TextStyle(color: AppColors.textPrimary,
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ],
  );
}