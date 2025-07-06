import 'package:pet_tracker/features/activities/domain/entities/activity.dart';

class ActivityMapper {
  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      petTrackerDeviceRecordId: json['petTrackerDeviceRecordId'],
      activityName: json['activityName'],
      activityType: json['activityType'],
      dateAndTime: DateTime.parse(json['dateAndTime']),
    );
  }

  static Map<String, dynamic> toJson(Activity activity) {

    return {
      'petTrackerDeviceRecordId': activity.petTrackerDeviceRecordId,
      'activityName': activity.activityName,
      'activityType': activity.activityType,
      'dateAndTime': activity.dateAndTime,
    };



  }




}
