class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final bool isPremium;
  final String bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.isPremium = false,
    this.bio = 'AI Explorer & Tech Enthusiast',
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    bool? isPremium,
    String? bio,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isPremium: isPremium ?? this.isPremium,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'isPremium': isPremium,
      'bio': bio,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      isPremium: json['isPremium'] ?? false,
      bio: json['bio'] ?? 'AI Explorer & Tech Enthusiast',
    );
  }
}
