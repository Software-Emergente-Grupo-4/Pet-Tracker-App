import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/navigation/domain/entities/health_measure.dart';
import 'package:pet_tracker/features/navigation/infrastructure/datasources/health_stream_datasource_impl.dart';
import 'package:pet_tracker/features/navigation/presentation/providers/health_stream_notifier.dart';

final healthStreamProvider =
    StateNotifierProvider<HealthStreamNotifier, AsyncValue<HealthMeasure>>(
  (ref) {
    final datasource = HealthStreamDatasourceImpl(
      baseUrl: 'wss://pettracker.azurewebsites.net',
    );
    return HealthStreamNotifier(datasource: datasource, ref: ref);
  },
);
