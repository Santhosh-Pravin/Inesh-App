// screens/dashboard_screen.dart
import 'package:flutter/material.dart';

import '../widgets/filter_tab_chip.dart';

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

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _syncing = true; _error = null; });
    final r = await DashboardService.instance.fetchDashboard();
    if (!mounted) return;
    setState(() {
      _syncing = false;
      if (r.isSuccess) _data = r.data; else _error = r.error;
    });
  }

  List<DcuData> get _filtered {
    final all = _data?.dcus ?? [];
    return all.where((d) {
      if (_filter == _FilterTab.online  && !d.isOnline) return false;
      if (_filter == _FilterTab.offline &&  d.isOnline) return false;
      if (_search.isNotEmpty &&
          !d.dcuName.toLowerCase().contains(_search.toLowerCase())) return false;
      return true;
    }).toList();
  }

  int get _totalDcus    => _data?.summary.totalDCUs ?? 0;
  int get _totalMeters  => _data?.summary.totalMeters ?? 0;
  int get _onlineCount  => _data?.dcus.where((d) =>  d.isOnline).length ?? 0;
  int get _offlineCount => _data?.dcus.where((d) => !d.isOnline).length ?? 0;
  int get _healthPct    => _data?.summary.healthPercent ?? 0;

  
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DCU Monitor', style: AppText.heading),
              SizedBox(height: 2),
              Text('Synced just now', style: AppText.subheading),
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

 

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          // W / KW / MW toggle
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

          // Search
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

          // MF toggle
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

  
}