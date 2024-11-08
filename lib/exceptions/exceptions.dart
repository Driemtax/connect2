class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class ContactNotFoundException implements Exception {
  final String message;
  ContactNotFoundException(this.message);

  @override
  String toString() => 'ContactNotFoundException: $message';
}
