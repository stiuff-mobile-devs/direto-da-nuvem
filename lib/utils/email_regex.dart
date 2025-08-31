bool emailHasMatch(String str) {
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return regex.hasMatch(str);
}

bool iduffEmailHasMatch(String str) {
  final iduffRegex = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@id\.uff\.br$");
  return iduffRegex.hasMatch(str);
}