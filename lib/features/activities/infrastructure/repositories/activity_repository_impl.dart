import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_datasource_impl.dart';

class ActivityRepositoryImpl extends ActivityRepository {
  final ActivityDatasourceImpl datasource;

  ActivityRepositoryImpl(this.datasource);

  @override
  Future<List<Activity>> getActivities(String deviceRecordId) {
    return datasource.getActivities(deviceRecordId);
  }
}
