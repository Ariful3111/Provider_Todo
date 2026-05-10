String? nameValidation(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) {
    return "Name is required";
  }
  if (text.length < 3) {
    return "Name must be at least 3 characters";
  }
  // Allow letters and spaces (multiple words with spaces)
  final RegExp name = RegExp(r'^[A-Za-z]+( [A-Za-z]+)*$');
  if (!name.hasMatch(text)) {
    return 'Name can only contain letters and spaces';
  }
  return null;
}