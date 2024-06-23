

class AuthResponse {
  final String refreshToken;
  final String token;

  AuthResponse({
    required this.refreshToken,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      refreshToken: json['refreshToken'],
      token: json['token'],
    );
  }
}

// {"refreshToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiI3MDExODk5ODI2IiwidXNlcl9pZCI6IjY2Nzg1NDViNTdiMWE0YmE0ZDk4MTJjZiIsInVzZXJfdHlwZSI6IiIsImV4cCI6MTcyMTc1Mzk0N30.cEBYc3PoMX9jy2TXaJWy0EjD4F8N0YL3r6kcTFA5hzg","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiI3MDExODk5ODI2IiwidXNlcl9pZCI6IjY2Nzg1NDViNTdiMWE0YmE0ZDk4MTJjZiIsInVzZXJfdHlwZSI6ImdlbmVyYWxfdXNlciIsImV4cCI6MTcxOTI0ODM0N30.q6IyfAq1aagaUvA3xz-H39DApJrMdhL06DOdpp8mFLg"}

