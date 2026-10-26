class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String createdAt;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  AppUser copyWith({int? id}) {
    return AppUser(
      id: id ?? this.id,
      name: name,
      email: email,
      passwordHash: passwordHash,
      createdAt: createdAt,
    );
  }
}
