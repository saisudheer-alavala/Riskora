class UserAccount {
  final String name;
  final String email;
  final String password;
  final DateTime? dob;
  final String role;
  final String avatarUrl;
  final bool isVerified;
  final String authProvider; // 'local' or 'google'
  final DateTime createdAt;

  UserAccount({
    required this.name,
    required this.email,
    required this.password,
    this.dob,
    this.role = 'SecOps Intelligence Analyst',
    this.avatarUrl = '',
    this.isVerified = true,
    this.authProvider = 'local',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum AuthResultCode {
  success,
  userNotFound,
  invalidPassword,
  invalidEmailFormat,
  disposableEmailRejected,
  emailAlreadyRegistered,
}

class AuthResult {
  final bool success;
  final AuthResultCode code;
  final String message;
  final UserAccount? user;

  const AuthResult({
    required this.success,
    required this.code,
    required this.message,
    this.user,
  });

  factory AuthResult.ok(UserAccount user) => AuthResult(
        success: true,
        code: AuthResultCode.success,
        message: 'Authentication successful. Access granted to Riskora Defense Matrix.',
        user: user,
      );

  factory AuthResult.fail(AuthResultCode code, String message) => AuthResult(
        success: false,
        code: code,
        message: message,
      );
}
