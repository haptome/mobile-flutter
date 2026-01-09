// Purpose: Group service for fetching categories and groups
// Author: Auto-generated

import 'package:dio/dio.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/models/api_response.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:et_digital_equb/models/group_model.dart';
import 'package:et_digital_equb/models/member_model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';

class GroupService extends GetxService {
  static GroupService get to => Get.find();

  final ApiService _apiService = ApiService.to;

  /// Fetch all categories with optional filters
  Future<ApiResponse<List<category_models.Category>>> getCategories({
    String? categoryType,
    bool? isActive,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (categoryType != null) {
        queryParams['category_type'] = categoryType;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _apiService.groupDio.get(
        '/categories',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final categories = data
            .map(
              (item) => category_models.Category.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

        return ApiResponse<List<category_models.Category>>(
          success: true,
          data: categories,
          message:
              response.data['message'] as String? ??
              'Categories fetched successfully',
        );
      } else {
        return ApiResponse<List<category_models.Category>>(
          success: false,
          data: null,
          message:
              response.data['message'] as String? ??
              'Failed to fetch categories',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: ${e.message}');
      }
      return ApiResponse<List<category_models.Category>>(
        success: false,
        data: null,
        message:
            e.response?.data['message'] as String? ??
            'Failed to fetch categories',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      return ApiResponse<List<category_models.Category>>(
        success: false,
        data: null,
        message: 'Failed to fetch categories',
      );
    }
  }

  /// Fetch a single category by ID
  Future<ApiResponse<category_models.Category>> getCategoryById(
    String categoryId,
  ) async {
    try {
      final response = await _apiService.groupDio.get(
        '/categories/$categoryId',
      );

      if (response.data['success'] == true) {
        final category = category_models.Category.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        return ApiResponse(
          success: true,
          data: category,
          message:
              response.data['message'] as String? ??
              'Category fetched successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] as String? ?? 'Failed to fetch category',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching category: ${e.message}');
      }
      return ApiResponse(
        success: false,
        message:
            e.response?.data['message'] as String? ??
            'Failed to fetch category',
      );
    }
  }

  /// Fetch cash groups with optional filters
  Future<ApiResponse<List<Group>>> getGroups({
    String? categoryId,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.groupDio.get(
        '/groups',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final groups = data
            .map((item) => Group.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          success: true,
          data: groups,
          message:
              response.data['message'] as String? ??
              'Groups fetched successfully',
        );
      } else {
        return ApiResponse<List<Group>>(
          success: false,
          data: null,
          message:
              response.data['message'] as String? ?? 'Failed to fetch groups',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching groups: ${e.message}');
      }
      return ApiResponse<List<Group>>(
        success: false,
        data: null,
        message:
            e.response?.data['message'] as String? ?? 'Failed to fetch groups',
      );
    }
  }

  /// Fetch a single group by ID
  Future<ApiResponse<Group>> getGroupById(String groupId) async {
    try {
      final response = await _apiService.groupDio.get('/groups/$groupId');

      if (response.data['success'] == true) {
        final group = Group.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        return ApiResponse(
          success: true,
          data: group,
          message:
              response.data['message'] as String? ??
              'Group fetched successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] as String? ?? 'Failed to fetch group',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching group: ${e.message}');
      }
      return ApiResponse(
        success: false,
        message:
            e.response?.data['message'] as String? ?? 'Failed to fetch group',
      );
    }
  }

  /// Join a group
  Future<ApiResponse<void>> joinGroup(
    String groupId, {
    required bool acceptTerms,
  }) async {
    try {
      final response = await _apiService.groupDio.post(
        '/groups/$groupId/join',
        data: {'accept_terms': acceptTerms},
      );

      if (response.data['success'] == true) {
        return ApiResponse(
          success: true,
          message:
              response.data['data']?['message'] as String? ??
              'Successfully joined group',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] as String? ?? 'Failed to join group',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error joining group: ${e.message}');
      }
      return ApiResponse(
        success: false,
        message:
            e.response?.data['message'] as String? ?? 'Failed to join group',
      );
    }
  }

  /// Fetch in-kind groups
  /// Get user's groups (groups where user is a member)
  Future<ApiResponse<List<Group>>> getUserGroups({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.groupDio.get(
        '/groups/members/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final groups = data
            .map((item) => Group.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Group>>(
          success: true,
          data: groups,
          message:
              response.data['message'] as String? ??
              'User groups fetched successfully',
        );
      } else {
        return ApiResponse<List<Group>>(
          success: false,
          data: null,
          message:
              response.data['message'] as String? ??
              'Failed to fetch user groups',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching user groups: ${e.message}');
      }
      return ApiResponse<List<Group>>(
        success: false,
        data: null,
        message:
            e.response?.data['message'] as String? ??
            'Failed to fetch user groups',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user groups: $e');
      }
      return ApiResponse<List<Group>>(
        success: false,
        data: null,
        message: 'Failed to fetch user groups',
      );
    }
  }

  /// Get user's in-kind groups
  Future<ApiResponse<List<InKindGroup>>> getUserInKindGroups() async {
    try {
      final response = await _apiService.groupDio.get(
        '/in-kind-groups/my-groups',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final groups = data
            .map((item) => InKindGroup.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<InKindGroup>>(
          success: true,
          data: groups,
          message:
              response.data['message'] as String? ??
              'User in-kind groups fetched successfully',
        );
      } else {
        return ApiResponse<List<InKindGroup>>(
          success: false,
          data: null,
          message:
              response.data['message'] as String? ??
              'Failed to fetch user in-kind groups',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching user in-kind groups: ${e.message}');
      }
      return ApiResponse<List<InKindGroup>>(
        success: false,
        data: null,
        message:
            e.response?.data['message'] as String? ??
            'Failed to fetch user in-kind groups',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user in-kind groups: $e');
      }
      return ApiResponse<List<InKindGroup>>(
        success: false,
        data: null,
        message: 'Failed to fetch user in-kind groups',
      );
    }
  }

  Future<ApiResponse<List<InKindGroup>>> getInKindGroups({
    String? categoryId,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.groupDio.get(
        '/in-kind-groups',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final groups = data
            .map((item) => InKindGroup.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          success: true,
          data: groups,
          message:
              response.data['message'] as String? ??
              'In-kind groups fetched successfully',
        );
      } else {
        return ApiResponse<List<InKindGroup>>(
          success: false,
          data: null,
          message:
              response.data['message'] as String? ??
              'Failed to fetch in-kind groups',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching in-kind groups: ${e.message}');
      }
      return ApiResponse<List<InKindGroup>>(
        success: false,
        data: null,
        message:
            e.response?.data['message'] as String? ??
            'Failed to fetch in-kind groups',
      );
    }
  }

  /// Fetch members of a specific group
  Future<ApiResponse<List<GroupMember>>> getGroupMembers(
    String groupId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.groupDio.get(
        '/groups/$groupId/members',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final members = data
            .map((item) => GroupMember.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<GroupMember>>(
          success: true,
          data: members,
          message:
              response.data['message'] as String? ??
              'Group members fetched successfully',
        );
      } else {
        return ApiResponse<List<GroupMember>>(
          success: false,
          data: null,
          message:
              response.data['message'] as String? ??
              'Failed to fetch group members',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error fetching group members: ${e.message}');
      }
      return ApiResponse<List<GroupMember>>(
        success: false,
        data: null,
        message:
            e.response?.data['message'] as String? ??
            'Failed to fetch group members',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching group members: $e');
      }
      return ApiResponse<List<GroupMember>>(
        success: false,
        data: null,
        message: 'Failed to fetch group members',
      );
    }
  }

  /// Generate an invite link for a group
  Future<ApiResponse<String>> generateInviteLink(String groupId) async {
    try {
      // For now, we'll return a mock invite link
      // In the future, this will call the actual backend endpoint
      return ApiResponse<String>(
        success: true,
        data: 'https://et-ekub.com/join-group/$groupId',
        message: 'Invite link generated successfully',
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        data: null,
        message: 'Failed to generate invite link',
      );
    }
  }

  /// Create a new group
  Future<ApiResponse<void>> createGroup({
    required String name,
    required int contributionAmount,
    required String frequency,
    required int targetMembers,
    required int minMembers,
    required String type,
    required String rotationMethod,
    required double serviceChargePercent,
    String? startDate,
    required String leaderId,
    required int durationMonths,
  }) async {
    try {
      final response = await _apiService.groupDio.post(
        '/groups',
        data: {
          'name': name,
          'contribution_amount': contributionAmount,
          'frequency': frequency,
          'target_members': targetMembers,
          'min_members': minMembers,
          'type': type,
          'rotation_method': rotationMethod,
          'service_charge_percent': serviceChargePercent,
          if (startDate != null) 'start_date': startDate,
          'leader_id': leaderId,
          'duration_months': durationMonths,
        },
      );

      if (response.data['success'] == true) {
        return ApiResponse(
          success: true,
          message:
              response.data['message'] as String? ??
              'Group created successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] as String? ?? 'Failed to create group',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error creating group: ${e.message}');
      }
      return ApiResponse(
        success: false,
        message:
            e.response?.data['message'] as String? ?? 'Failed to create group',
      );
    }
  }
}
