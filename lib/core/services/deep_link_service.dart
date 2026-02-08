// Purpose: Deep link handling utility for invitation links and other deep linking functionality
// Author: Generated for ET Digital Equb
// Handles parsing and routing of deep links throughout the application

import 'dart:async';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/deep_link_model.dart';

class DeepLinkService extends GetxService {
  static DeepLinkService get to => Get.find();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final Rx<DeepLinkModel?> _currentLink = Rx<DeepLinkModel?>(null);

  DeepLinkModel? get currentLink => _currentLink.value;

  @override
  void onInit() {
    super.onInit();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  /// Initialize deep link listening
  void _initDeepLinks() {
    // Listen to incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        print('Deep link error: $err');
      },
    );

    // Check for initial link when app starts
    _checkInitialLink();
  }

  /// Check for initial deep link when app launches
  Future<void> _checkInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  /// Handle incoming deep link URI
  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;

    print('Received deep link: $uri');

    final linkModel = _parseDeepLink(uri);
    if (linkModel != null) {
      _currentLink.value = linkModel;
      _routeToDestination(linkModel);
    }
  }

  /// Parse URI into DeepLinkModel
  DeepLinkModel? _parseDeepLink(Uri uri) {
    try {
      // Handle custom scheme links (etequb://)
      if (uri.scheme == 'etequb') {
        return _parseCustomSchemeLink(uri);
      }

      // Handle universal links (https://etequb.com)
      if (uri.host.contains('etequb.com')) {
        return _parseUniversalLink(uri);
      }

      return null;
    } catch (e) {
      print('Error parsing deep link: $e');
      return null;
    }
  }

  /// Parse custom scheme links (etequb://)
  DeepLinkModel _parseCustomSchemeLink(Uri uri) {
    final path = uri.pathSegments;

    if (path.isNotEmpty) {
      switch (path[0]) {
        case 'invite':
          return DeepLinkModel(
            type: DeepLinkType.invitation,
            path: uri.path,
            parameters: uri.queryParameters,
            groupId: uri.queryParameters['groupId'],
            inviteCode: uri.queryParameters['code'],
          );

        case 'group':
          return DeepLinkModel(
            type: DeepLinkType.groupDetail,
            path: uri.path,
            parameters: uri.queryParameters,
            groupId: path.length > 1 ? path[1] : null,
          );

        case 'payment':
          return DeepLinkModel(
            type: DeepLinkType.payment,
            path: uri.path,
            parameters: uri.queryParameters,
            paymentId: uri.queryParameters['id'],
          );

        default:
          return DeepLinkModel(
            type: DeepLinkType.unknown,
            path: uri.path,
            parameters: uri.queryParameters,
          );
      }
    }

    return DeepLinkModel(
      type: DeepLinkType.unknown,
      path: uri.path,
      parameters: uri.queryParameters,
    );
  }

  /// Parse universal links (HTTPS)
  DeepLinkModel _parseUniversalLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty) {
      switch (pathSegments[0]) {
        case 'invite':
          return DeepLinkModel(
            type: DeepLinkType.invitation,
            path: uri.path,
            parameters: uri.queryParameters,
            groupId: pathSegments.length > 1 ? pathSegments[1] : null,
            inviteCode: uri.queryParameters['code'],
          );

        case 'group':
          return DeepLinkModel(
            type: DeepLinkType.groupDetail,
            path: uri.path,
            parameters: uri.queryParameters,
            groupId: pathSegments.length > 1 ? pathSegments[1] : null,
          );

        case 'payment':
          return DeepLinkModel(
            type: DeepLinkType.payment,
            path: uri.path,
            parameters: uri.queryParameters,
            paymentId: pathSegments.length > 1 ? pathSegments[1] : null,
          );

        default:
          return DeepLinkModel(
            type: DeepLinkType.unknown,
            path: uri.path,
            parameters: uri.queryParameters,
          );
      }
    }

    return DeepLinkModel(
      type: DeepLinkType.unknown,
      path: uri.path,
      parameters: uri.queryParameters,
    );
  }

  /// Route to appropriate destination based on deep link
  void _routeToDestination(DeepLinkModel link) {
    switch (link.type) {
      case DeepLinkType.invitation:
        _handleInvitationLink(link);
        break;

      case DeepLinkType.groupDetail:
        _handleGroupDetailLink(link);
        break;

      case DeepLinkType.payment:
        _handlePaymentLink(link);
        break;

      case DeepLinkType.unknown:
        _handleUnknownLink(link);
        break;
    }
  }

  /// Handle invitation links
  void _handleInvitationLink(DeepLinkModel link) {
    final groupId = link.groupId;
    final inviteCode = link.inviteCode;

    if (groupId == null || inviteCode == null) {
      // Invalid invitation link
      Get.snackbar(
        'Invalid Link',
        'This invitation link is invalid or expired.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check if user is authenticated
    final authService = AuthService.to;
    final storageService = StorageService.to;
    if (!authService.isAuthenticated.value) {
      // Store the invitation data for after login
      storageService.saveString('pending_invitation_group_id', groupId);
      storageService.saveString('pending_invitation_code', inviteCode);

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Invitation Received',
        'Please log in to accept this invitation.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // User is authenticated, navigate to invitation screen
    Get.toNamed(
      '/invitation',
      arguments: {'groupId': groupId, 'inviteCode': inviteCode},
    );
  }

  /// Handle group detail links
  void _handleGroupDetailLink(DeepLinkModel link) {
    final groupId = link.groupId;

    if (groupId == null) {
      Get.snackbar(
        'Invalid Link',
        'Group ID is missing from the link.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to group detail screen
    Get.toNamed(AppRoutes.groupDetail, arguments: {'groupId': groupId});
  }

  /// Handle payment links
  void _handlePaymentLink(DeepLinkModel link) {
    final paymentId = link.paymentId;

    if (paymentId == null) {
      Get.snackbar(
        'Invalid Link',
        'Payment ID is missing from the link.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to payment screen
    Get.toNamed(
      AppRoutes.selectPaymentMethod,
      arguments: {'paymentId': paymentId},
    );
  }

  /// Handle unknown links
  void _handleUnknownLink(DeepLinkModel link) {
    print('Unknown deep link received: ${link.path}');
    Get.snackbar(
      'Unknown Link',
      'This link type is not supported.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Generate invitation link for sharing
  String generateInvitationLink(String groupId, String inviteCode) {
    return 'etequb://invite?groupId=$groupId&code=$inviteCode';
  }

  /// Generate universal link for invitation
  String generateUniversalInvitationLink(String groupId, String inviteCode) {
    return 'https://etequb.com/invite/$groupId?code=$inviteCode';
  }

  /// Launch URL (for sharing invitation links)
  Future<bool> launchUrlExternal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }

  /// Clear current link data
  void clearCurrentLink() {
    _currentLink.value = null;
  }
}
