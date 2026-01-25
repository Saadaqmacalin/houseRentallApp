class House {
  final String id;
  final String address;
  final double price;
  final int numberOfRooms;
  final String houseType;
  final String description;
  final String status;
  final String ownerName;
  final String imageUrl;

  House({
    required this.id,
    required this.address,
    required this.price,
    required this.numberOfRooms,
    required this.houseType,
    required this.description,
    required this.status,
    required this.ownerName,
    required this.imageUrl,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['_id'],
      address: json['address'],
      price: (json['price'] as num).toDouble(),
      numberOfRooms: json['numberOfRooms'],
      houseType: json['houseType'],
      description: json['description'] ?? '',
      status: json['status'],
      ownerName: json['owner'] is Map ? json['owner']['name'] : 'Unknown',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    );
  }
}
