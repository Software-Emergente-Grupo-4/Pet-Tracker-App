import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/navigation/domain/entities/health_measure.dart';
import 'package:pet_tracker/features/navigation/infrastructure/datasources/health_stream_datasource_impl.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

class HealthStreamNotifier extends StateNotifier<AsyncValue<HealthMeasure>> {
  final HealthStreamDatasourceImpl datasource;
  final Ref ref;

  String? _currentApiKey;
  StreamSubscription<HealthMeasure>? _healthStreamSubscription;
  StreamSubscription<String?>? _apiKeySubscription;
  Timer? _reconnectTimer;
  Timer? _noDataTimer;

  // *Lo usaremos para verificar si estamos reconectando
  bool _isReconnecting = false;

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
        state = AsyncValue.error('No API Key found', StackTrace.current);
        return;
      }

      _connectToWebSocket(_currentApiKey!);

      // !Verificaremos si existen cambios en el API Key
      _apiKeySubscription = Stream.periodic(const Duration(seconds: 5))
          .asyncMap((_) => storageService.getValue<String>('selectedApiKey'))
          .listen((newApiKey) {
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
      _cancelTimers();
      _isReconnecting = false; // *Resetea la bandera de reconexión

      // print('Intentando conectar con WebSocket usando API Key: $apiKey');
      final healthStream = datasource.connectToHealthStream(apiKey);

      _healthStreamSubscription?.cancel();
      _healthStreamSubscription = healthStream.listen(
        (data) {
          // print('Datos recibidos: $data');
          _resetNoDataTimer(); // *Reinicia el temporizador de "no datos"
          state = AsyncValue.data(data);
        },
        onError: (error) {
          // print('Error en WebSocket: $error');
          state = AsyncValue.error(error, StackTrace.current);
          _scheduleReconnectWithBackoff(apiKey);
        },
        onDone: () {
          // print('WebSocket cerrado, intentando reconectar...');
          _scheduleReconnectWithBackoff(apiKey);
        },
      );

      _resetNoDataTimer();
    } catch (error, stackTrace) {
      // print('Error al conectar WebSocket: $error');
      state = AsyncValue.error(error, stackTrace);
      _scheduleReconnectWithBackoff(apiKey);
    }
  }

  void _scheduleReconnectWithBackoff(String apiKey, {int attempt = 0}) async {
    if (_isReconnecting) return; // Salimos si ya estamos intentando reconectar
    _isReconnecting = true;

    // Verifica si hay conexión a Internet
    final connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) {
      // print('Sin conexión a Internet. Esperando...');
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        _isReconnecting = false; // Permitir nuevos intentos de reconexión
        _scheduleReconnectWithBackoff(apiKey, attempt: attempt);
      });
      return;
    }

    // Calcula el tiempo de espera con Exponential Backoff (1s, 2s, 4s, ...)
    final delay = Duration(seconds: (1 << attempt).clamp(1, 64));
    // print('Reconectando en ${delay.inSeconds} segundos (intento: $attempt)');

    // *Programa el temporizador para reconectar
    _reconnectTimer = Timer(delay, () {
      // print('Intentando conectar con WebSocket usando API Key: $apiKey');
      _connectToWebSocket(apiKey);

      // *Si la conexión falla, intentamos de nuevo
      _isReconnecting = false; // * En caso de falla, permitir nuevos intentos
      _scheduleReconnectWithBackoff(apiKey, attempt: attempt + 1);
    });
  }

  void _resetNoDataTimer() {
    _noDataTimer?.cancel();
    _noDataTimer = Timer(const Duration(minutes: 5), () {
      // print('No se han recibido datos en 5 minutos. Intentando reconectar...');
      if (_currentApiKey != null) {
        _connectToWebSocket(_currentApiKey!);
      }
    });
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _noDataTimer?.cancel();
  }

  @override
  void dispose() {
    _healthStreamSubscription?.cancel();
    _apiKeySubscription?.cancel();
    _cancelTimers();
    datasource.disconnect();
    super.dispose();
  }
}
