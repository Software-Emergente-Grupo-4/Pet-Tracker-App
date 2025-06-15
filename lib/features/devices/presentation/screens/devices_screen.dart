// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:pet_tracker/features/devices/domain/domain.dart';
import 'package:pet_tracker/features/devices/presentation/providers/device_provider.dart';
import 'package:pet_tracker/features/devices/presentation/widgets/widgets.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    if (authState.authStatus == AuthStatus.checking || userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = userProfile.id;
    final deviceAsyncValue = ref.watch(deviceProvider(userId.toString()));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Devices',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showAddDeviceDialog(context, ref, userId.toString());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08273A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF08273A),
                onRefresh: () async {
                  ref.refresh(deviceProvider(userId.toString()));
                  return Future.value();
                },
                child: deviceAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error: ${error.toString().length > 50 ? '${error.toString().substring(0, 50)}...' : error.toString()}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (devices) {
                    if (devices.isEmpty) {
                      return const Center(child: Text('No devices found'));
                    }

                    return FutureBuilder<String?>(
                      future: ref.read(deviceProvider(userId.toString()).notifier).getSelectedDeviceId(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final selectedDeviceId = snapshot.data;

                        return ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return DeviceCard(
                              device: device,
                              selectedDeviceId: selectedDeviceId,
                              onSelectDevice: () {
                                showSelectDeviceDialog(context, ref, device, userId.toString());
                              },
                              onEditDevice: () {
                                showEditDeviceDialog(context, device, userId.toString());
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddDeviceDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddDeviceDialog(
          onAssignDevice: (deviceId) async {
            final assignProvider = ref.read(deviceAssignProvider.notifier);
            await assignProvider.assignDeviceToUser(dialogContext, deviceId, userId);

            if (!ref.read(deviceAssignProvider).hasError) {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              ref.refresh(deviceProvider(userId));
            }
          },
        );
      },
    );
  }

  void showSelectDeviceDialog(BuildContext context, WidgetRef ref, Device device, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SelectDeviceDialog(
          device: device,
          userId: userId,
          onConfirm: () async {
            await ref.read(deviceProvider(userId).notifier).selectDevice(device);
            ref.refresh(deviceProvider(userId));
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showEditDeviceDialog(BuildContext context, Device device, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return EditDeviceDialog(
          device: device,
          userId: userId,
        );
      },
    );
  }
}
