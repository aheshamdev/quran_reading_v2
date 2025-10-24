import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend/config/firebase_options.dart';
import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/fortress_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QuranReadingCorrectionApp());
}

class QuranReadingCorrectionApp extends StatelessWidget {
  const QuranReadingCorrectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => FortressProvider()),
      ],
      child: MaterialApp(
        title: 'Quran Reading Correction',
        theme: AppTheme.lightTheme,
        // تفعيل الاتجاه من اليمين لليسار
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA')],
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
