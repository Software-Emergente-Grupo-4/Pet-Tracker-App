// prediction_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:pet_tracker/features/devices/infrastructure/repositories/device_repository_impl.dart';
import 'package:pet_tracker/features/vital-signs/domain/repositories/health_summary_repository.dart';
import 'package:pet_tracker/features/vital-signs/presentation/screens/prediction_result_screen.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class PredictionLoadingScreen extends StatefulWidget {
  final String dataType; // 'bpm' o 'spo2'
  final HealthSummaryRepository repository;
  final KeyValueStorageService storageService;
  final DeviceRepositoryImpl deviceRepository;
  const PredictionLoadingScreen(
      {super.key,
      required this.dataType,
      required this.repository,
      required this.storageService,
      required this.deviceRepository});

  @override
  State<PredictionLoadingScreen> createState() => _PredictionLoadingScreenState(
      this.repository, this.storageService, this.deviceRepository);
}

class _PredictionLoadingScreenState extends State<PredictionLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadPrediction();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final HealthSummaryRepository repository;
  final KeyValueStorageService storageService;
  final DeviceRepositoryImpl deviceRepository;
  _PredictionLoadingScreenState(
      this.repository, this.storageService, this.deviceRepository) {}

  Future<void> _loadPrediction() async {
    try {
      final userId = await storageService.getValue<String>('userId');
      var selectedDeviceRecordId =
          await storageService.getValue<String>('selectedDeviceRecordId');

      if (userId == null) {
        throw Exception('No user found');
      }

      final userDevices = await deviceRepository.getAllDevices(userId);

      if (userDevices.isEmpty) {
        await storageService.removeKey('selectedDeviceRecordId');
        return;
      }

      if (selectedDeviceRecordId == null) {
        selectedDeviceRecordId = userDevices.first.petTrackerDeviceRecordId;
        await storageService.setKeyValue<String>(
            'selectedDeviceRecordId', selectedDeviceRecordId);
      }

      final isOwnedDevice = userDevices.any(
        (device) => device.petTrackerDeviceRecordId == selectedDeviceRecordId,
      );

      if (!isOwnedDevice) {
        throw Exception('Unauthorized access');
      }

      final data =
          await repository.fetchHealthPrediction(selectedDeviceRecordId);
      // Navega al resultado
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PredictionResultScreen(
            dataType: widget.dataType,
            predictions: data,
          ),
        ),
      );
    } catch (e, stacktrace) {
      print('>>> Prediction error: $e');
      print(stacktrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: const Icon(Icons.auto_awesome,
                        size: 64, color: Colors.blue),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Generating prediction...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
