class Vehicle {
  String id;
  String name;
  String description;
  String image;
  String capacity;
  String price;

  Vehicle({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.capacity,
    required this.price,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'].toString(),
      name: json['name']['en'].toString(),
      description: json['description']['en'].toString().replaceAll("\r", ""),
      image: json['image'].toString(),
      capacity: json['capacity'].toString(),
      price: json['fixed'].toString(),
    );
  }
}
