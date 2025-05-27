import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';

class VehicleStorage {
  static const _key = 'vehicles';

  static Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = vehicles.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<Vehicle>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];
    return jsonList.map((json) => Vehicle.fromJson(jsonDecode(json))).toList();
  }
}
