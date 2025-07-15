class JwtUser {

  JwtUser({required this.id});

  factory JwtUser.fromJson(Map<String, dynamic> json) {
    return JwtUser(
      id: json['id'] as String,
    );
  }
  final String id;
}
