class PackageService {
  String id;
  String name;
  String capacity;
  String fixed;

  PackageService({
    required this.id,
    required this.name,
    required this.capacity,
    required this.fixed,
  });

  factory PackageService.fromJson(Map<String, dynamic> json) {
    return PackageService(
      id: json['id'].toString(),
      name: json['name']['en'].toString(),
      capacity: json['capacity'],
      fixed: json['fixed'],
    );
  }
}
