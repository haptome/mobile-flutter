// Purpose: Home controller
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/core/services/storage_service.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  final AuthService _authService = AuthService.to;
  final GroupService _groupService = GroupService.to;
  final ApiService _apiService = ApiService.to;

  final RxInt currentBottomNavIndex = 0.obs;
  final RxBool isAccountVerified = true.obs; // Set to false to show banner
  final RxList<category_models.Category> cashCategories =
      <category_models.Category>[].obs;
  final RxList<category_models.Category> inKindCategories =
      <category_models.Category>[].obs;
  final RxBool isLoadingCategories = true.obs;
  final RxBool isLoadingInKindCategories = true.obs;
  final RxMap<String, int> durationGroupsCount =
      <String, int>{}.obs; // frequency -> count
  final RxBool isLoadingDuration = true.obs;
  final RxList<Map<String, dynamic>> marketingCampaigns =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCampaigns = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to authentication state changes
    ever(_authService.isAuthenticated, (isAuth) {
      print('HomeController - Auth state changed: $isAuth');
      if (isAuth) {
        // User just logged in, load data
        _loadAllData();
      } else {
        // User logged out, clear data
        _clearData();
      }
    });
    
    // Also load data immediately if already authenticated
    if (_authService.isAuthenticated.value) {
      print('HomeController - Already authenticated, loading data');
      _loadAllData();
    }
  }

  void _loadAllData() {
    print('HomeController._loadAllData - Starting...');
    loadUserData();
    loadCashCategories();
    loadInKindCategories();
    loadDurationGroups();
    loadMarketingCampaigns();
  }

  void _clearData() {
    print('HomeController._clearData - Clearing all data');
    cashCategories.clear();
    inKindCategories.clear();
    durationGroupsCount.clear();
    marketingCampaigns.clear();
    isLoadingCategories.value = false;
    isLoadingInKindCategories.value = false;
    isLoadingDuration.value = false;
    isLoadingCampaigns.value = false;
  }

  Future<void> loadUserData() async {
    try {
      await _authService.getProfile();
      // Check verification status from user data
      final kycStatus = _authService.currentUser.value?.kycStatus;
      isAccountVerified.value = kycStatus == 'approved';
    } catch (e) {
      // Silently handle error for UI-only mode
    }
  }

  Future<void> loadCashCategories() async {
    try {
      print('HomeController.loadCashCategories - Starting...');
      isLoadingCategories.value = true;
      final response = await _groupService.getCategories(
        categoryType: 'cash',
        isActive: true,
        limit: 3, // Only show first 3 categories on home
      );

      print('HomeController.loadCashCategories - Response: ${response.success}');
      if (response.success && response.data != null) {
        cashCategories.value = List<category_models.Category>.from(
          response.data!,
        );
        print('HomeController.loadCashCategories - Loaded ${cashCategories.length} categories');
      }
    } catch (e) {
      // Silently handle error
      print('HomeController.loadCashCategories - Error: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void onBottomNavTap(int index) {
    currentBottomNavIndex.value = index;
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Get.toNamed('/your-ekubs');
        break;
      case 2:
        Get.toNamed('/transactions');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }

  void onVerifyAccountTap() {
    // Navigate to verification page
    Get.toNamed('/verification');
  }

  void logout() {
    _authService.logout();
  }

  void onViewAllEkubTypes() {
    Get.toNamed('/ekub-type');
  }

  void onViewAllInKind() {
    Get.toNamed('/in-kind');
  }

  Future<void> loadInKindCategories() async {
    try {
      isLoadingInKindCategories.value = true;
      final response = await _groupService.getCategories(
        categoryType: 'in_kind',
        isActive: true,
        limit: 3, // Only show first 3 categories on home
      );

      if (response.success && response.data != null) {
        inKindCategories.value = List<category_models.Category>.from(
          response.data!,
        );
      }
    } catch (e) {
      // Silently handle error
    } finally {
      isLoadingInKindCategories.value = false;
    }
  }

  Future<void> loadDurationGroups() async {
    try {
      isLoadingDuration.value = true;
      // Fetch groups to count by frequency
      final response = await _groupService.getGroups(
        status: 'active',
        limit: 100, // Get more groups to count frequencies
      );

      if (response.success && response.data != null) {
        final groups = response.data!;
        final counts = <String, int>{};

        // Count groups by frequency
        for (var group in groups) {
          final frequency = group.frequency.toLowerCase();
          counts[frequency] = (counts[frequency] ?? 0) + 1;
        }

        durationGroupsCount.value = counts;
      }
    } catch (e) {
      // Silently handle error
    } finally {
      isLoadingDuration.value = false;
    }
  }

  void onCategoryTap(category_models.Category category) {
    Get.toNamed('/category-detail', arguments: category);
  }

  void onInKindCategoryTap(category_models.Category category) {
    Get.toNamed('/category-detail', arguments: category);
  }

  void onDurationTap(String frequency) {
    // Navigate to duration page with frequency filter
    Get.toNamed('/duration', arguments: {'frequency': frequency});
  }

  void onViewAllDuration() {
    Get.toNamed('/duration');
  }

  Future<void> loadMarketingCampaigns() async {
    try {
      print('HomeController.loadMarketingCampaigns - Starting...');
      isLoadingCampaigns.value = true;
      
      final response = await _apiService.dio.get(
        '/users/marketing/campaigns',
      );

      print('HomeController.loadMarketingCampaigns - Response: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final campaigns = response.data['data'] as List<dynamic>?;
        if (campaigns != null && campaigns.isNotEmpty) {
          marketingCampaigns.value = campaigns.map((campaign) {
            return {
              'id': campaign['id'],
              'title': campaign['name'] ?? '',
              'description': campaign['name'] ?? '', // Use name as description fallback
              'image_url': campaign['imagelink'] ?? '',
              'link_url': campaign['link'] ?? '',
              'created_at': campaign['created_at'],
              'creator_name': campaign['creator_name'] ?? '',
            };
          }).toList();
          print('HomeController.loadMarketingCampaigns - Loaded ${marketingCampaigns.length} campaigns');
        } else {
          print('HomeController.loadMarketingCampaigns - No campaigns found');
          marketingCampaigns.clear();
        }
      }
    } catch (e) {
      print('HomeController.loadMarketingCampaigns - Error: $e');
      // Silently handle error, keep empty list
      marketingCampaigns.clear();
    } finally {
      isLoadingCampaigns.value = false;
    }
  }

  void onCampaignTap(Map<String, dynamic> campaign) async {
    final linkUrl = campaign['link_url'] as String?;
    if (linkUrl != null && linkUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(linkUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          Get.snackbar(
            'error'.tr,
            'cannot_open_link'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print('Error launching URL: $e');
        Get.snackbar(
          'error'.tr,
          'invalid_link'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
