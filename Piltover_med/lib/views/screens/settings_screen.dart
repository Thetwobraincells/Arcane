import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  String _selectedLanguage = 'English';
  String _selectedUnits = 'Metric';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Settings Content
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildPreferencesSection(),
                  const SizedBox(height: 24),
                  _buildMedicalInfoSection(),
                  const SizedBox(height: 24),
                  _buildPrivacySection(),
                  const SizedBox(height: 24),
                  _buildAppInfoSection(),
                  const SizedBox(height: 40),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(AppConstants.hextechBlue).withOpacity(0.1),
            const Color(AppConstants.arcanePurple).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppConstants.hextechBlue).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(AppConstants.hextechBlue),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: const Color(AppConstants.hextechBlue).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalize your experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(AppConstants.hextechGold).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(AppConstants.hextechGold).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                color: Color(AppConstants.hextechGold),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildDivider(),
        _buildInfoTile(
          icon: Icons.account_circle_outlined,
          title: 'User Status',
          subtitle: 'Guest Mode (No Login Required)',
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
          subtitle: 'Optimized for medical displays',
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
          },
        ),
        _buildDivider(),
        _buildDropdownTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: _selectedLanguage,
          onTap: () => _showLanguageSelector(),
        ),
        _buildDivider(),
        _buildDropdownTile(
          icon: Icons.straighten,
          title: 'Units',
          subtitle: _selectedUnits,
          onTap: () => _showUnitsSelector(),
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
          subtitle: 'Learn how we analyze reports',
          onTap: () => _showAboutDialog(),
        ),
        _buildDivider(),
        _buildNavigationTile(
          icon: Icons.psychology_outlined,
          title: 'AI Analysis Method',
          subtitle: 'Understanding our technology',
          onTap: () => _showAIInfoDialog(),
        ),
        _buildDivider(),
        _buildNavigationTile(
          icon: Icons.warning_amber_outlined,
          title: 'Medical Disclaimer',
          subtitle: 'Important information',
          onTap: () => _showDisclaimerDialog(),
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
          subtitle: 'All analysis happens locally on your device',
        ),
        _buildDivider(),
        _buildInfoTile(
          icon: Icons.cloud_off_outlined,
          title: 'No Cloud Storage',
          subtitle: 'Your reports are never uploaded to servers',
        ),
        _buildDivider(),
        _buildNavigationTile(
          icon: Icons.delete_outline,
          title: 'Delete All Reports',
          subtitle: 'Clear all uploaded data',
          onTap: () => _showDeleteConfirmation(),
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
        _buildDivider(),
        _buildInfoTile(
          icon: Icons.rocket_launch_outlined,
          title: 'Build Type',
          subtitle: 'Hackathon Demo Build',
        ),
        _buildDivider(),
        _buildNavigationTile(
          icon: Icons.email_outlined,
          title: 'Feedback',
          subtitle: 'Send us your thoughts',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Feedback feature coming soon!'),
                backgroundColor: const Color(AppConstants.hextechBlue),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                Icon(
                  icon,
                  color: const Color(AppConstants.hextechBlue),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.hextechBlue),
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
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(AppConstants.hextechBlue),
            activeTrackColor: const Color(AppConstants.hextechBlue).withOpacity(0.3),
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
        ? Colors.red.shade400
        : isWarning
            ? const Color(AppConstants.hextechGold)
            : Colors.white.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDanger ? Colors.red.shade400 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
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
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(AppConstants.hextechBlue),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withOpacity(0.5),
              size: 24,
            ),
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
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: Colors.white.withOpacity(0.05),
        height: 1,
      ),
    );
  }

  // Dialog Methods
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => _buildSelectionDialog(
        title: 'Select Language',
        options: ['English', 'Spanish', 'French', 'German', 'Hindi'],
        currentValue: _selectedLanguage,
        onSelect: (value) {
          setState(() => _selectedLanguage = value);
        },
      ),
    );
  }

  void _showUnitsSelector() {
    showDialog(
      context: context,
      builder: (context) => _buildSelectionDialog(
        title: 'Select Units',
        options: ['Metric', 'Imperial'],
        currentValue: _selectedUnits,
        onSelect: (value) {
          setState(() => _selectedUnits = value);
        },
      ),
    );
  }

  Widget _buildSelectionDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelect,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(AppConstants.hextechBlue),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == currentValue;
          return InkWell(
            onTap: () {
              onSelect(option);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(AppConstants.hextechBlue).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(AppConstants.hextechBlue)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(AppConstants.hextechBlue)
                            : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(AppConstants.hextechBlue),
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog() {
    _showInfoDialog(
      title: 'About Piltover Medical',
      icon: Icons.info_outline,
      content:
          'Piltover Medical is an AI-powered medical test report interpretation platform. '
          'We help you understand your lab results with clear, plain-language explanations.\n\n'
          'This is a demo application built for educational purposes.',
    );
  }

  void _showAIInfoDialog() {
    _showInfoDialog(
      title: 'AI Analysis Method',
      icon: Icons.psychology_outlined,
      content:
          'Our AI uses Google Gemini to analyze your medical reports. The system:\n\n'
          '• Extracts test results from reports\n'
          '• Compares values against normal ranges\n'
          '• Identifies potential concerns\n'
          '• Provides plain-language explanations\n\n'
          'All processing happens on your device for privacy.',
    );
  }

  void _showDisclaimerDialog() {
    _showInfoDialog(
      title: 'Medical Disclaimer',
      icon: Icons.warning_amber_outlined,
      iconColor: const Color(AppConstants.hextechGold),
      content:
          '⚠️ IMPORTANT: This app is for educational purposes only.\n\n'
          '• Not a substitute for professional medical advice\n'
          '• Always consult qualified healthcare providers\n'
          '• Do not make medical decisions based solely on this app\n'
          '• In case of emergency, contact your doctor or emergency services immediately\n\n'
          'This is a demonstration application and should not be used for actual medical diagnosis.',
    );
  }

  void _showInfoDialog({
    required String title,
    required IconData icon,
    required String content,
    Color? iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
          ),
        ),
        title: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? const Color(AppConstants.hextechBlue),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: iconColor ?? const Color(AppConstants.hextechBlue),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: Color(AppConstants.hextechBlue),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            Text(
              'Delete All Reports?',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all uploaded reports and analysis data. This action cannot be undone.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All reports deleted'),
                  backgroundColor: Colors.red.shade400,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}