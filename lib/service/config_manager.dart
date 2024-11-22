import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigManager {
  static Map<String, dynamic> _config = {};

  // Method to load and parse the config.json file
  static Future<void> loadConfig() async {
    try {
      String configString = await rootBundle.loadString('assets/config.json');
      _config = jsonDecode(configString);
      print("Config loaded successfully.");
    } catch (e) {
      print("Error loading config: $e");
      rethrow;
    }
  }

  // Getter to access config values
  static dynamic getConfigValue(String key) {
    return _config[key];
  }
}
