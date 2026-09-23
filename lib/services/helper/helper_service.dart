import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';

class HelperService {
  Future<List<UserModel>> loadSampleHelpers() async {
    final jsonString = await rootBundle.loadString('assets/data/helper.json');
    final data = json.decode(jsonString) as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
