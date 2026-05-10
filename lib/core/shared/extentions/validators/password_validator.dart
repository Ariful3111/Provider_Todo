String? passwordValidation(String? value) {
  final text = (value ?? '').trim();

  if (text.isEmpty) {
    return "Password is required";
  }
  if (text.length < 8) {
    return "Password must be at least 8 characters";
  }
  return null;
}