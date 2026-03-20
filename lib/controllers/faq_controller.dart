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

  List<String> get tabs => ['view_all'.tr, 'top_questions'.tr, 'getting_started'.tr, 'pricing'.tr, 'safety_money'.tr, 'circles'.tr];

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
    allFaqs.value = [
      // Top Questions
      {
        'id': '1',
        'question': 'faq_q1',
        'answer': 'faq_a1',
        'category': 'top_questions',
        'usersAsked': 25,
        'userAvatars': [],
      },
      {
        'id': '24',
        'question': 'faq_q24',
        'answer': 'faq_a24',
        'category': 'top_questions',
        'usersAsked': 22,
        'userAvatars': [],
      },
      {
        'id': '3',
        'question': 'faq_q3',
        'answer': 'faq_a3',
        'category': 'top_questions',
        'usersAsked': 20,
        'userAvatars': [],
      },
      {
        'id': '16',
        'question': 'faq_q16',
        'answer': 'faq_a16',
        'category': 'top_questions',
        'usersAsked': 18,
        'userAvatars': [],
      },
      {
        'id': '29',
        'question': 'faq_q29',
        'answer': 'faq_a29',
        'category': 'top_questions',
        'usersAsked': 16,
        'userAvatars': [],
      },
      
      // Getting Started
      {
        'id': '2',
        'question': 'faq_q2',
        'answer': 'faq_a2',
        'category': 'getting_started',
        'usersAsked': 15,
        'userAvatars': [],
      },
      {
        'id': '9',
        'question': 'faq_q9',
        'answer': 'faq_a9',
        'category': 'getting_started',
        'usersAsked': 14,
        'userAvatars': [],
      },
      {
        'id': '13',
        'question': 'faq_q13',
        'answer': 'faq_a13',
        'category': 'getting_started',
        'usersAsked': 13,
        'userAvatars': [],
      },
      {
        'id': '20',
        'question': 'faq_q20',
        'answer': 'faq_a20',
        'category': 'getting_started',
        'usersAsked': 12,
        'userAvatars': [],
      },
      {
        'id': '21',
        'question': 'faq_q21',
        'answer': 'faq_a21',
        'category': 'getting_started',
        'usersAsked': 11,
        'userAvatars': [],
      },
      {
        'id': '22',
        'question': 'faq_q22',
        'answer': 'faq_a22',
        'category': 'getting_started',
        'usersAsked': 10,
        'userAvatars': [],
      },
      {
        'id': '23',
        'question': 'faq_q23',
        'answer': 'faq_a23',
        'category': 'getting_started',
        'usersAsked': 9,
        'userAvatars': [],
      },
      
      // Pricing
      {
        'id': '17',
        'question': 'faq_q17',
        'answer': 'faq_a17',
        'category': 'pricing',
        'usersAsked': 14,
        'userAvatars': [],
      },
      {
        'id': '18',
        'question': 'faq_q18',
        'answer': 'faq_a18',
        'category': 'pricing',
        'usersAsked': 8,
        'userAvatars': [],
      },
      {
        'id': '19',
        'question': 'faq_q19',
        'answer': 'faq_a19',
        'category': 'pricing',
        'usersAsked': 7,
        'userAvatars': [],
      },
      {
        'id': '27',
        'question': 'faq_q27',
        'answer': 'faq_a27',
        'category': 'pricing',
        'usersAsked': 6,
        'userAvatars': [],
      },
      
      // Safety & Money
      {
        'id': '25',
        'question': 'faq_q25',
        'answer': 'faq_a25',
        'category': 'safety_money',
        'usersAsked': 13,
        'userAvatars': [],
      },
      {
        'id': '26',
        'question': 'faq_q26',
        'answer': 'faq_a26',
        'category': 'safety_money',
        'usersAsked': 10,
        'userAvatars': [],
      },
      {
        'id': '28',
        'question': 'faq_q28',
        'answer': 'faq_a28',
        'category': 'safety_money',
        'usersAsked': 5,
        'userAvatars': [],
      },
      {
        'id': '4',
        'question': 'faq_q4',
        'answer': 'faq_a4',
        'category': 'safety_money',
        'usersAsked': 12,
        'userAvatars': [],
      },
      {
        'id': '7',
        'question': 'faq_q7',
        'answer': 'faq_a7',
        'category': 'safety_money',
        'usersAsked': 11,
        'userAvatars': [],
      },
      
      // Circles
      {
        'id': '30',
        'question': 'faq_q30',
        'answer': 'faq_a30',
        'category': 'circles',
        'usersAsked': 9,
        'userAvatars': [],
      },
      {
        'id': '31',
        'question': 'faq_q31',
        'answer': 'faq_a31',
        'category': 'circles',
        'usersAsked': 8,
        'userAvatars': [],
      },
      {
        'id': '32',
        'question': 'faq_q32',
        'answer': 'faq_a32',
        'category': 'circles',
        'usersAsked': 7,
        'userAvatars': [],
      },
      {
        'id': '15',
        'question': 'faq_q15',
        'answer': 'faq_a15',
        'category': 'circles',
        'usersAsked': 6,
        'userAvatars': [],
      },
      {
        'id': '11',
        'question': 'faq_q11',
        'answer': 'faq_a11',
        'category': 'circles',
        'usersAsked': 5,
        'userAvatars': [],
      },
      {
        'id': '5',
        'question': 'faq_q5',
        'answer': 'faq_a5',
        'category': 'circles',
        'usersAsked': 10,
        'userAvatars': [],
      },
      {
        'id': '6',
        'question': 'faq_q6',
        'answer': 'faq_a6',
        'category': 'circles',
        'usersAsked': 9,
        'userAvatars': [],
      },
      
      // Additional questions for other categories
      {
        'id': '8',
        'question': 'faq_q8',
        'answer': 'faq_a8',
        'category': 'pricing',
        'usersAsked': 11,
        'userAvatars': [],
      },
      {
        'id': '10',
        'question': 'faq_q10',
        'answer': 'faq_a10',
        'category': 'circles',
        'usersAsked': 8,
        'userAvatars': [],
      },
      {
        'id': '12',
        'question': 'faq_q12',
        'answer': 'faq_a12',
        'category': 'getting_started',
        'usersAsked': 4,
        'userAvatars': [],
      },
      {
        'id': '14',
        'question': 'faq_q14',
        'answer': 'faq_a14',
        'category': 'getting_started',
        'usersAsked': 3,
        'userAvatars': [],
      },
      
      // Diaspora
      {
        'id': '33',
        'question': 'faq_q33',
        'answer': 'faq_a33',
        'category': 'diaspora',
        'usersAsked': 12,
        'userAvatars': [],
      },
      {
        'id': '34',
        'question': 'faq_q34',
        'answer': 'faq_a34',
        'category': 'diaspora',
        'usersAsked': 10,
        'userAvatars': [],
      },
      {
        'id': '35',
        'question': 'faq_q35',
        'answer': 'faq_a35',
        'category': 'diaspora',
        'usersAsked': 8,
        'userAvatars': [],
      },
      
      // Corporate
      {
        'id': '36',
        'question': 'faq_q36',
        'answer': 'faq_a36',
        'category': 'corporate',
        'usersAsked': 7,
        'userAvatars': [],
      },
      {
        'id': '37',
        'question': 'faq_q37',
        'answer': 'faq_a37',
        'category': 'corporate',
        'usersAsked': 6,
        'userAvatars': [],
      },
      {
        'id': '38',
        'question': 'faq_q38',
        'answer': 'faq_a38',
        'category': 'corporate',
        'usersAsked': 5,
        'userAvatars': [],
      },
      {
        'id': '39',
        'question': 'faq_q39',
        'answer': 'faq_a39',
        'category': 'corporate',
        'usersAsked': 4,
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
    } else if (selectedTabIndex.value == 3) {
      // Pricing
      filtered = filtered
          .where((faq) => faq['category'] == 'pricing')
          .toList();
    } else if (selectedTabIndex.value == 4) {
      // Safety & Money
      filtered = filtered
          .where((faq) => faq['category'] == 'safety_money')
          .toList();
    } else if (selectedTabIndex.value == 5) {
      // Circles
      filtered = filtered
          .where((faq) => faq['category'] == 'circles')
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

