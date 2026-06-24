import 'package:flutter/material.dart';
import 'main.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _tabTitles = [
    'Dashboard',
    'Monitors',
    'Reports',
    'About Us',
  ];

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Content coming soon',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return _buildPlaceholder(_tabTitles[1]);
      case 2:
        return _buildPlaceholder(_tabTitles[2]);
      case 3:
        return _buildPlaceholder(_tabTitles[3]);
      default:
        return _buildPlaceholder(_tabTitles[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      // ── AppBar ──
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF344E41),
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${widget.username}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Inesh Smart Energy',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF588157),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else if (value == 'profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile is coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.manage_accounts_outlined,
                        color: Color(0xFF0D1B3E)),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: _pageForIndex(_selectedIndex),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: const Color(0xFF3A5A40),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
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