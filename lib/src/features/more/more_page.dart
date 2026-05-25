import 'package:flutter/material.dart';

import '../hijri/hijri_page.dart';
import 'theme_settings_page.dart';
import 'about_page.dart';

import '../../core/ui/universal_hijri_header.dart';
import '../../core/ui/glass.dart';
import '../../core/ui/glass_scaffold.dart';
import '../../core/theme/app_theme.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'المزيد',
      body: Column(
        children: [
          const UniversalHijriHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.calendar_month,
                  title: 'التاريخ الهجري',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HijriPage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.dark_mode,
                  title: 'المظهر (نهاري/ليلي)',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'عن التطبيق',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppTheme.goldMain),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: const Icon(Icons.chevron_left, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}