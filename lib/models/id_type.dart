// Purpose: ID type models for KYC ID capture flow
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'package:flutter/material.dart';

/// Enum representing the types of ID documents that can be captured
enum IDType {
  nationalId,
  driverLicense,
  passport,
}

/// Class containing display information and properties for each ID type
class IDTypeInfo {
  final IDType type;
  final String displayName;
  final String description;
  final IconData icon;
  final bool requiresBackSide;
  final double aspectRatio; // width/height

  const IDTypeInfo({
    required this.type,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.requiresBackSide,
    required this.aspectRatio,
  });

  /// Get IDTypeInfo for a specific IDType
  static IDTypeInfo forType(IDType type) {
    switch (type) {
      case IDType.nationalId:
        return nationalId;
      case IDType.driverLicense:
        return driverLicense;
      case IDType.passport:
        return passport;
    }
  }

  /// Get IDTypeInfo from IDType (alias for forType)
  static IDTypeInfo fromType(IDType type) => forType(type);

  /// National ID type info
  static const IDTypeInfo nationalId = IDTypeInfo(
    type: IDType.nationalId,
    displayName: 'National ID',
    description: 'Government-issued national identification card',
    icon: Icons.credit_card,
    requiresBackSide: true,
    aspectRatio: 1.6, // 16:10 aspect ratio
  );

  /// Driver License type info
  static const IDTypeInfo driverLicense = IDTypeInfo(
    type: IDType.driverLicense,
    displayName: 'Driver License',
    description: 'Valid driver\'s license',
    icon: Icons.drive_eta,
    requiresBackSide: true,
    aspectRatio: 1.6, // 16:10 aspect ratio
  );

  /// Passport type info
  static const IDTypeInfo passport = IDTypeInfo(
    type: IDType.passport,
    displayName: 'Passport',
    description: 'International passport',
    icon: Icons.book,
    requiresBackSide: false,
    aspectRatio: 0.75, // 3:4 aspect ratio
  );

  /// Get all available ID types
  static List<IDTypeInfo> get allTypes => [
        nationalId,
        driverLicense,
        passport,
      ];
}
