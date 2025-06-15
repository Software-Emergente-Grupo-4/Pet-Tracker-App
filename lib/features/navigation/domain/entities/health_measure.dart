class HealthMeasure {
  final int bpm;
  final int spo2;

  HealthMeasure({
    required this.bpm,
    required this.spo2,
  });

  factory HealthMeasure.fromJson(Map<String, dynamic> json) {
    return HealthMeasure(
      bpm: json['bpm'] as int,
      spo2: json['spo2'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpm': bpm,
      'spo2': spo2,
    };
  }
}
