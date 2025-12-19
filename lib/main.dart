import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services before running the app
  final storageService = Get.put(StorageService(), permanent: true);
  await storageService.init();
  
  final apiService = Get.put(ApiService(), permanent: true);
  await apiService.init();
  
  final authService = Get.put(AuthService(), permanent: true);
  await authService.init();
  
  runApp(const ETDigitalEqubApp());
}

class ETDigitalEqubApp extends StatelessWidget {
  const ETDigitalEqubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ET Digital Equb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
