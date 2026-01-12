import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ReportsScreen(),
    const StatsScreen(),
    const SettingsScreen(),
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

  void _handleUploadTap() {
    showUploadModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleUploadTap,
        backgroundColor: const Color(0xFF0EA5E9),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.assignment, 'Reports', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.menu_book, 'Dictionary', 2),
              _buildNavItem(Icons.settings, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}