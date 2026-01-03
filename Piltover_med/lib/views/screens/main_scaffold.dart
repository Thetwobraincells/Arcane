import 'dart:ui';

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../widgets/upload_modal.dart';

// Global key definition
final GlobalKey<MainScaffoldState> mainScaffoldKey = GlobalKey<MainScaffoldState>();

class MainScaffold extends StatefulWidget {
  MainScaffold() : super(key: mainScaffoldKey);

  @override
  MainScaffoldState createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),   // 0: Home
    const ReportsScreen(),     // 1: Reports
    const StatsScreen(),       // 2: Stats (Dictionary)
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

  void _handleUploadTap() {
    showUploadModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color arcaneBg = const Color(0xFF0D1218);
    final Color neonCyan = const Color(0xFF00F0FF);
    final Color mutedText = const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: arcaneBg,
      
      // KEY CHANGE: This allows the body to scroll BEHIND the nav bar
      extendBody: true, 
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      floatingActionButtonLocation: _CustomFloatingActionButtonLocation(),
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
          onPressed: _handleUploadTap,
          backgroundColor: const Color(0xFF0F172A),
          shape: CircleBorder(side: BorderSide(color: neonCyan, width: 2)),
          elevation: 0,
          child: Icon(Icons.add, color: neonCyan, size: 32),
        ),
      ),

      // The Floating Transparent Nav Bar
      bottomNavigationBar: SafeArea(
        bottom: false, // Allow it to sit closer to the bottom edge if desired
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24), // Added bottom margin to lift it up
          height: 70,
          // Removed the solid Container color here
          decoration: BoxDecoration(
            color: Colors.transparent, // Ensures no background color
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              // Glass Effect: Keeps the blur so text is readable over scrolling content
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), 
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.6), // Very sheer dark tint for contrast
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_filled, "Home", 0, neonCyan, mutedText),
                    _buildNavItem(Icons.description_outlined, "Reports", 1, neonCyan, mutedText),
                    const SizedBox(width: 48), 
                    _buildNavItem(Icons.menu_book, "Dictionary", 2, neonCyan, mutedText),
                    _buildNavItem(Icons.settings_outlined, "Settings", 3, neonCyan, mutedText),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor, Color inactiveColor) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with simple glow only when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: isSelected 
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 10)
                    ]
                  ) 
                : null,
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // Text logic
            if (isSelected) 
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: activeColor.withOpacity(0.5), blurRadius: 4)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double centerX = scaffoldGeometry.scaffoldSize.width / 2.0;
    
    // Adjusted calculation to match the new floating margin
    // The nav bar has a bottom margin of 24 and height of 70. 
    // We want the FAB to sit centered on that floating capsule.
    final double bottomPadding = 24.0; 
    final double navBarHeight = 70.0;
    
    // Position: Screen Height - Bottom Padding - (Nav Bar Height / 2) - (FAB Height / 2)
    final double y = scaffoldGeometry.scaffoldSize.height - bottomPadding - (navBarHeight / 2.0) - 35.0; 
    
    return Offset(centerX - 35, y); 
  }
}
