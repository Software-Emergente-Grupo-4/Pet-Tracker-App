class HealthSummary{
  final DateTime date;
  final int avgBpm;
  final int avgSpo2;

  HealthSummary({
    required this.date,
    required this.avgBpm,
    required this.avgSpo2,
  });

  HealthSummary copyWith({
    DateTime? date,
    int? avgBpm,
    int? avgSpo2,
  }) {
    return HealthSummary(
      date: date ?? this.date,
      avgBpm: avgBpm ?? this.avgBpm,
      avgSpo2: avgSpo2 ?? this.avgSpo2,
    );
  }
}

