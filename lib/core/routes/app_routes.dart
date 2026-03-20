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
import '../../features/category_detail/presentation/category_detail_view.dart';
import '../../features/group_detail/presentation/group_detail_view.dart';
import '../../features/in_kind_detail/presentation/in_kind_detail_view.dart';
import '../../features/payment/presentation/select_payment_method_view.dart';
import '../../features/payment/presentation/upcoming_payments_view.dart';
import '../../features/payment/presentation/payment_webview.dart';
import '../../features/lottery/presentation/lottery_view.dart';
import '../../features/lottery_draw/presentation/lottery_draw_page.dart';
import '../../features/completed_ekubs/presentation/completed_ekubs_view.dart';
import '../../features/faq/presentation/faq_view.dart';
import '../../controllers/your_ekubs_controller.dart';
import '../../controllers/transactions_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/account_setting_controller.dart';
import '../../controllers/ekub_type_controller.dart';
import '../../controllers/in_kind_controller.dart';
import '../../controllers/duration_controller.dart';
import '../../controllers/category_detail_controller.dart';
import '../../controllers/group_detail_controller.dart';
import '../../controllers/in_kind_detail_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/upcoming_payments_controller.dart';
import '../../controllers/lottery_controller.dart';
import '../../controllers/lottery_draw_controller.dart';
import '../../controllers/completed_ekubs_controller.dart';
import '../../controllers/faq_controller.dart';
import '../../controllers/set_password_controller.dart';
import '../../controllers/create_group_controller.dart';
import '../../controllers/terms_conditions_controller.dart';
import '../../core/services/permission_service.dart';
import '../../models/category_model.dart' as category_models;
import '../../models/group_model.dart';
import '../widgets/main_wrapper.dart';
import '../../features/profile/set_password_view.dart';
import '../../features/create_group/presentation/create_group_view.dart';
import '../../features/terms/terms_conditions_view.dart';
import '../../features/privacy/privacy_policy_view.dart';
import '../../features/profile/about_view.dart';
import '../../controllers/privacy_policy_controller.dart';

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
  static const String categoryDetail = '/category-detail';
  static const String groupDetail = '/group-detail';
  static const String selectPaymentMethod = '/select-payment-method';
  static const String upcomingPayments = '/upcoming-payments';
  static const String paymentWebview = '/payment-webview';
  static const String lottery = '/lottery';
  static const String lotteryDraw = '/lottery-draw';
  static const String completedEkubs = '/completed-ekubs';
  static const String faq = '/faq';
  static const String setPassword = '/set-password';
  static const String createGroup = '/create-group';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String inKindDetail = '/in-kind-detail';
  static const String about = '/about';
}

/// Route configuration for the app
class AppRouter {
  static List<GetPage> getPages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(
      name: AppRoutes.otp,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return OtpScreen(
          phoneNumber: args?['phoneNumber'] ?? '',
          isFromLogin: args?['isFromLogin'] ?? false,
        );
      },
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainWrapper(initialIndex: 0),
    ),
    GetPage(
      name: AppRoutes.ekubs,
      page: () => const MainWrapper(initialIndex: 1),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const MainWrapper(initialIndex: 2),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const MainWrapper(initialIndex: 3),
    ),
    GetPage(
      name: AppRoutes.accountSetting,
      page: () => const AccountSettingView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AccountSettingController>()) {
          Get.put(AccountSettingController());
        }
      }),
    ),
    GetPage(name: AppRoutes.verification, page: () => const VerificationView()),
    GetPage(
      name: AppRoutes.ekubType,
      page: () => const EkubTypeView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<EkubTypeController>()) {
          Get.put(EkubTypeController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.inKind,
      page: () => const InKindView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<InKindController>()) {
          Get.put(InKindController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.duration,
      page: () => const DurationView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<DurationController>()) {
          Get.put(DurationController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.idCardCamera,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return IdCardCameraView(
          verificationMethod: args?['verificationMethod'] ?? 'National ID',
        );
      },
    ),
    GetPage(
      name: AppRoutes.idCardConfirmation,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return IdCardConfirmationView(
          imagePath: args?['imagePath'] ?? '',
          verificationMethod: args?['verificationMethod'] ?? 'National ID',
        );
      },
    ),
    GetPage(
      name: AppRoutes.accountChecking,
      page: () => const AccountCheckingView(),
    ),
    GetPage(
      name: AppRoutes.categoryDetail,
      page: () {
        final category = Get.arguments as category_models.Category?;
        if (category == null) {
          return const Scaffold(
            body: Center(child: Text('Category not found')),
          );
        }
        if (!Get.isRegistered<CategoryDetailController>()) {
          Get.put(CategoryDetailController(category: category));
        } else {
          Get.find<CategoryDetailController>().category.value = category;
          Get.find<CategoryDetailController>().loadGroups();
        }
        return const CategoryDetailView();
      },
    ),
    GetPage(
      name: AppRoutes.inKindDetail,
      page: () {
        final group = Get.arguments as InKindGroup?;
        if (group == null) {
          return const Scaffold(
            body: Center(child: Text('In-kind group not found')),
          );
        }
        if (!Get.isRegistered<InKindDetailController>()) {
          Get.put(InKindDetailController(group: group));
        } else {
          Get.delete<InKindDetailController>();
          Get.put(InKindDetailController(group: group));
        }
        return const InKindDetailView();
      },
    ),
    GetPage(
      name: AppRoutes.groupDetail,
      page: () {
        final group = Get.arguments as Group?;
        if (group == null) {
          return const Scaffold(body: Center(child: Text('Group not found')));
        }
        if (!Get.isRegistered<GroupDetailController>()) {
          Get.put(GroupDetailController(group: group));
        } else {
          Get.delete<GroupDetailController>();
          Get.put(GroupDetailController(group: group));
        }
        return const GroupDetailView();
      },
    ),
    // Action Grid Routes
    GetPage(
      name: AppRoutes.selectPaymentMethod,
      page: () => const SelectPaymentMethodView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PaymentController>()) {
          Get.put(PaymentController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.upcomingPayments,
      page: () => const UpcomingPaymentsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UpcomingPaymentsController>()) {
          Get.put(UpcomingPaymentsController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.paymentWebview,
      page: () => const PaymentWebView(),
    ),
    GetPage(
      name: AppRoutes.lottery,
      page: () => const LotteryView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LotteryController>()) {
          Get.put(LotteryController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.lotteryDraw,
      page: () => const LotteryDrawPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LotteryDrawController>()) {
          Get.put(LotteryDrawController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.completedEkubs,
      page: () => const CompletedEkubsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CompletedEkubsController>()) {
          Get.put(CompletedEkubsController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const FaqView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<FaqController>()) {
          Get.put(FaqController());
        }
      }),
    ),

    GetPage(
      name: AppRoutes.createGroup,
      page: () => const CreateGroupView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CreateGroupController>()) {
          Get.put(CreateGroupController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<TermsConditionsController>()) {
          Get.put(TermsConditionsController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PrivacyPolicyController>()) {
          Get.put(PrivacyPolicyController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
    ),
  ];

  // Keep generateRoute for backward compatibility if needed
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

      case AppRoutes.categoryDetail:
        final category = settings.arguments as category_models.Category?;
        if (category == null) {
          // If no category provided, return error page
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Category not found'))),
          );
        }
        if (!Get.isRegistered<CategoryDetailController>()) {
          Get.put(CategoryDetailController(category: category));
        } else {
          // Update existing controller with new category
          Get.find<CategoryDetailController>().category.value = category;
          Get.find<CategoryDetailController>().loadGroups();
        }
        return MaterialPageRoute(
          builder: (_) => const CategoryDetailView(),
          settings: settings,
        );

      case AppRoutes.groupDetail:
        final group = settings.arguments as Group?;
        if (group == null) {
          // If no group provided, return error page
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Group not found'))),
          );
        }
        if (!Get.isRegistered<GroupDetailController>()) {
          Get.put(GroupDetailController(group: group));
        } else {
          // Controller already exists, but we can't update it since group is not reactive
          // So we'll create a new instance
          Get.delete<GroupDetailController>();
          Get.put(GroupDetailController(group: group));
        }
        return MaterialPageRoute(
          builder: (_) => const GroupDetailView(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
