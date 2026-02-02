class User {
  final String id;
  final String name;
  final String email;
  final String token;
  List<String> favorites;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    List<String>? favorites,
  }) : favorites = favorites ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      token: json['token'] ?? '', // Handle case where token might be mostly in login/register response but maybe not in profile update
      favorites: (json['favorites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'favorites': favorites,
    };
  }
}
