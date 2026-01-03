import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../widgets/upload_modal.dart';

final GlobalKey<MainScaffoldState> mainScaffoldKey = GlobalKey<MainScaffoldState>();

class MainScaffold extends StatefulWidget {
  MainScaffold() : super(key: mainScaffoldKey);

  @override
  MainScaffoldState createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const DashboardScreen(),   // 0: Home
    const ReportsScreen(),     // 1: Reports
    const StatsScreen(),       // 2: Stats
    const SettingsScreen(),    // 3: Settings
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ✅ UNIFIED UPLOAD HANDLER
  void _handleUploadTap() {
    showUploadModal(context);
  }

  @override
  Widget build(BuildContext context) {
    // Arcane Theme Colors
    final Color arcaneBg = const Color(0xFF0D1218);
    final Color cardBg = const Color(0xFF1A202C);
    final Color neonCyan = const Color(0xFF00F0FF);
    final Color mutedText = const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: arcaneBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      // The Floating "Add Report" Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: neonCyan.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _handleUploadTap, // ✅ NOW CALLS UPLOAD MODAL
          backgroundColor: const Color(0xFF0F172A),
          shape: CircleBorder(side: BorderSide(color: neonCyan, width: 2)),
          elevation: 0,
          child: Icon(Icons.add, color: neonCyan, size: 32),
        ),
      ),

      // The Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: cardBg,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0, neonCyan, mutedText),
            _buildNavItem(Icons.description_outlined, "Reports", 1, neonCyan, mutedText),
            const SizedBox(width: 48), // Spacing for the center FAB
            _buildNavItem(Icons.menu_book, "Dictionary", 2, neonCyan, mutedText),
            _buildNavItem(Icons.settings_outlined, "Settings", 3, neonCyan, mutedText),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor, Color inactiveColor) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: isSelected
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: -2,
                      )
                    ],
                  )
                : null,
            child: Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              shadows: isSelected
                  ? [Shadow(color: activeColor.withOpacity(0.8), blurRadius: 8)]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}
