import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Import your existing dashboard

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const DashboardScreen(),      // 0: Home
    const Center(child: Text("Reports Screen", style: TextStyle(color: Colors.white))), // 1: Placeholder
    const SizedBox(),             // 2: Placeholder for the center Add button (handled by FAB)
    const Center(child: Text("Stats Screen", style: TextStyle(color: Colors.white))),   // 3: Placeholder
    const Center(child: Text("Settings Screen", style: TextStyle(color: Colors.white))),// 4: Placeholder
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // Middle button is handled by FAB
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Arcane Theme Colors (adjust to match your exact hex codes)
    final Color arcaneBg = const Color(0xFF0D1218); // Dark background
    final Color cardBg = const Color(0xFF1A202C); // Slightly lighter for nav bar
    final Color neonCyan = const Color(0xFF00F0FF); // Hextech glow color
    final Color mutedText = const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: arcaneBg,
      body: _screens[_currentIndex],
      
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
          onPressed: () {
            // Handle Add Report Action
            print("Add Report Clicked");
          },
          backgroundColor: const Color(0xFF0F172A),
          shape: CircleBorder(side: BorderSide(color: neonCyan, width: 2)),
          elevation: 0,
          child: Icon(Icons.add, color: neonCyan, size: 32),
        ),
      ),

      // The Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: cardBg,
        shape: const CircularNotchedRectangle(), // Creates the cutout for the FAB
        notchMargin: 8.0,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0, neonCyan, mutedText),
            _buildNavItem(Icons.description_outlined, "Reports", 1, neonCyan, mutedText),
            const SizedBox(width: 48), // Spacing for the center FAB
            _buildNavItem(Icons.bar_chart_rounded, "Stats", 3, neonCyan, mutedText),
            _buildNavItem(Icons.settings_outlined, "Settings", 4, neonCyan, mutedText),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a navigation item with "Glow" effect
  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor, Color inactiveColor) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing Icon Effect
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