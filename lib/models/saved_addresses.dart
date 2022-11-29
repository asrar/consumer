class SavedAddress {
  String id;
  String title;
  String formattedAddress;
  SavedAddress({
    required this.id,
    required this.title,
    required this.formattedAddress,
  });
  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      formattedAddress: json['formated_address'].toString(),
      title: json['title'].toString(),
      id: json['id'].toString(),
    );
  }
}
