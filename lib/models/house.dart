class House {
  final String id;
  final String address;
  final double price;
  final int numberOfRooms;
  final String houseType;
  final String description;
  final String status;
  final String ownerName;

  House({
    required this.id,
    required this.address,
    required this.price,
    required this.numberOfRooms,
    required this.houseType,
    required this.description,
    required this.status,
    required this.ownerName,
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
    );
  }
}
