import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/report_controller.dart';
import 'theme/arcane_theme.dart';
import 'views/screens/dashboard_screen.dart';

void main() {
  runApp(const ArcaneMedicalApp());
}

class ArcaneMedicalApp extends StatelessWidget {
  const ArcaneMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportController(),
      child: MaterialApp(
        title: 'Arcane Medical Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ArcaneTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}

