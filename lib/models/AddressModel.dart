class AddressModel {
  String formattedAddress;
  String placeID;

  AddressModel({
    required this.formattedAddress,
    required this.placeID,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      formattedAddress: json['description'].toString(),
      placeID: json['place_id'].toString(),
    );
  }
}
