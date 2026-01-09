import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'controllers/upload_controller.dart';
import 'theme/arcane_theme.dart';
import 'views/screens/main_scaffold.dart';
import 'services/standards_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseConfig.options,
  );
  runApp(const ArcaneMedicalApp());
}

class ArcaneMedicalApp extends StatelessWidget {
  const ArcaneMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => UploadController()),
      ],
      child: MaterialApp(
        title: 'Medical Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ArcaneTheme.lightTheme,
        home: MainScaffold(),
      ),
    );
  }
}
