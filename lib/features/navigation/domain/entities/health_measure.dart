class HealthMeasure {
  final int? bpm;
  final int? spo2;

  HealthMeasure({
    required this.bpm,
    required this.spo2,
  });

  factory HealthMeasure.fromJson(Map<String, dynamic> json) {
    final bpmRaw = json['bpm'];
    final spo2Raw = json['spo2'];

    return HealthMeasure(
      bpm: bpmRaw is int ? bpmRaw : int.tryParse(bpmRaw?.toString() ?? ''),
      spo2: spo2Raw is int ? spo2Raw : int.tryParse(spo2Raw?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpm': bpm,
      'spo2': spo2,
    };
  }
}
