// Purpose: Application routes configuration
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/your_ekubs_binding.dart';
import '../bindings/payment_binding.dart';
import '../bindings/upcoming_payments_binding.dart';
import '../bindings/lottery_binding.dart';
import '../bindings/completed_ekubs_binding.dart';
import '../bindings/faq_binding.dart';
import '../bindings/transactions_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/account_setting_binding.dart';
import '../bindings/ekub_type_binding.dart';
import '../bindings/in_kind_binding.dart';
import '../bindings/duration_binding.dart';
import '../bindings/terms_conditions_binding.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/otp_verify_view.dart';
import '../views/home/home_view.dart';
import '../views/your_ekubs/your_ekubs_view.dart';
import '../views/payment/select_payment_method_view.dart';
import '../views/payment/upcoming_payments_view.dart';
import '../views/lottery/lottery_view.dart';
import '../views/completed_ekubs/completed_ekubs_view.dart';
import '../views/help/faq_view.dart';
import '../views/transactions/transactions_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/account_setting_view.dart';
import '../views/ekub/ekub_type_view.dart';
import '../views/in_kind/in_kind_view.dart';
import '../views/duration/duration_view.dart';
import '../views/terms/terms_conditions_view.dart';
import '../views/splash/splash_view.dart';

class AppPages {
  AppPages._();

  static const initial = '/splash';

  static final routes = [
    // Splash
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
    ),

    // Auth
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/otp-verify',
      page: () => const OtpVerifyView(),
      binding: AuthBinding(),
    ),

    // Home
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // Your Ekubs
    GetPage(
      name: '/your-ekubs',
      page: () => const YourEkubsView(),
      binding: YourEkubsBinding(),
    ),

    // Payment
    GetPage(
      name: '/select-payment-method',
      page: () => const SelectPaymentMethodView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: '/upcoming-payments',
      page: () => const UpcomingPaymentsView(),
      binding: UpcomingPaymentsBinding(),
    ),

    // Lottery
    GetPage(
      name: '/lottery',
      page: () => const LotteryView(),
      binding: LotteryBinding(),
    ),

    // Completed Ekubs
    GetPage(
      name: '/completed-ekubs',
      page: () => const CompletedEkubsView(),
      binding: CompletedEkubsBinding(),
    ),

    // FAQ/Help
    GetPage(
      name: '/faq',
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),

    // Transactions
    GetPage(
      name: '/transactions',
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),

    // Profile
    GetPage(
      name: '/profile',
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: '/account-setting',
      page: () => const AccountSettingView(),
      binding: AccountSettingBinding(),
    ),

    // Ekub Type
    GetPage(
      name: '/ekub-type',
      page: () => const EkubTypeView(),
      binding: EkubTypeBinding(),
    ),

    // In-Kind
    GetPage(
      name: '/in-kind',
      page: () => const InKindView(),
      binding: InKindBinding(),
    ),

    // Duration
    GetPage(
      name: '/duration',
      page: () => const DurationView(),
      binding: DurationBinding(),
    ),

    // Terms & Conditions
    GetPage(
      name: '/terms-conditions',
      page: () => const TermsConditionsView(),
      binding: TermsConditionsBinding(),
    ),
  ];
}

