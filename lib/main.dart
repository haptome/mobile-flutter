// Purpose: Main entry point for ET Digital Ekub Mobile App
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'translations/app_translations.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services in dependency order
  await _initServices();
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

Future<void> _initServices() async {
  // 1. Initialize StorageService first (no dependencies)
  Get.put(StorageService(), permanent: true);
  await Get.find<StorageService>().init();
  
  // 2. Initialize ApiService (depends on StorageService)
  Get.put(ApiService(), permanent: true);
  await Get.find<ApiService>().init();
  
  // 3. Initialize AuthService (depends on ApiService and StorageService)
  Get.put(AuthService(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ET Digital Ekub',
      debugShowCheckedModeBanner: false,
      
      // Device Preview Configuration
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      // Localization
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('am', 'ET'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Routing
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // Theme
      theme: ThemeData(
        primaryColor: const Color(0xFFBBBB32), // Primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBBBB32),
          primary: const Color(0xFFBBBB32),
          secondary: const Color(0xFF024141),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
    );
  }
}

