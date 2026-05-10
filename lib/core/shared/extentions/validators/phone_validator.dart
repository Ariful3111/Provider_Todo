import 'package:intl_phone_field/phone_number.dart';

String? phoneValidation(PhoneNumber? value) {
  final text = (value?.number ?? '').trim();
  if (text.isEmpty) {
    return "Phone number is required";
  }
  // Strict regex: Must start with 880, followed by 1, then 3-9, then 8 digits.
  final RegExp phoneReg = RegExp(r'^8801[3-9]\d{8}$');
  if (phoneReg.hasMatch(text)) {
    return null;
  }
  return "Must be a valid phone number. Example: 880XXXXXXXXX";
}