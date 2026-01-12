import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'controllers/upload_controller.dart';
import 'services/user_service.dart';
import 'theme/arcane_theme.dart';
import 'views/screens/main_scaffold.dart';
import 'services/standards_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_config.dart';
import 'services/standards_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseConfig.options,
  );
  // ---------------- TEST CODE START ----------------
  print("🔥 TESTING FIREBASE CONNECTION...");
  try {
    final service = StandardsService();
    // This asks for the "hemoglobin" doc you created in the console
    final result = await service.getStandard("hemoglobin");
    if (result != null) {
      print("✅ SUCCESS! Firebase sent back: ${result.unit}");
      print("✅ Found ranges for: ${result.ranges.map((r) => r.sex).join(', ')}");
    } else {
      print("⚠️ CONNECTED, BUT DATA NOT FOUND. Check your Firestore Document ID (must be 'hemoglobin').");
    }
  } catch (e) {
    print("❌ CONNECTION FAILED: $e");
  }
  // ---------------- TEST CODE END ----------------
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
        ChangeNotifierProvider(create: (_) => UserService()),
        Provider(create: (_) => StandardsService()),
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
