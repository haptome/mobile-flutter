import 'package:et_digital_equb/controllers/bottom_nav_controller.dart';
import 'package:et_digital_equb/controllers/completed_ekubs_controller.dart';
import 'package:et_digital_equb/controllers/faq_controller.dart';
import 'package:et_digital_equb/controllers/home_controller.dart';
import 'package:et_digital_equb/controllers/language_controller.dart';
import 'package:et_digital_equb/controllers/lottery_controller.dart';
import 'package:et_digital_equb/controllers/payment_controller.dart';
import 'package:et_digital_equb/controllers/profile_controller.dart';
import 'package:et_digital_equb/controllers/transactions_controller.dart';
import 'package:et_digital_equb/controllers/upcoming_payments_controller.dart';
import 'package:et_digital_equb/controllers/your_ekubs_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_service.dart';
import 'core/services/lottery_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/kyc_service.dart';
import 'core/services/group_service.dart';
import 'core/services/permission_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/upload_queue.dart';
import 'core/services/camera_service.dart';
import 'core/services/edge_detection_service.dart';
import 'core/services/image_quality_service.dart';
import 'core/services/face_detection_service.dart';
import 'core/services/liveness_detection_service.dart';
import 'core/utils/app_signature_helper.dart';
import 'core/utils/device_info.dart';
import 'config/cloudinary_config.dart';
import 'translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set dark status bar globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await _initServices().timeout(
    const Duration(milliseconds: 10000),
    onTimeout: () {
      debugPrint('[Main] Init timeout — proceeding to runApp() in degraded mode');
    },
  );

  runApp(const ETDigitalEqubApp());
}

Future<void> _initServices() async {
  // Initialize Firebase (required for FCM)
  if (!kIsWeb) {
    await Firebase.initializeApp();

    // Register background message handler
    // This must be called before any other Firebase Messaging methods
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialize InAppWebView plugin
  if (!kIsWeb) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // Initialize services before running the app
  final storageService = Get.put(StorageService(), permanent: true);
  await storageService.init();

  // Pre-warm device ID cache so getDeviceId() is ready synchronously
  await DeviceInfo.getDeviceIdAsync();

  final apiService = Get.put(ApiService(), permanent: true);
  await apiService.init();

  Get.put(LotteryService(), permanent: true);

  final authService = Get.put(AuthService(), permanent: true);
  await authService.init();

  // Initialize Cloudinary configuration
  final cloudinaryConfig = CloudinaryConfig.forEnvironment(Environment.production);
  final cloudinaryAvailable = cloudinaryConfig.validate();
  if (!cloudinaryAvailable) {
    debugPrint('[Main] Cloudinary unavailable — running in degraded mode');
  }

  if (cloudinaryAvailable) {
    // Initialize SharedPreferences for upload queue
    final prefs = await SharedPreferences.getInstance();

    // Initialize Connectivity for network monitoring
    final connectivity = Connectivity();

    // Create and register UploadQueue
    final uploadQueue = UploadQueue(prefs, connectivity);
    Get.put(uploadQueue, permanent: true);

    // Create and register CloudinaryService
    final cloudinaryService = CloudinaryService(
      cloudinaryConfig,
      uploadQueue,
      connectivity,
    );
    Get.put(cloudinaryService, permanent: true);

    // Start monitoring connectivity for automatic queue processing
    uploadQueue.startMonitoring();
  }

  // Register KYC service
  Get.put(KycService(), permanent: true);

  // Register KYC-related services lazily (only on mobile, not web)
  // Services are instantiated on first access during the KYC flow, not at startup
  if (!kIsWeb) {
    debugPrint('[Main] Registering KYC services for mobile platform (lazy)');
    Get.lazyPut(() => CameraService(), fenix: true);
    Get.lazyPut(() => EdgeDetectionService(), fenix: true);
    Get.lazyPut(() => ImageQualityService(), fenix: true);
    Get.lazyPut(() => FaceDetectionService(), fenix: true);
    Get.lazyPut(() => LivenessDetectionService(), fenix: true);
    debugPrint('[Main] KYC services registered lazily');
  } else {
    debugPrint('[Main] Skipping KYC services registration (running on web)');
  }

  // Register Group service
  Get.put(GroupService(), permanent: true);

  // Register Permission service
  Get.put(PermissionService(), permanent: true);

  // Register Payment service
  Get.put(PaymentService(), permanent: true);

  // Initialize FCM service (for push notifications)
  if (!kIsWeb) {
    Get.put(FcmService(), permanent: true);
    Get.put(DeepLinkService(), permanent: true);
  }

  // Initialize Language Controller
  Get.put(LanguageController(), permanent: true);

  Get.put(BottomNavController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(YourEkubsController(), permanent: true);
  Get.put(TransactionsController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(UpcomingPaymentsController(), permanent: true);
  Get.put(CompletedEkubsController(), permanent: true);
  Get.put(CompletedEkubsController(), permanent: true);
  Get.put(FaqController(), permanent: true);
  Get.put(LotteryController(), permanent: true);
  Get.put(PaymentController(), permanent: true);

  // Print Android app signature for SMS auto-fill setup (debug mode only)
  if (kDebugMode && !kIsWeb) {
    AppSignatureHelper.printAppSignature();
  }
}

class ETDigitalEqubApp extends StatelessWidget {
  const ETDigitalEqubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (languageController) {
        return GetMaterialApp(
          title: 'ET Digital Equb',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          
          // Localization
          translations: AppTranslations(),
          locale: languageController.currentLocale.value,
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
          
          initialRoute: AppRoutes.splash,
          getPages: AppRouter.getPages,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const Scaffold(body: Center(child: Text('Page not found'))),
          ),
        );
      },
    );
  }
}
