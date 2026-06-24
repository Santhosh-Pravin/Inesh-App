import 'package:flutter/material.dart';



/// Display unit for power readings across the dashboard.
enum PowerUnit { w, kw, mw }

/// Formats a power value given in **watts** into the requested [unit].
///
/// This is the single source of truth for power formatting so that when
/// real API data arrives (always in watts), every screen converts the
/// same way.

String formatPower(double watts, PowerUnit unit) {
  switch (unit) {
    case PowerUnit.w:
      return '${watts.toStringAsFixed(watts >= 100 ? 0 : 1)} W';
    case PowerUnit.kw:
      final kw = watts / 1000;
      return '${kw.toStringAsFixed(kw >= 100 ? 0 : 1)} kW';
    case PowerUnit.mw:
      final mw = watts / 1000000;
      return '${mw.toStringAsFixed(mw >= 100 ? 0 : 2)} MW';
  }
}



enum DcuStatus { online, offline }

class DcuUnit {
  final String id;
  final String name;
  final String location;
  final DcuStatus status;
  final String lastSeen;
  final double powerMW;
  final double powerKW;
  final int feeders;
  final int activeFeeders;
  final int offlineFeeders;

  const DcuUnit({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.lastSeen,
    required this.powerMW,
    required this.powerKW,
    required this.feeders,
    this.activeFeeders = 0,
    this.offlineFeeders = 0,
  });

  /// Power reading normalized to watts, for use with [formatPower].
  /// (API will eventually supply watts directly; powerKW is the
  /// interim source until then.)
  double get powerWatts => powerKW * 1000;
}

final List<DcuUnit> _dummyDcus = [
  DcuUnit(
    id: 'DCU-001',
    name: 'Anna Nagar Feeder',
    location: 'Zone A',
    status: DcuStatus.online,
    lastSeen: '20 hr ago',
    powerMW: 1.24,
    powerKW: 1240,
    feeders: 8,
    activeFeeders: 7,
    offlineFeeders: 1,
  ),
  DcuUnit(
    id: 'DCU-002',
    name: 'T Nagar Substation',
    location: 'Zone B',
    status: DcuStatus.online,
    lastSeen: '20 hr ago',
    powerMW: 0.98,
    powerKW: 980,
    feeders: 6,
    activeFeeders: 6,
    offlineFeeders: 0,
  ),
  DcuUnit(
    id: 'DCU-003',
    name: 'Velachery Zone B',
    location: 'Zone C',
    status: DcuStatus.offline,
    lastSeen: '20 hr ago',
    powerMW: 0.0,
    powerKW: 0,
    feeders: 5,
    activeFeeders: 0,
    offlineFeeders: 5,
  ),
  DcuUnit(
    id: 'DCU-004',
    name: 'Guindy Industrial Park',
    location: 'Zone D',
    status: DcuStatus.online,
    lastSeen: '20 hr ago',
    powerMW: 2.10,
    powerKW: 2100,
    feeders: 12,
    activeFeeders: 11,
    offlineFeeders: 1,
  ),
  DcuUnit(
    id: 'DCU-005',
    name: 'Porur Lake Pump House',
    location: 'Zone E',
    status: DcuStatus.offline,
    lastSeen: '21 hr ago',
    powerMW: 0.0,
    powerKW: 0,
    feeders: 4,
    activeFeeders: 0,
    offlineFeeders: 4,
  ),
  DcuUnit(
    id: 'DCU-006',
    name: 'Adyar River Station',
    location: 'Zone F',
    status: DcuStatus.online,
    lastSeen: '19 hr ago',
    powerMW: 0.76,
    powerKW: 760,
    feeders: 7,
    activeFeeders: 7,
    offlineFeeders: 0,
  ),
  DcuUnit(
    id: 'DCU-007',
    name: 'Tambaram Grid',
    location: 'Zone G',
    status: DcuStatus.online,
    lastSeen: '18 hr ago',
    powerMW: 1.55,
    powerKW: 1550,
    feeders: 10,
    activeFeeders: 9,
    offlineFeeders: 1,
  ),
  DcuUnit(
    id: 'DCU-008',
    name: 'Ambattur OT',
    location: 'Zone H',
    status: DcuStatus.offline,
    lastSeen: '22 hr ago',
    powerMW: 0.0,
    powerKW: 0,
    feeders: 3,
    activeFeeders: 0,
    offlineFeeders: 3,
  ),
];


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum _FilterTab { all, online, offline }

class _DashboardScreenState extends State<DashboardScreen> {
  PowerUnit _unit = PowerUnit.mw;
  _FilterTab _filter = _FilterTab.all;
  bool _mfEnabled = true;
  String _search = '';
  bool _syncing = false;

  List<DcuUnit> get _filtered {
    var list = _dummyDcus.where((d) {
      if (_filter == _FilterTab.online && d.status != DcuStatus.online) {
        return false;
      }
      if (_filter == _FilterTab.offline && d.status != DcuStatus.offline) {
        return false;
      }
      if (_search.isNotEmpty &&
          !d.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    return list;
  }

  int get _totalDcus => _dummyDcus.length;
  int get _totalFeeders =>
      _dummyDcus.fold(0, (sum, d) => sum + d.feeders);
  int get _onlineCount =>
      _dummyDcus.where((d) => d.status == DcuStatus.online).length;
  int get _offlineCount =>
      _dummyDcus.where((d) => d.status == DcuStatus.offline).length;
  int get _healthPct => ((_onlineCount / _totalDcus) * 100).round();

  /// Thin wrapper so call sites don't need to know about `.powerWatts`.
  String _powerLabel(DcuUnit d) => formatPower(d.powerWatts, _unit);

  Future<void> _refresh() async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _syncing = false);
  }

  void _showDcuDetail(BuildContext context, DcuUnit unit) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => DcuDetailDialog(unit: unit, powerUnit: _unit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: RefreshIndicator(
        color: const Color(0xFF3A5A40),
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            
            SliverToBoxAdapter(child: _buildHeader()),

            
            SliverToBoxAdapter(child: _buildStatRow()),

           
            SliverToBoxAdapter(child: _buildToolbar()),

           
            SliverToBoxAdapter(child: _buildFilterTabs(filtered)),

            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _DcuCard(
                    unit: filtered[i],
                    powerLabel: _powerLabel(filtered[i]),
                    onTap: () => _showDcuDetail(context, filtered[i]),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DCU Monitor',
                style: TextStyle(
                  color: Color(0xFF3A5A40),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Synced just now',
                style: TextStyle(color: Color(0xFF3A5A40), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _refresh,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB8CCB9)),
              ),
              child: _syncing
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3A5A40),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded,
                      color: Color(0xFF3A5A40), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    final stats = [
      _StatChip(
          label: 'DCUS',
          value: '$_totalDcus',
          valueColor: const Color(0xFF0D1B3E)),
      _StatChip(
          label: 'FEEDERS',
          value: '$_totalFeeders',
          valueColor: const Color(0xFF0D1B3E)),
      _StatChip(
          label: 'ONLINE',
          value: '$_onlineCount',
          valueColor: const Color(0xFF2E7D52)),
      _StatChip(
          label: 'OFFLINE',
          value: '$_offlineCount',
          valueColor: const Color(0xFFD64550)),
      _StatChip(
          label: 'HEALTH',
          value: '$_healthPct%',
          valueColor: _healthPct >= 80
              ? const Color(0xFF2E7D52)
              : const Color(0xFFC68A2E)),
      _StatChip(
          label: 'ZONES',
          value: '${_dummyDcus.map((d) => d.location).toSet().length}',
          valueColor: const Color(0xFF2E6CA8)),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        physics: const BouncingScrollPhysics(),
        itemCount: stats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => stats[i],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Unit toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCE3DD)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: PowerUnit.values.map((u) {
                final selected = _unit == u;
                return GestureDetector(
                  onTap: () => setState(() => _unit = u),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF3A5A40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      u.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF7C8B7E),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
          // Search bar
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCE3DD)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Color(0xFF0D1B3E), fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search DCU...',
                  hintStyle: TextStyle(color: Color(0xFF9AA6A0), fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: Color(0xFF7C8B7E), size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // MF toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCE3DD)),
            ),
            child: Row(
              children: [
                const Text('MF',
                    style: TextStyle(
                        color: Color(0xFF7C8B7E),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _mfEnabled = !_mfEnabled),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _mfEnabled
                          ? const Color(0xFF3A5A40)
                          : const Color(0xFFC9D1CA),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _mfEnabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(List<DcuUnit> filtered) {
    final allCount = _dummyDcus.length;
    final onCount = _onlineCount;
    final offCount = _offlineCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All DCUs',
            count: allCount,
            selected: _filter == _FilterTab.all,
            onTap: () => setState(() => _filter = _FilterTab.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Online',
            count: onCount,
            selected: _filter == _FilterTab.online,
            color: const Color(0xFF52B788),
            onTap: () => setState(() => _filter = _FilterTab.online),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Offline',
            count: offCount,
            selected: _filter == _FilterTab.offline,
            color: const Color(0xFFE06C75),
            onTap: () => setState(() => _filter = _FilterTab.offline),
          ),
        ],
      ),
    );
  }
}


class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E9E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A9890),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    this.color = const Color(0xFF0D1B3E),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3A5A40) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF3A5A40) : const Color(0xFFDCE3DD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF5B6B5D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF0F3F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DcuCard extends StatelessWidget {
  final DcuUnit unit;
  final String powerLabel;
  final VoidCallback onTap;

  const _DcuCard({
    required this.unit,
    required this.powerLabel,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isOnline = unit.status == DcuStatus.online;
    final statusColor =
        isOnline ? const Color(0xFF2E7D52) : const Color(0xFFD64550);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1EA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD3E2D4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             
              Expanded(
                flex: 65,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder for a future real DCU image.
                      Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          child: Column(
                            children: [
                              SizedBox(height: 65,),
                              Icon(
                                Icons.image_outlined,
                                color: Color(0xFFB7C9B9),
                                size: 80,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 64,
                        child: Text(
                          '${unit.location} · ${unit.lastSeen}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF5B6B5D),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Text(
                          isOnline ? 'ONLINE' : 'OFFLINE',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                flex: 35,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 45,),
                        Text(
                          unit.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0D1B3E),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


enum FeederType { main, check }

class Feeder {
  final String id;
  final String name;
  final FeederType type;
  final DcuStatus status;
  final double currentA;
  final double voltageKV;
  final double phaseR;
  final double phaseY;
  final double phaseB;
  final double activeMW;
  final double reactiveMVAR;

  const Feeder({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.currentA,
    required this.voltageKV,
    required this.phaseR,
    required this.phaseY,
    required this.phaseB,
    required this.activeMW,
    required this.reactiveMVAR,
  });
}

List<Feeder> _dummyFeedersFor(DcuUnit unit) {
  final prefix = unit.name.split(' ').map((w) => w[0]).take(2).join();
  return List.generate(unit.feeders, (i) {
    final isMain = i % 2 == 0;
    final isOnline = i < unit.activeFeeders;
    return Feeder(
      id: '${unit.id}-F${i + 1}',
      name: '$prefix-F${i + 1}',
      type: isMain ? FeederType.main : FeederType.check,
      status: isOnline ? DcuStatus.online : DcuStatus.offline,
      currentA: isOnline ? 120.0 + (i * 7.5) : 0,
      voltageKV: isOnline ? 11.0 + (i % 3) * 0.2 : 0,
      phaseR: isOnline ? 118 + i * 2 : 0,
      phaseY: isOnline ? 121 + i * 2 : 0,
      phaseB: isOnline ? 119 + i * 2 : 0,
      activeMW: isOnline ? 0.8 + (i * 0.15) : 0,
      reactiveMVAR: isOnline ? 0.2 + (i * 0.05) : 0,
    );
  });
}


enum _FeederFilter { all, main, check, online, offline }

class DcuDetailDialog extends StatefulWidget {
  final DcuUnit unit;
  final PowerUnit powerUnit;

  const DcuDetailDialog({
    super.key,
    required this.unit,
    required this.powerUnit,
  });

  @override
  State<DcuDetailDialog> createState() => _DcuDetailDialogState();
}

class _DcuDetailDialogState extends State<DcuDetailDialog> {
  _FeederFilter _filter = _FeederFilter.all;
  late final List<Feeder> _feeders = _dummyFeedersFor(widget.unit);

  List<Feeder> get _filteredFeeders {
    switch (_filter) {
      case _FeederFilter.all:
        return _feeders;
      case _FeederFilter.main:
        return _feeders.where((f) => f.type == FeederType.main).toList();
      case _FeederFilter.check:
        return _feeders.where((f) => f.type == FeederType.check).toList();
      case _FeederFilter.online:
        return _feeders.where((f) => f.status == DcuStatus.online).toList();
      case _FeederFilter.offline:
        return _feeders.where((f) => f.status == DcuStatus.offline).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final screenSize = MediaQuery.of(context).size;
    final maxDialogHeight = screenSize.height * 0.82;
    final maxDialogWidth = screenSize.width > 520 ? 480.0 : screenSize.width * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, unit),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterChips(),
                      const SizedBox(height: 14),
                      if (_filteredFeeders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No feeders match this filter',
                              style: TextStyle(color: Color(0xFF8A9890)),
                            ),
                          ),
                        )
                      else
                        ..._filteredFeeders.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FeederCard(
                              feeder: f,
                              powerUnit: widget.powerUnit,
                            ),
                          ),
                        ),
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

  Widget _buildHeader(BuildContext context, DcuUnit unit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF3A5A40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Last communication: ${unit.lastSeen}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  'Active Feeders',
                  '${unit.activeFeeders}',
                  const Color(0xFF8FD9A8),
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _headerStat(
                  'Offline Feeders',
                  '${unit.offlineFeeders}',
                  const Color(0xFFF3A0A6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  ///
  Widget _buildFilterChips() {
    final chips = <(_FeederFilter, String)>[
      (_FeederFilter.all, 'All'),
      (_FeederFilter.main, 'Main'),
      (_FeederFilter.check, 'Check'),
      (_FeederFilter.online, 'Online'),
      (_FeederFilter.offline, 'Offline'),
    ];
///this the part where it gives stats
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (value, label) = chips[i];
          final selected = _filter == value;
          return GestureDetector(
            onTap: () => setState(() => _filter = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF3A5A40) : const Color(0xFFF1F4F1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF5B6B5D),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

///Part of FeederCards which give Feeder common class 
class _FeederCard extends StatelessWidget {
  final Feeder feeder;
  final PowerUnit powerUnit;

  const _FeederCard({required this.feeder, required this.powerUnit});

  @override
  Widget build(BuildContext context) {
    final isOnline = feeder.status == DcuStatus.online;
    final statusColor =
        isOnline ? const Color(0xFF2E7D52) : const Color(0xFFD64550);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Text(
                feeder.name,
                style: const TextStyle(
                  color: Color(0xFF0D1B3E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  feeder.type == FeederType.main ? 'MAIN' : 'CHECK',
                  style: const TextStyle(
                    color: Color(0xFF3A5A40),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Current / Voltage row
          Row(
            children: [
              Expanded(
                child: _metric('Current (A)', feeder.currentA.toStringAsFixed(1)),
              ),
              Expanded(
                child: _metric('Voltage (kV)', feeder.voltageKV.toStringAsFixed(2)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Phase readings R / Y / B
          Row(
            children: [
              Expanded(child: _phase('R', feeder.phaseR, const Color(0xFFD64550))),
              Expanded(child: _phase('Y', feeder.phaseY, const Color(0xFFC68A2E))),
              Expanded(child: _phase('B', feeder.phaseB, const Color(0xFF2E6CA8))),
            ],
          ),
          const SizedBox(height: 10),
          // Active / Reactive power row
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Active',
                  isOnline
                      ? formatPower(feeder.activeMW * 1000000, powerUnit)
                      : '—',
                ),
              ),
              Expanded(
                child: _metric(
                  'Reactive (MVAR)',
                  isOnline ? feeder.reactiveMVAR.toStringAsFixed(2) : '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A9890), fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0D1B3E),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
  
  Widget _phase(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          '$label  ${value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Color(0xFF0D1B3E),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}