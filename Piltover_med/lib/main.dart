import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'controllers/upload_controller.dart'; // ✅ NEW
import 'theme/arcane_theme.dart';
import 'views/screens/main_scaffold.dart';

void main() {
  runApp(const ArcaneMedicalApp());
}

class ArcaneMedicalApp extends StatelessWidget {
  const ArcaneMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => UploadController()), // ✅ NEW
      ],
      child: MaterialApp(
        title: 'Arcane Medical Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ArcaneTheme.lightTheme,
        home: MainScaffold(),
      ),
    );
  }
}