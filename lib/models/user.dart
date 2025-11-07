class AppUser {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;
  final bool notificationsEnabled;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
    this.notificationsEnabled = true,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}