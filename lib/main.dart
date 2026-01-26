import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'features/content_studio/data/draft_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DraftStorage.init();
  runApp(const LonePenguApp());
}

class LonePenguApp extends StatelessWidget {
  const LonePenguApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LonePengu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
