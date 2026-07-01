// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../widgets/stat_chip.dart';
import '../widgets/filter_tab_chip.dart';
import '../widgets/dcu_card.dart';
import '../widgets/dcu_detail_dialog.dart';
import '../theme/app_theme.dart';

enum _FilterTab { all, online, offline }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PowerUnit  _unit      = PowerUnit.mw;
  _FilterTab _filter    = _FilterTab.all;
  bool       _mfEnabled = true;
  String     _search    = '';
  bool       _syncing   = false;

  DashboardResponse? _data;
  String?            _error;
  DateTime?          _lastSynced;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _syncing = true; _error = null; });
    final r = await DashboardService.instance.fetchDashboard();
    if (!mounted) return;
    setState(() {
      _syncing = false;
      if (r.isSuccess) {
        _data = r.data;
        _lastSynced = DateTime.now();
      } else {
        _error = r.error;
      }
    });
  }

  List<DcuData> get _filtered {
    final all = _data?.dcus ?? [];
    return all.where((d) {
      if (_filter == _FilterTab.online  && !d.isOnline) { return false; }
      if (_filter == _FilterTab.offline &&  d.isOnline)  { return false; }
      if (_search.isNotEmpty &&
          !d.dcuName.toLowerCase().contains(_search.toLowerCase())) { return false; }
      return true;
    }).toList();
  }

  int get _totalDcus    => _data?.summary.totalDCUs ?? 0;
  int get _totalMeters  => _data?.summary.totalMeters ?? 0;
  int get _onlineCount  => _data?.dcus.where((d) =>  d.isOnline).length ?? 0;
  int get _offlineCount => _data?.dcus.where((d) => !d.isOnline).length ?? 0;
  int get _healthPct    => _data?.summary.healthPercent ?? 0;

  String _powerLabel(DcuData d) =>
      d.isOnline ? formatPower(d.totalMainImportW, _unit) : '—';

  String get _syncLabel {
    if (_error != null && _data == null) return 'Not synced';
    if (_syncing) return 'Syncing...';
    if (_lastSynced == null) return 'Not synced yet';
    final diff = DateTime.now().difference(_lastSynced!);
    if (diff.inSeconds < 10)  return 'Synced just now';
    if (diff.inMinutes < 1)   return 'Synced ${diff.inSeconds}s ago';
    if (diff.inMinutes < 60)  return 'Synced ${diff.inMinutes} min ago';
    return 'Synced ${diff.inHours} hr ago';
  }

  void _showDetail(DcuData dcu) => showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (_) => DcuDetailDialog(dcu: dcu, powerUnit: _unit),
  );

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: _fetch,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),

            if (_syncing && _data == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(
                    color: AppColors.accent)),
              )
            else if (_error != null && _data == null)
              SliverFillRemaining(child: _buildError())
            else ...[
              SliverToBoxAdapter(child: _buildStatRow()),
              SliverToBoxAdapter(child: _buildToolbar()),
              SliverToBoxAdapter(child: _buildFilterTabs()),
              if (filtered.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => DcuCard(
                      dcu: filtered[i],
                      powerLabel: _powerLabel(filtered[i]),
                      onTap: () => _showDetail(filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          // Pulsing green dot
          _PulseDot(),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DCU Monitor', style: AppText.heading),
              const SizedBox(height: 2),
              Text(_syncLabel, style: AppText.subheading),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _fetch,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _syncing
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent))
                  : const Icon(Icons.refresh_rounded,
                      color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    final totalPower = _data == null
        ? '—'
        : formatPower(_data!.summary.totalImportW(applyMF: _mfEnabled), _unit);

    final chips = [
      StatChip(label: 'DCUS',    value: '$_totalDcus',   valueColor: AppColors.textPrimary),
      StatChip(label: 'FEEDERS', value: '$_totalMeters',  valueColor: AppColors.textPrimary),
      StatChip(label: 'ONLINE',  value: '$_onlineCount',  valueColor: AppColors.online),
      StatChip(label: 'OFFLINE', value: '$_offlineCount', valueColor: AppColors.offline),
      StatChip(
        label: 'HEALTH',
        value: '$_healthPct%',
        valueColor: _healthPct >= 80 ? AppColors.online : const Color(0xFFF59E0B),
      ),
      StatChip(label: 'IMPORT',  value: totalPower,       valueColor: AppColors.accentLight),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < chips.length; i++) ...[
                chips[i],
                if (i < chips.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: PowerUnit.values.map((u) {
                final sel = _unit == u;
                return GestureDetector(
                  onTap: () => setState(() => _unit = u),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      u.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold,
                        color: sel ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search DCU...',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.textSecondary, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text('MF', style: AppText.statLabel),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _mfEnabled = !_mfEnabled),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38, height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: _mfEnabled
                          ? AppColors.accent : AppColors.bgChipUnsel,
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _mfEnabled
                          ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 18, height: 18,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
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

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          FilterTabChip(
            countColor: Colors.transparent,
            label: 'All DCUs', count: _data?.dcus.length ?? 0,
            selected: _filter == _FilterTab.all,
            onTap: () => setState(() => _filter = _FilterTab.all),
          ),
          const SizedBox(width: 8),
          FilterTabChip(
            label: 'Online', count: _onlineCount,
            selected: _filter == _FilterTab.online,
            countColor: AppColors.online,
            onTap: () => setState(() => _filter = _FilterTab.online),
          ),
          const SizedBox(width: 8),
          FilterTabChip(
            label: 'Offline', count: _offlineCount,
            selected: _filter == _FilterTab.offline,
            countColor: AppColors.offline,
            onTap: () => setState(() => _filter = _FilterTab.offline),
          ),
        ],
      ),
    );
  }


  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Check here'),
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Failed to load dashboard',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0x66EF4444)),
            ),
            child: SingleChildScrollView(
              child: Text(
                _error ?? 'Unknown error',
                style: const TextStyle(
                    color: AppColors.offline,
                    fontSize: 12,
                    fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          const _NetworkChecklist(),
        ],
      ),
    );
  }

  Widget _buildEmpty() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: Text('No DCUs match this filter.',
          style: AppText.subheading),
    ),
  );
}


class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  late final Animation<double> _anim =
      Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 10, height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle, color: AppColors.online),
    ),
  );
}

class _NetworkChecklist extends StatelessWidget {
  const _NetworkChecklist();

  @override
  Widget build(BuildContext context) {
    const items = [
      '• Phone and server on the same Wi-Fi / VPN?',
      '• AndroidManifest has INTERNET permission?',
      '• android:usesCleartextTraffic="true" set?',
      '• Server running at 118.91.232.233:3001?',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Check list',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          ...items.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(s,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              )
            ),
        ],
      ),
    );
  }
}