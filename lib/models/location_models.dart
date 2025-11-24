class LocationModel {
  final String name;
  final double? latitude;
  final double? longitude;

  LocationModel({required this.name, this.latitude, this.longitude});

  Map<String, dynamic> toJson() => {
    'name': name,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    name: json['name'] as String,
    latitude: json['latitude'] as double?,
    longitude: json['longitude'] as double?,
  );
}
