class AuthItem {
  //String? id;
  final String? name;
  final String email;
  final String password;
  final String passwordConfirm;
  final String? token;
  final DateTime? expiryDate;
  String? userId;

  AuthItem(
      {this.name,
      required this.email,
      required this.password,
      required this.passwordConfirm,
      this.token,
      this.expiryDate,
      this.userId});
}
