import 'package:flutter/material.dart';
import 'package:pet_tracker/features/devices/domain/entities/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final String? selectedDeviceId;
  final VoidCallback onSelectDevice;
  final VoidCallback onEditDevice;

  const DeviceCard({
    super.key,
    required this.device,
    required this.selectedDeviceId,
    required this.onSelectDevice,
    required this.onEditDevice,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = device.petTrackerDeviceRecordId == selectedDeviceId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.lightBlue[50] : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.lightBlue : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pets,
            size: 36,
            color: Color(0xFF08273A),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.nickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  device.careMode,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            device.status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: device.status == "CONNECTED"
                  ? Colors.green
                  : device.status == "DISCONNECTED"
                      ? Colors.red
                      : Colors.grey,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'select') {
                onSelectDevice();
              } else if (value == 'edit') {
                onEditDevice();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: Text('Select Device'),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Device'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
