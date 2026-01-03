import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'theme/arcane_theme.dart';
import 'views/screens/main_scaffold.dart';

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
        
        // Ensure this theme defines the dark colors for the full effect
        theme: ArcaneTheme.lightTheme, 
        
        // This is the key change: Load the Scaffold with Nav Bar first
        home: MainScaffold(), 
      ),
    );
  }
}