// Purpose: Example usage of deep linking functionality
// Demonstrates how to generate and handle invitation links

import 'package:et_digital_equb/core/services/deep_link_service.dart';

void main() {
  // Initialize the deep link service
  final deepLinkService = DeepLinkService();

  // Example: Generate invitation links
  final groupId = 'group-123';
  final inviteCode = 'invite-abc-xyz';

  // Generate custom scheme link (etequb://)
  final customLink = deepLinkService.generateInvitationLink(
    groupId,
   
  );
  print('Custom scheme link: $customLink');
  // Output: etequb://invite?groupId=group-123&code=invite-abc-xyz

  // Generate universal link (HTTPS)
  final universalLink = deepLinkService.generateInvitationLink(
    groupId,
  
  );
  print('Universal link: $universalLink');
  // Output: https://etequb.com/invite/group-123?code=invite-abc-xyz

  // Example: Handle incoming deep links
  // This would typically be handled automatically by the DeepLinkService
  // when the app receives a deep link through app_links package

  print('\nDeep linking setup complete!');
  print('Supported link formats:');
  print('- Custom scheme: etequb://invite?groupId=GROUP_ID&code=INVITE_CODE');
  print(
    '- Universal link: https://etequb.com/invite/GROUP_ID?code=INVITE_CODE',
  );
  print(
    '\nWhen users click these links, they will be directed to the invitation acceptance screen.',
  );
}
