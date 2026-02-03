class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? phoneNumber;
  final String? address;
  final String? nationalID;
  List<String> favorites;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.phoneNumber,
    this.address,
    this.nationalID,
    List<String>? favorites,
  }) : favorites = favorites ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      token: json['token'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      nationalID: json['nationalID'],
      favorites: (json['favorites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'phoneNumber': phoneNumber,
      'address': address,
      'nationalID': nationalID,
      'favorites': favorites,
    };
  }
}
