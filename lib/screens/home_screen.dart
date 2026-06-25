// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  Widget _page(int i) {
    switch (i) {
      case 0: return const DashboardScreen();
      case 1: return _placeholder('Monitors',  Icons.monitor_heart_outlined);
      case 2: return _placeholder('Reports',   Icons.bar_chart_outlined);
      case 3: return _placeholder('About Us',  Icons.info_outline);
      default: return const DashboardScreen();
    }
  }

  Widget _placeholder(String label, IconData icon) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 52, color: AppColors.textMuted),
        const SizedBox(height: 14),
        Text(label, style: AppText.heading),
        const SizedBox(height: 6),
        Text('Content coming soon', style: AppText.subheading),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        title: Row(
          children: [
            // Brand logo circle
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, ${widget.username}!',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const Text('Inesh Smart Energy',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.bgChipUnsel,
              child: Icon(Icons.person_outline,
                  color: AppColors.textSecondary, size: 18),
            ),
            onSelected: (v) {
              if (v == 'logout') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Profile coming soon')));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(children: [
                  Icon(Icons.manage_accounts_outlined,
                      color: AppColors.textPrimary, size: 18),
                  SizedBox(width: 10),
                  Text('Profile',
                      style: TextStyle(color: AppColors.textPrimary)),
                ]),
              ),
              PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, color: AppColors.offline, size: 18),
                  SizedBox(width: 10),
                  Text('Logout',
                      style: TextStyle(color: AppColors.offline)),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _page(_idx),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.bgCard,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined),
              activeIcon: Icon(Icons.monitor_heart),
              label: 'Monitors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'About Us',
            ),
            
          ],
        ),
      ),
    );
  }
}