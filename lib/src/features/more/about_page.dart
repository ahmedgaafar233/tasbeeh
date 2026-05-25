import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/glass.dart';
import '../athkar/athkar_data.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldMain.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(Icons.mosque, size: 80, color: AppTheme.goldMain),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const GlassCard(
              child: Column(
                children: [
                  Text(
                    'هذا التطبيق صدقة جارية',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.goldMain, fontFamily: 'Amiri'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'صدقة جارية عن المطور وعائلته نسأل الله ان يتقبله خالصا لوجهه الكريم.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'مصادر المحتوى:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ...builtInSources.map((source) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.goldMain, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(source, style: const TextStyle(fontSize: 15))),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سياسة الخصوصية:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const GlassCard(
              child: Text(
                'نحن في تطبيق تسبيح نحترم خصوصيتك. التطبيق لا يقوم بجمع أي بيانات شخصية، وجميع البيانات يتم تخزينها محلياً فقط على جهازك ولا تتم مشاركتها مع أي طرف ثالث. التطبيق لا يتطلب الوصول إلى الكاميرا أو الميكروفون أو أي معلومات حساسة.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'الإصدار 1.1.0+4',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
