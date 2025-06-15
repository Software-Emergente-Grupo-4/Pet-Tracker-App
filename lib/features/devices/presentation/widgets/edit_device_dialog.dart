// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/devices/domain/entities/device.dart';
import 'package:pet_tracker/features/devices/presentation/providers/device_provider.dart';

class EditDeviceDialog extends StatefulWidget {
  final Device device;
  final String userId;

  const EditDeviceDialog({
    super.key,
    required this.device,
    required this.userId,
  });

  @override
  State<EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<EditDeviceDialog> {
  late TextEditingController bearerController;
  late TextEditingController nameController;
  late String selectedRole;

  final List<String> roles = ['SMALL', 'MEDIUM', 'LARGE']; // Nuevos roles

  @override
  void initState() {
    super.initState();

    bearerController = TextEditingController(text: widget.device.bearer);
    nameController = TextEditingController(text: widget.device.nickname);

    // Validamos que el valor actual esté dentro de los roles
    if (roles.contains(widget.device.careMode)) {
      selectedRole = widget.device.careMode;
    } else {
      selectedRole = roles.first;
    }
  }

  @override
  void dispose() {
    bearerController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Device',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Bearer Field
            TextFormField(
              controller: bearerController,
              decoration: InputDecoration(
                labelText: 'Bearer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // Device Name Field
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Device Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // Role Dropdown actualizado
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: const TextStyle(fontSize: 16, color: Colors.black),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role, style: const TextStyle(fontSize: 14, color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(deviceProvider(widget.userId).notifier)
                            .updateDevice(
                              widget.device,
                              bearerController.text,
                              nameController.text,
                              selectedRole,
                              widget.device.status,
                            );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08273A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(100, 0),
                      ),
                      child: const Text('Save'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
