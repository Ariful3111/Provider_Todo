String? emailValidation(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) {
    return "Email is required";
  }
  // ignore: deprecated_member_use
  final RegExp emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (emailReg.hasMatch(text)) {
    return null;
  }
  {
    return "Enter a valid email address";
  }
}