import 'dart:io';

import 'package:device_info/device_info.dart';

class RMPUtil {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      return (await deviceInfoPlugin.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await deviceInfoPlugin.iosInfo).identifierForVendor;
    }

    return null;
  }

  static String formatEnum(dynamic enumConstant) {
    final enumName = enumConstant.runtimeType.toString();
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