import 'package:flutter/material.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(String deviceId) onAssignDevice;

  const AddDeviceDialog({super.key, required this.onAssignDevice});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final TextEditingController deviceIdController = TextEditingController();
  bool isAssigning = false;

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
              'Add Device',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: deviceIdController,
              decoration: InputDecoration(
                labelText: 'Device ID',
                labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                hintText: 'Enter a Device ID...',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: isAssigning
                      ? null
                      : () async {
                          setState(() {
                            isAssigning = true;
                          });
                          final deviceId = deviceIdController.text.trim();
                          if (deviceId.isNotEmpty) {
                            await widget.onAssignDevice(deviceId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a Device ID',
                                    style: TextStyle(fontSize: 14)),
                              ),
                            );
                          }
                          setState(() {
                            isAssigning = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08273A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(
                        100, 0),
                  ),
                  child: isAssigning
                      ? const SizedBox(
                          width: 20, // Ancho del indicador
                          height: 20, // Alto del indicador
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Accept', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
