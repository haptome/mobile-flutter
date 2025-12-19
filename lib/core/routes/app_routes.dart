import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/your_ekubs/your_ekubs_view.dart';
import '../../features/transactions/transactions_view.dart';
import '../../features/profile/profile_view.dart';
import '../../features/profile/account_setting_view.dart';
import '../../features/profile/verification_view.dart';
import '../../features/profile/id_card_camera_view.dart';
import '../../features/profile/id_card_confirmation_view.dart';
import '../../features/profile/account_checking_view.dart';
import '../../features/ekub_type/presentation/ekub_type_view.dart';
import '../../features/in_kind/presentation/in_kind_view.dart';
import '../../features/duration/presentation/duration_view.dart';
import '../../controllers/your_ekubs_controller.dart';
import '../../controllers/transactions_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/account_setting_controller.dart';
import '../../controllers/ekub_type_controller.dart';
import '../../controllers/in_kind_controller.dart';
import '../../controllers/duration_controller.dart';

/// Application route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String ekubs = '/ekubs';
  static const String transactions = '/transactions';
  static const String profile = '/profile';
  static const String accountSetting = '/account-setting';
  static const String verification = '/verification';
  static const String ekubType = '/ekub-type';
  static const String inKind = '/in-kind';
  static const String duration = '/duration';
  static const String idCardCamera = '/id-card-camera';
  static const String idCardConfirmation = '/id-card-confirmation';
  static const String accountChecking = '/account-checking';
}

/// Route configuration for the app
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );

      case AppRoutes.otp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            isFromLogin: args?['isFromLogin'] ?? false,
          ),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.ekubs:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<YourEkubsController>()) {
          Get.put(YourEkubsController());
        }
        return MaterialPageRoute(
          builder: (_) => const YourEkubsView(),
          settings: settings,
        );

      case AppRoutes.transactions:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<TransactionsController>()) {
          Get.put(TransactionsController());
        }
        return MaterialPageRoute(
          builder: (_) => const TransactionsView(),
          settings: settings,
        );

      case AppRoutes.profile:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
        return MaterialPageRoute(
          builder: (_) => const ProfileView(),
          settings: settings,
        );

      case AppRoutes.accountSetting:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<AccountSettingController>()) {
          Get.put(AccountSettingController());
        }
        return MaterialPageRoute(
          builder: (_) => const AccountSettingView(),
          settings: settings,
        );

      case AppRoutes.verification:
        return MaterialPageRoute(
          builder: (_) => const VerificationView(),
          settings: settings,
        );

      case AppRoutes.ekubType:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<EkubTypeController>()) {
          Get.put(EkubTypeController());
        }
        return MaterialPageRoute(
          builder: (_) => const EkubTypeView(),
          settings: settings,
        );

      case AppRoutes.inKind:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<InKindController>()) {
          Get.put(InKindController());
        }
        return MaterialPageRoute(
          builder: (_) => const InKindView(),
          settings: settings,
        );

      case AppRoutes.duration:
        // Initialize controller if not already initialized
        if (!Get.isRegistered<DurationController>()) {
          Get.put(DurationController());
        }
        return MaterialPageRoute(
          builder: (_) => const DurationView(),
          settings: settings,
        );

      case AppRoutes.idCardCamera:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => IdCardCameraView(
            verificationMethod: args?['verificationMethod'] ?? 'National ID',
          ),
          settings: settings,
        );

      case AppRoutes.idCardConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => IdCardConfirmationView(
            imagePath: args?['imagePath'] ?? '',
            verificationMethod: args?['verificationMethod'] ?? 'National ID',
          ),
          settings: settings,
        );

      case AppRoutes.accountChecking:
        return MaterialPageRoute(
          builder: (_) => const AccountCheckingView(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}

