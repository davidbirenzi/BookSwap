// User model - represents a student using the app
class AppUser {
  final String id; // unique user ID from Firebase Auth
  final String email; // student's email address
  final String name; // display name for the student
  final bool emailVerified; // whether they've verified their email
  final bool notificationsEnabled; // user preference for notifications

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
    this.notificationsEnabled = true, // notifications on by default
  });

  // Create user object from Firestore data
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '', // fallback to empty string if null
      name: map['name'] ?? '',
      emailVerified: map['emailVerified'] ?? false, // default to unverified
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  // Convert user object to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
      // Note: ID is not included since Firestore handles document IDs separately
    };
  }
}