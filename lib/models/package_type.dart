class PackageType {
  String id;
  String name;

  PackageType({
    required this.id,
    required this.name,
  });

  factory PackageType.fromJson(Map<String, dynamic> json) {
    return PackageType(
      id: json['id'].toString(),
      name: json['name']['en'].toString(),
    );
  }
}
