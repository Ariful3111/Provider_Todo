String? confirmPasswordValidation(String? password, String? confirmPassword) {
  final text = (confirmPassword ?? '').trim();
  if (text.isEmpty) {
    return "Confirm Password is required";
  }
  if (text != password) {
    return "Passwords do not match";
  }
  return null;
}