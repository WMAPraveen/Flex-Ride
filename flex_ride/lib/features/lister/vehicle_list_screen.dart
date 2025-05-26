import 'dart:convert'; // Add this for base64Decode
import 'package:flutter/material.dart';
import 'package:car_rental_app/models/vehicle.dart';

class VehicleListScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  final void Function(Vehicle)? onEdit;
  final void Function(Vehicle)? onDelete;

  const VehicleListScreen({
    Key? key,
    required this.vehicles,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('All Vehicles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body:
          vehicles.isEmpty
              ? const Center(
                child: Text(
                  'No vehicles added yet.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: _buildVehicleImage(vehicle),
                      title: Text(
                        vehicle.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Type: ${vehicle.type}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Price/Day: \$${vehicle.pricePerDay.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Status: ${vehicle.isUnderMaintenance
                                ? "Under Maintenance"
                                : vehicle.isRented
                                ? "Rented"
                                : "Available"}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (vehicle.description != null &&
                              vehicle.description!.isNotEmpty)
                            Text(
                              'Note: ${vehicle.description}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => onEdit?.call(vehicle),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => onDelete?.call(vehicle),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildVehicleImage(Vehicle vehicle) {
    if (vehicle.imageBase64.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.directions_car, color: Colors.white, size: 36),
      );
    }

    try {
      final imageBytes = base64Decode(vehicle.imageBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageBytes,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 36,
              ),
            );
          },
        ),
      );
    } catch (e) {
      print('Exception while loading image: $e');
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.error, color: Colors.white, size: 36),
      );
    }
  }
}
