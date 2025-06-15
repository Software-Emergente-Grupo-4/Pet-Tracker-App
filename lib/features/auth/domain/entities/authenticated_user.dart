class AuthenticatedUser {
  final int id;
  final String username;
  final String? token;

  AuthenticatedUser({
    required this.id,
    required this.username,
    this.token,
  });
}
