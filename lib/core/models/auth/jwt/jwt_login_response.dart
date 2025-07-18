import 'jwt_user.dart';

class JwtLoginResponse {

  JwtLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.user,
  });

  factory JwtLoginResponse.fromJson(Map<String, dynamic> json) {
    return JwtLoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      user: json['user'] != null
          ? JwtUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final JwtUser? user;
}
