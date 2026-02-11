// Purpose: Unit tests for IDType model
// Author: Kiro AI
// Linked Spec: KYC ID & Liveness Flow Redesign

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/models/id_type.dart';

void main() {
  group('IDType enum', () {
    test('should have three ID types', () {
      expect(IDType.values.length, 3);
      expect(IDType.values, contains(IDType.nationalId));
      expect(IDType.values, contains(IDType.driverLicense));
      expect(IDType.values, contains(IDType.passport));
    });
  });

  group('IDTypeInfo', () {
    test('should return correct info for National ID', () {
      final info = IDTypeInfo.forType(IDType.nationalId);
      
      expect(info.type, IDType.nationalId);
      expect(info.displayName, 'National ID');
      expect(info.description, 'Government-issued national identification card');
      expect(info.requiresBackSide, true);
      expect(info.aspectRatio, 1.6);
    });

    test('should return correct info for Driver License', () {
      final info = IDTypeInfo.forType(IDType.driverLicense);
      
      expect(info.type, IDType.driverLicense);
      expect(info.displayName, 'Driver License');
      expect(info.description, 'Valid driver\'s license');
      expect(info.requiresBackSide, true);
      expect(info.aspectRatio, 1.6);
    });

    test('should return correct info for Passport', () {
      final info = IDTypeInfo.forType(IDType.passport);
      
      expect(info.type, IDType.passport);
      expect(info.displayName, 'Passport');
      expect(info.description, 'International passport');
      expect(info.requiresBackSide, false);
      expect(info.aspectRatio, 0.75);
    });

    test('should return all three ID types', () {
      final allTypes = IDTypeInfo.allTypes;
      
      expect(allTypes.length, 3);
      expect(allTypes[0].type, IDType.nationalId);
      expect(allTypes[1].type, IDType.driverLicense);
      expect(allTypes[2].type, IDType.passport);
    });

    test('National ID and Driver License should have same aspect ratio', () {
      final nationalIdInfo = IDTypeInfo.forType(IDType.nationalId);
      final driverLicenseInfo = IDTypeInfo.forType(IDType.driverLicense);
      
      expect(nationalIdInfo.aspectRatio, driverLicenseInfo.aspectRatio);
    });

    test('Passport should have different aspect ratio than cards', () {
      final passportInfo = IDTypeInfo.forType(IDType.passport);
      final nationalIdInfo = IDTypeInfo.forType(IDType.nationalId);
      
      expect(passportInfo.aspectRatio, isNot(nationalIdInfo.aspectRatio));
    });

    test('Only passport should not require back side', () {
      final nationalIdInfo = IDTypeInfo.forType(IDType.nationalId);
      final driverLicenseInfo = IDTypeInfo.forType(IDType.driverLicense);
      final passportInfo = IDTypeInfo.forType(IDType.passport);
      
      expect(nationalIdInfo.requiresBackSide, true);
      expect(driverLicenseInfo.requiresBackSide, true);
      expect(passportInfo.requiresBackSide, false);
    });
  });
}
