// Purpose: Data model for deep link information
// Author: Generated for ET Digital Equb
// Represents parsed deep link data for routing decisions

enum DeepLinkType { invitation, groupDetail, payment, unknown }

class DeepLinkModel {
  final DeepLinkType type;
  final String path;
  final Map<String, String> parameters;
  final String? groupId;
  final String? inviteCode;
  final String? paymentId;

  DeepLinkModel({
    required this.type,
    required this.path,
    required this.parameters,
    this.groupId,
    this.inviteCode,
    this.paymentId,
  });

  @override
  String toString() {
    return 'DeepLinkModel(type: $type, path: $path, groupId: $groupId, inviteCode: $inviteCode, paymentId: $paymentId)';
  }
}
