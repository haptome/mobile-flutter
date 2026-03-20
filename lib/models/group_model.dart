// Purpose: Group model
// Author: Auto-generated

import 'package:et_digital_equb/core/extensions/number_formatting.dart';

import 'category_model.dart' as category_models;

class Group {
  final String id;
  final String name;
  final String type; // 'public', 'private', 'invite'
  final String? leaderId;
  final String? categoryId;
  final double contributionAmount;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final int minMembers;
  final int targetMembers;
  final int currentMembers;
  final DateTime? startDate;
  final String rotationMethod; // 'sequential', 'random', 'bidding'
  final double serviceChargePercent;
  final String status; // 'draft', 'pending', 'active', 'completed', 'suspended'
  final DateTime createdAt;
  final category_models.Category? category;

  Group({
    required this.id,
    required this.name,
    required this.type,
    this.leaderId,
    this.categoryId,
    required this.contributionAmount,
    required this.frequency,
    required this.minMembers,
    required this.targetMembers,
    required this.currentMembers,
    this.startDate,
    required this.rotationMethod,
    required this.serviceChargePercent,
    required this.status,
    required this.createdAt,
    this.category,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    // helpers to safely parse numbers that may come as strings
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) {
        if (!v.isFinite) return 0.0; // Handle Infinity and NaN
        return v.toDouble();
      }
      if (v is String) {
        final parsed = double.tryParse(v) ?? 0.0;
        if (!parsed.isFinite) return 0.0; // Handle Infinity and NaN
        return parsed;
      }
      return 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) {
        if (!v.isFinite) return 0; // Handle Infinity and NaN
        return v.toInt();
      }
      if (v is String) {
        final parsed = int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
        if (parsed.isInfinite || parsed.isNaN) return 0; // Handle special values
        return parsed;
      }
      return 0;
    }

    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      leaderId: json['leader_id'] as String?,
      categoryId: json['category_id'] as String?,
      contributionAmount: parseDouble(json['contribution_amount']),
      frequency: json['frequency'] as String,
      minMembers: parseInt(json['min_members']),
      targetMembers: parseInt(json['target_members']),
      currentMembers: parseInt(json['current_members']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      rotationMethod: json['rotation_method'] as String,
      serviceChargePercent: parseDouble(json['service_charge_percent']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['category'] != null
          ? category_models.Category.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'leader_id': leaderId,
      'category_id': categoryId,
      'contribution_amount': contributionAmount,
      'frequency': frequency,
      'min_members': minMembers,
      'target_members': targetMembers,
      'current_members': currentMembers,
      'start_date': startDate?.toIso8601String(),
      'rotation_method': rotationMethod,
      'service_charge_percent': serviceChargePercent,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'category': category?.toJson(),
    };
  }
}

// In-kind group model (extends Group with additional fields)
class InKindGroup {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? inventoryItemId;
  final String? inventoryItemName;
  final String? inventoryItemImageUrl;
  final String type;
  final String? leaderId;
  final String? categoryId;
  final double contributionAmount;
  final String frequency;
  final int minMembers;
  final int targetMembers;
  final int currentMembers;
  final DateTime? startDate;
  final String rotationMethod;
  final double serviceChargePercent;
  final String status;
  final DateTime createdAt;
  final category_models.Category? category;

  InKindGroup({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.inventoryItemId,
    this.inventoryItemName,
    this.inventoryItemImageUrl,
    required this.type,
    this.leaderId,
    this.categoryId,
    required this.contributionAmount,
    required this.frequency,
    required this.minMembers,
    required this.targetMembers,
    required this.currentMembers,
    this.startDate,
    required this.rotationMethod,
    required this.serviceChargePercent,
    required this.status,
    required this.createdAt,
    this.category,
  });

  factory InKindGroup.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) {
        if (!v.isFinite) return 0.0; // Handle Infinity and NaN
        return v.toDouble();
      }
      if (v is String) {
        final parsed = double.tryParse(v) ?? 0.0;
        if (!parsed.isFinite) return 0.0; // Handle Infinity and NaN
        return parsed;
      }
      return 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) {
        if (!v.isFinite) return 0; // Handle Infinity and NaN
        return v.toInt();
      }
      if (v is String) {
        final parsed = int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
        if (parsed.isInfinite || parsed.isNaN) return 0; // Handle special values
        return parsed;
      }
      return 0;
    }

    return InKindGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      inventoryItemId: json['inventory_item_id'] as String?,
      inventoryItemName: json['inventory_item_name'] as String?,
      inventoryItemImageUrl: json['inventory_item_image_url'] as String?,
      type: json['type'] as String,
      leaderId: json['leader_id'] as String?,
      categoryId: json['category_id'] as String?,
      contributionAmount: parseDouble(json['contribution_amount']),
      frequency: json['frequency'] as String,
      minMembers: parseInt(json['min_members']),
      targetMembers: parseInt(json['target_members']),
      currentMembers: parseInt(json['current_members']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      rotationMethod: json['rotation_method'] as String,
      serviceChargePercent: parseDouble(json['service_charge_percent']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['category'] != null
          ? category_models.Category.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
