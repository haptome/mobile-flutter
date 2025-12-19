// Purpose: Controller for FAQ/Help page
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:get/get.dart';

class FaqController extends GetxController {
  final RxList<Map<String, dynamic>> allFaqs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredFaqs = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxInt currentBottomNavIndex = 1.obs; // Your Ekubs tab

  List<String> get tabs => ['view_all'.tr, 'top_questions'.tr, 'getting_started'.tr];

  @override
  void onInit() {
    super.onInit();
    _loadFaqs();
    // Listen to search query changes
    ever(searchQuery, (_) => _filterFaqs());
    // Listen to tab changes
    ever(selectedTabIndex, (_) => _filterFaqs());
  }

  void _loadFaqs() {
    // Sample data - in real app, this would come from API
    allFaqs.value = [
      {
        'id': '1',
        'question': 'how_to_use_et_equb'.tr,
        'answer': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
        'category': 'top_questions',
        'usersAsked': 4,
        'userAvatars': [],
      },
      {
        'id': '2',
        'question': 'how_to_pay_equb'.tr,
        'answer': 'To pay your Ekub contribution, go to the Payment section, select your payment method, and complete the transaction. You can use Chapa, Arifpay, or other supported payment gateways.',
        'category': 'top_questions',
        'usersAsked': 2,
        'userAvatars': [],
      },
      {
        'id': '3',
        'question': 'how_to_set_password'.tr,
        'answer': 'To set or change your password, go to Settings > Account Settings > Change Password. Enter your current password and set a new secure password.',
        'category': 'getting_started',
        'usersAsked': 1,
        'userAvatars': [],
      },
      {
        'id': '4',
        'question': 'how_to_login_with_email'.tr,
        'answer': 'To login with email, enter your registered email address and password on the login screen. Make sure you have verified your email address first.',
        'category': 'getting_started',
        'usersAsked': 3,
        'userAvatars': [],
      },
    ];
    _filterFaqs();
  }

  void _filterFaqs() {
    List<Map<String, dynamic>> filtered = allFaqs.value;

    // Filter by tab
    if (selectedTabIndex.value == 1) {
      // Top Questions
      filtered = filtered
          .where((faq) => faq['category'] == 'top_questions')
          .toList();
    } else if (selectedTabIndex.value == 2) {
      // Getting Started
      filtered = filtered
          .where((faq) => faq['category'] == 'getting_started')
          .toList();
    }
    // selectedTabIndex.value == 0 means "View all", so no category filter

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((faq) {
            final question = (faq['question'] ?? '').toString().toLowerCase();
            final answer = (faq['answer'] ?? '').toString().toLowerCase();
            return question.contains(query) || answer.contains(query);
          })
          .toList();
    }

    filteredFaqs.value = filtered;
  }

  void onTabSelected(int index) {
    selectedTabIndex.value = index;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onViewAll() {
    selectedTabIndex.value = 0;
  }

  void onBottomNavTap(int index) {
    currentBottomNavIndex.value = index;
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/your-ekubs');
        break;
      case 2:
        Get.toNamed('/transactions');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }
}

