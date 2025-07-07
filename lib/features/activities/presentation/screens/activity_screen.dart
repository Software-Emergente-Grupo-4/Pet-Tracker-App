import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/activities/domain/entities/activity.dart';
import 'package:pet_tracker/features/activities/presentation/providers/activity_provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../devices/presentation/providers/device_provider.dart';

import 'package:intl/intl.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    // Mostrar loading mientras se obtiene el estado de autenticación o el perfil del usuario
    if (authState.authStatus == AuthStatus.checking || userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = userProfile.id.toString();
    final devicesAsync = ref.watch(deviceProvider(userId));

    return devicesAsync.when(
      data: (devices) {
        if (devices.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron dispositivos vinculados.')),
          );
        }

        // Obtener el primer dispositivo del usuario
        final deviceId = devices.first.petTrackerDeviceRecordId;
        final activitiesAsync = ref.watch(activityProvider(deviceId));

        return activitiesAsync.when(
          data: (activities) => _ActivityTable(activities: activities),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text('Error cargando actividades: $e')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error cargando dispositivos: $e')),
      ),
    );
  }
}


class _ActivityTable extends StatelessWidget {
  final List<Activity> activities;

  const _ActivityTable({required this.activities});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Actividades del Dispositivo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: activities.isEmpty
            ? const Center(child: Text('No hay actividades registradas.'))
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nombre de la Actividad')),
              DataColumn(label: Text('Tipo de Actividad')),
              DataColumn(label: Text('Fecha y Hora')),
            ],
            rows: activities.map((a) {
              return DataRow(cells: [
                DataCell(Text(a.activityName)),
                DataCell(Text(a.activityType)),
                DataCell(Text(dateFormatter.format(a.dateAndTime))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
