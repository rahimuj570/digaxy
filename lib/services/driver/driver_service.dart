import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';

class DriverService {
  Future<List<UserModel>> loadSampleDrivers() async {
    final jsonString = await rootBundle.loadString('assets/data/driver.json');
    final data = json.decode(jsonString) as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
