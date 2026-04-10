import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/report_controller.dart';
import 'controllers/upload_controller.dart';
import 'services/user_service.dart';
import 'theme/arcane_theme.dart';
import 'views/screens/main_scaffold.dart';
import 'services/standards_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
