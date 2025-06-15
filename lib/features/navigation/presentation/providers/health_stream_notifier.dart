import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/navigation/domain/entities/health_measure.dart';
import 'package:pet_tracker/features/navigation/infrastructure/datasources/health_stream_datasource_impl.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

class HealthStreamNotifier extends StateNotifier<AsyncValue<HealthMeasure>> {
  final HealthStreamDatasourceImpl datasource;
  final Ref ref;

  String? _currentApiKey;
  Stream<HealthMeasure>? _healthStream;
  StreamSubscription<HealthMeasure>? _healthStreamSubscription;
  StreamSubscription<String?>? _apiKeySubscription;
  Timer? _noDataTimer;

  HealthStreamNotifier({
    required this.datasource,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final storageService = ref.read(keyValueStorageServiceProvider);

    try {
      _currentApiKey = await storageService.getValue<String>('selectedApiKey');

      if (_currentApiKey == null) {
        state = AsyncValue.error(
          'No API Key found',
          StackTrace.current,
        );
        return;
      }

      _connectToWebSocket(_currentApiKey!);

      _apiKeySubscription =
          Stream.periodic(const Duration(seconds: 1)).asyncMap((_) {
        return storageService.getValue<String>('selectedApiKey');
      }).listen((newApiKey) {
        if (newApiKey != null && newApiKey != _currentApiKey) {
          _currentApiKey = newApiKey;
          _connectToWebSocket(newApiKey);
        }
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _connectToWebSocket(String apiKey) {
    try {
      datasource.disconnect();
      _noDataTimer?.cancel();
      _healthStreamSubscription?.cancel();

      _healthStream = datasource.connectToHealthStream(apiKey);
      _healthStreamSubscription = _healthStream!.listen(
        (data) {
          _noDataTimer?.cancel();

          state = AsyncValue.data(data);

          _startNoDataTimer();
        },
        onError: (error) {
          state = AsyncValue.error(error, StackTrace.current);
        },
      );

      _startNoDataTimer();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _startNoDataTimer() {
    _noDataTimer?.cancel();

    _noDataTimer = Timer(const Duration(seconds: 5), () {
      state = AsyncValue.data(HealthMeasure(bpm: 0, spo2: 0));
    });
  }

  @override
  void dispose() {
    _apiKeySubscription?.cancel();
    _healthStreamSubscription?.cancel();
    _noDataTimer?.cancel();
    datasource.disconnect();
    super.dispose();
  }
}
