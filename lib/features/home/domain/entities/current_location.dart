class CurrentLocation {
  final double latitude;
  final double longitude;
  final String riskLevel;

  CurrentLocation({
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
  });

  CurrentLocation copyWith({
    double? latitude,
    double? longitude,
    String? riskLevel,
  }) =>
      CurrentLocation(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        riskLevel: riskLevel ?? this.riskLevel,
      );

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      CurrentLocation(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        riskLevel: json["riskLevel"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "riskLevel": riskLevel,
      };
}
