import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/utils/form_validators.dart';

void main() {
  group('FormValidators', () {
    group('validateName', () {
      test('returns error when name is empty', () {
        expect(FormValidators.validateName(''), isNotNull);
        expect(FormValidators.validateName(null), isNotNull);
        expect(FormValidators.validateName('   '), isNotNull);
      });

      test('returns error when name is less than 2 characters', () {
        expect(FormValidators.validateName('A'), isNotNull);
      });

      test('returns null when name is valid', () {
        expect(FormValidators.validateName('John Doe'), isNull);
        expect(FormValidators.validateName('Mary'), isNull);
      });
    });

    group('validatePhoneNumber', () {
      test('returns error when phone is empty', () {
        expect(FormValidators.validatePhoneNumber(''), isNotNull);
        expect(FormValidators.validatePhoneNumber(null), isNotNull);
      });

      test('returns error when phone is less than 8 digits', () {
        expect(FormValidators.validatePhoneNumber('1234567'), isNotNull);
      });

      test('returns error when phone is more than 11 digits', () {
        expect(FormValidators.validatePhoneNumber('123456789012'), isNotNull);
      });

      test('returns error when phone contains non-digits', () {
        expect(FormValidators.validatePhoneNumber('123456789a'), isNotNull);
        expect(FormValidators.validatePhoneNumber('12345-6789'), isNotNull);
      });

      test('returns null when phone is valid', () {
        expect(FormValidators.validatePhoneNumber('12345678'), isNull);
        expect(FormValidators.validatePhoneNumber('0900000001'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when password is empty', () {
        expect(FormValidators.validatePassword(''), isNotNull);
        expect(FormValidators.validatePassword(null), isNotNull);
      });

      test('returns error when password is less than 6 characters', () {
        expect(FormValidators.validatePassword('pass'), isNotNull);
        expect(FormValidators.validatePassword('pass12'), isNull);
      });

      test('returns null when password is valid', () {
        expect(FormValidators.validatePassword('password123'), isNull);
        expect(FormValidators.validatePassword('123456'), isNull);
      });
    });

    group('validatePasswordConfirmation', () {
      test('returns error when confirmation is empty', () {
        expect(
          FormValidators.validatePasswordConfirmation('', 'password'),
          isNotNull,
        );
      });

      test('returns error when passwords do not match', () {
        expect(
          FormValidators.validatePasswordConfirmation('password2', 'password1'),
          isNotNull,
        );
      });

      test('returns null when passwords match', () {
        expect(
          FormValidators.validatePasswordConfirmation(
            'password123',
            'password123',
          ),
          isNull,
        );
      });
    });

    group('validateOtp', () {
      test('returns error when OTP is empty', () {
        expect(FormValidators.validateOtp(''), isNotNull);
        expect(FormValidators.validateOtp(null), isNotNull);
      });

      test('returns error when OTP is not 6 digits', () {
        expect(FormValidators.validateOtp('12345'), isNotNull);
        expect(FormValidators.validateOtp('1234567'), isNotNull);
      });

      test('returns error when OTP contains non-digits', () {
        expect(FormValidators.validateOtp('123a56'), isNotNull);
        expect(FormValidators.validateOtp('123-456'), isNotNull);
      });

      test('returns null when OTP is valid', () {
        expect(FormValidators.validateOtp('123456'), isNull);
        expect(FormValidators.validateOtp('000000'), isNull);
      });
    });

    group('validateEmail', () {
      test('returns error when email is empty', () {
        expect(FormValidators.validateEmail(''), isNotNull);
        expect(FormValidators.validateEmail(null), isNotNull);
      });

      test('returns error for invalid email formats', () {
        expect(FormValidators.validateEmail('invalid'), isNotNull);
        expect(FormValidators.validateEmail('invalid@'), isNotNull);
        expect(FormValidators.validateEmail('invalid@.com'), isNotNull);
        expect(FormValidators.validateEmail('invalid@domain'), isNotNull);
      });

      test('returns null for valid email formats', () {
        expect(FormValidators.validateEmail('user@example.com'), isNull);
        expect(FormValidators.validateEmail('test.user@domain.co.uk'), isNull);
        expect(FormValidators.validateEmail('user+tag@example.com'), isNull);
      });
    });
  });
}
