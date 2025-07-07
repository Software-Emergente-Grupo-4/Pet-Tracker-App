class Activity {
  final String petTrackerDeviceRecordId;
  final String activityName;
  final String activityType;
  final DateTime dateAndTime;

  Activity({
    required this.petTrackerDeviceRecordId,
    required this.activityName,
    required this.activityType,
    required this.dateAndTime,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    petTrackerDeviceRecordId: json['petTrackerDeviceRecordId'],
    activityName: json['activityName'],
    activityType: json['activityType'],
    dateAndTime: DateTime.parse(json['dateAndTime']),
  );
}
