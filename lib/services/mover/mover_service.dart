import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';

class MoverService {
  Future<List<UserModel>> loadSampleMovers() async {
    final jsonString = await rootBundle.loadString('assets/data/mover.json');
    final data = json.decode(jsonString) as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
