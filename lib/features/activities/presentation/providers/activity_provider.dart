import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/activities/domain/entities/activity.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

import '../../infrastructure/datasources/activity_datasource_impl.dart';
import '../../infrastructure/repositories/activity_repository_impl.dart';

class ActivityNotifier extends StateNotifier<AsyncValue<List<Activity>>> {
  final ActivityRepositoryImpl repository;

  ActivityNotifier(this.repository) : super(const AsyncLoading());

  Future<void> fetchActivities(String deviceRecordId) async {
    try {
      final activities = await repository.getActivities(deviceRecordId);
      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activityRepositoryProvider = Provider<ActivityRepositoryImpl>((ref) {
  final datasource = ActivityDatasourceImpl(
    storageService: ref.watch(keyValueStorageServiceProvider),
  );
  return ActivityRepositoryImpl(datasource);
});

final activityProvider = StateNotifierProvider.family<ActivityNotifier,
    AsyncValue<List<Activity>>, String>((ref, deviceId) {
  final repo = ref.watch(activityRepositoryProvider);
  final notifier = ActivityNotifier(repo);
  notifier.fetchActivities(deviceId);
  return notifier;
});
