class Device {
  final String petTrackerDeviceRecordId;
  final String nickname;
  final String bearer;
  final String careMode;
  final String status;
  final String userId;
  final String apiKey;

  Device({
    required this.petTrackerDeviceRecordId,
    required this.nickname,
    required this.bearer,
    required this.careMode,
    required this.status,
    required this.userId,
    required this.apiKey,
  });
}
