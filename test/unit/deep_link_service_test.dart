// Purpose: Test deep link functionality
// Tests the DeepLinkService parsing and routing capabilities

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/deep_link_model.dart';
import 'package:et_digital_equb/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService Tests', () {
    late DeepLinkService deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkService();
    });

    test('Generate invitation links correctly', () {
      final groupId = 'test-group-id';
      final inviteCode = 'test-invite-code';

      final customLink = deepLinkService.generateInvitationLink(
        groupId,
        
      );
      final universalLink = deepLinkService.generateInvitationLink(
        groupId,
        
      );

      expect(
        customLink,
        equals('etequb://invite?groupId=$groupId&code=$inviteCode'),
      );
      expect(
        universalLink,
        equals('https://etequb.com/invite/$groupId?code=$inviteCode'),
      );
    });

    test('DeepLinkModel creates correctly', () {
      final model = DeepLinkModel(
        type: DeepLinkType.invitation,
        path: '/invite/test-group',
        parameters: {'groupId': 'test-group-id', 'code': 'invite-code'},
        groupId: 'test-group-id',
        inviteCode: 'invite-code',
      );

      expect(model.type, equals(DeepLinkType.invitation));
      expect(model.path, equals('/invite/test-group'));
      expect(model.groupId, equals('test-group-id'));
      expect(model.inviteCode, equals('invite-code'));
    });

    test('DeepLinkModel handles unknown types', () {
      final model = DeepLinkModel(
        type: DeepLinkType.unknown,
        path: '/unknown/path',
        parameters: {},
      );

      expect(model.type, equals(DeepLinkType.unknown));
      expect(model.path, equals('/unknown/path'));
    });
  });
}
