import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ads/ad_manager.dart';
import 'core/theme.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // AdMob not supported on web
  if (!kIsWeb) await AdManager().initialize();

  runApp(const NeonDriveApp());
}

class NeonDriveApp extends StatelessWidget {
  const NeonDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Drive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainMenuScreen(),
    );
  }
}
