// Purpose: Test CloudinaryConfig class functionality
// Tests the CloudinaryConfig factory methods and validation

import 'package:flutter_test/flutter_test.dart';
import 'package:et_digital_equb/config/cloudinary_config.dart';

void main() {
  group('CloudinaryConfig Tests', () {
    group('forEnvironment() factory method', () {
      test('returns correct config for development environment', () {
        final config = CloudinaryConfig.forEnvironment(Environment.development);

        expect(config.cloudName, equals('dglbocbnt'));
        expect(config.uploadPreset, equals('unsigned_dev_preset'));
        expect(config.apiKey, equals('676919573513538'));
        expect(config.environment, equals(Environment.development));
      });

      test('returns correct config for staging environment', () {
        final config = CloudinaryConfig.forEnvironment(Environment.staging);

        expect(config.cloudName, equals('dglbocbnt'));
        expect(config.uploadPreset, equals('unsigned_staging_preset'));
        expect(config.apiKey, equals('676919573513538'));
        expect(config.environment, equals(Environment.staging));
      });

      test('returns correct config for production environment', () {
        final config = CloudinaryConfig.forEnvironment(Environment.production);

        expect(config.cloudName, equals('dglbocbnt'));
        expect(config.uploadPreset, equals('unsigned_prod_preset'));
        expect(config.apiKey, equals('676919573513538'));
        expect(config.environment, equals(Environment.production));
      });
    });

    group('validate() method', () {
      test('returns true for complete config', () {
        final config = CloudinaryConfig(
          cloudName: 'test_cloud',
          uploadPreset: 'test_preset',
          apiKey: 'test_key',
          environment: Environment.development,
        );

        expect(config.validate(), isTrue);
      });

      test('returns false for missing cloudName', () {
        final config = CloudinaryConfig(
          cloudName: '',
          uploadPreset: 'test_preset',
          apiKey: 'test_key',
          environment: Environment.development,
        );

        expect(config.validate(), isFalse);
      });

      test('returns false for missing uploadPreset', () {
        final config = CloudinaryConfig(
          cloudName: 'test_cloud',
          uploadPreset: '',
          apiKey: 'test_key',
          environment: Environment.development,
        );

        expect(config.validate(), isFalse);
      });

      test('returns false for both cloudName and uploadPreset missing', () {
        final config = CloudinaryConfig(
          cloudName: '',
          uploadPreset: '',
          apiKey: 'test_key',
          environment: Environment.development,
        );

        expect(config.validate(), isFalse);
      });

      test('returns true even if apiKey is empty (not validated)', () {
        final config = CloudinaryConfig(
          cloudName: 'test_cloud',
          uploadPreset: 'test_preset',
          apiKey: '',
          environment: Environment.development,
        );

        // validate() only checks cloudName and uploadPreset
        expect(config.validate(), isTrue);
      });
    });

    group('Environment enum', () {
      test('all environment values are accessible', () {
        expect(Environment.development, isNotNull);
        expect(Environment.staging, isNotNull);
        expect(Environment.production, isNotNull);
      });

      test('environment values can be used in switch statements', () {
        final env = Environment.development;
        String result;

        switch (env) {
          case Environment.development:
            result = 'dev';
            break;
          case Environment.staging:
            result = 'staging';
            break;
          case Environment.production:
            result = 'prod';
            break;
        }

        expect(result, equals('dev'));
      });
    });
  });
}
