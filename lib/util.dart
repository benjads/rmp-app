import 'dart:io';
import 'dart:math';

import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

class RMPUtil {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static final Random _random = Random();
  static const String COOKIE = "rmp_app_user";

  static Future<String> getDeviceId() async {
    if (kIsWeb) {
      String key = html.window.localStorage[COOKIE];
      if (key == null || key == "")
        key = _random.nextInt(1000000000).toString();
      html.window.localStorage[COOKIE] = key;
      return key;
    } else {
      if (Platform.isAndroid) {
        return (await _deviceInfoPlugin.androidInfo).id;
      } else if (Platform.isIOS) {
        return (await _deviceInfoPlugin.iosInfo).identifierForVendor;
      }
    }

    return null;
  }

  static String formatEnum(String enumName, dynamic enumConstant) {
    final constantName = enumConstant.toString().substring(enumName.length + 1);
    return "${constantName[0]}${constantName.substring(1).toLowerCase()}";
  }

  static String percent(num amount, num total) {
    double percent = (amount / total) * 100;
    return "${percent.toStringAsFixed(0)}\%";
  }

  static Map<String, dynamic> toMap(Map<dynamic, dynamic> data) {
    return Map<String, dynamic>.from(data);
  }
}