import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedUnits = 'Metric';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildPreferencesSection(),
                  const SizedBox(height: 16),
                  _buildMedicalInfoSection(),
                  const SizedBox(height: 16),
                  _buildPrivacySection(),
                  const SizedBox(height: 16),
                  _buildAppInfoSection(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.settings,
              color: Color(0xFF0EA5E9),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Manage your preferences',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0EA5E9), size: 18),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Profile',
      icon: Icons.person_outline,
      children: [
        _buildInfoTile(
          icon: Icons.badge_outlined,
          title: AppConstants.appName,
          subtitle: 'AI-Powered Medical Analysis',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'DEMO',
              style: GoogleFonts.inter(
                color: const Color(0xFFF59E0B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildInfoTile(
          icon: Icons.account_circle_outlined,
          title: 'User Status',
          subtitle: 'Guest Mode',
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.tune,
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Switch to dark theme',
          value: _darkMode,
          onChanged: (value) => setState(() => _darkMode = value),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildDropdownTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: _selectedLanguage,
          onTap: _showLanguageSelector,
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildDropdownTile(
          icon: Icons.straighten,
          title: 'Units',
          subtitle: _selectedUnits,
          onTap: _showUnitsSelector,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoSection() {
    return _buildSection(
      title: 'Medical Information',
      icon: Icons.medical_information_outlined,
      children: [
        _buildNavigationTile(
          icon: Icons.info_outline,
          title: 'About This App',
          subtitle: 'How we analyze reports',
          onTap: _showAboutDialog,
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildNavigationTile(
          icon: Icons.psychology_outlined,
          title: 'AI Analysis Method',
          subtitle: 'Understanding our technology',
          onTap: _showAIInfoDialog,
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildNavigationTile(
          icon: Icons.warning_amber_outlined,
          title: 'Medical Disclaimer',
          subtitle: 'Important information',
          onTap: _showDisclaimerDialog,
          isWarning: true,
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy & Security',
      icon: Icons.security,
      children: [
        _buildInfoTile(
          icon: Icons.lock_outline,
          title: 'Data Processing',
          subtitle: 'Local processing only',
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildInfoTile(
          icon: Icons.cloud_off_outlined,
          title: 'No Cloud Storage',
          subtitle: 'Your data stays on device',
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildNavigationTile(
          icon: Icons.delete_outline,
          title: 'Delete All Reports',
          subtitle: 'Clear all data',
          onTap: _showDeleteConfirmation,
          isDanger: true,
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return _buildSection(
      title: 'App Information',
      icon: Icons.apps,
      children: [
        _buildInfoTile(
          icon: Icons.code,
          title: 'Version',
          subtitle: AppConstants.appVersion,
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        _buildInfoTile(
          icon: Icons.rocket_launch_outlined,
          title: 'Build Type',
          subtitle: 'Hackathon Demo',
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0EA5E9),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
    bool isWarning = false,
  }) {
    Color iconColor = isDanger
        ? const Color(0xFFEF4444)
        : isWarning
            ? const Color(0xFFF59E0B)
            : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF0EA5E9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Language',
        options: ['English', 'Spanish', 'French', 'German', 'Hindi'],
        currentValue: _selectedLanguage,
        onSelect: (value) => setState(() => _selectedLanguage = value),
      ),
    );
  }

  void _showUnitsSelector() {
    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Units',
        options: ['Metric', 'Imperial'],
        currentValue: _selectedUnits,
        onSelect: (value) => setState(() => _selectedUnits = value),
      ),
    );
  }

  Widget _buildDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelect,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == currentValue;
          return ListTile(
            title: Text(option, style: GoogleFonts.inter()),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF0EA5E9)) : null,
            onTap: () {
              onSelect(option);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog() {
    _showInfoDialog(
      'About Piltover Medical',
      'AI-powered medical test report interpretation platform helping you understand lab results.',
    );
  }

  void _showAIInfoDialog() {
    _showInfoDialog(
      'AI Analysis Method',
      'Uses Google Gemini to analyze reports, extract results, compare against normal ranges, and provide plain-language explanations.',
    );
  }

  void _showDisclaimerDialog() {
    _showInfoDialog(
      'Medical Disclaimer',
      'This app is for educational purposes only. Not a substitute for professional medical advice. Always consult qualified healthcare providers.',
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(content, style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Delete All Reports?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('This action cannot be undone.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All reports deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}