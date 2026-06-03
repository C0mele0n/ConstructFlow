// lib/data/models/user.dart
//
// USER MODEL
// ==========
// Represents a person using the app. Every user is identified by their
// phone number (no passwords). Users can belong to multiple projects
// and hold different roles in each.
//
// KEY DART CONCEPTS IN THIS FILE:
// - `final` = value can only be set once (immutable)
// - `required` = caller MUST provide this value
// - `?` = nullable (can be null)
// - `= const []` = default value if none provided
// - Named constructor = alternative way to create an object

class User {
  final String id;               // Unique ID (phone number based)
  final String name;             // Display name
  final String? photoUrl;        // Profile photo (optional — ? means nullable)
  final List<String> tradeTags;  // e.g., ["Framing", "Flooring"]
  final List<String> projectIds; // IDs of projects this user belongs to
  final DateTime createdAt;      // When the account was created

  // Main constructor
  // Every user MUST have an id, name, and createdAt date.
  // Everything else is optional and defaults to empty/null.
  const User({
    required this.id,
    required this.name,
    this.photoUrl,
    this.tradeTags = const [],
    this.projectIds = const [],
    required this.createdAt,
  });

  // Named constructor: creates a temporary "guest" user
  // Usage: var guest = User.guest();
  User.guest()
      : id = 'guest',
        name = 'Guest',
        photoUrl = null,
        tradeTags = const [],
        projectIds = const [],
        createdAt = DateTime.now();

  // Getter: computed property (looks like a field, acts like a method)
  // Usage: if (user.isGuest) { ... }
  bool get isGuest => id == 'guest';

  // Method: returns a human-readable summary
  String summary() {
    if (tradeTags.isEmpty) return name;
    return '$name • ${tradeTags.join(", ")}';
  }

  // copyWith: creates a new User with some fields changed
  // This is a common pattern in Dart because objects are immutable (final).
  // Instead of changing a field, you create a new copy with the change.
  //
  // Usage: var updatedUser = user.copyWith(name: "New Name");
  User copyWith({
    String? id,
    String? name,
    String? photoUrl,
    List<String>? tradeTags,
    List<String>? projectIds,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      tradeTags: tradeTags ?? this.tradeTags,
      projectIds: projectIds ?? this.projectIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // toString: controls how the object prints (useful for debugging)
  @override
  String toString() => 'User(id: $id, name: $name, trades: $tradeTags)';
}
