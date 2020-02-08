import 'dart:io';

import 'package:device_info/device_info.dart';

class DeviceUtil {

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      return (await deviceInfoPlugin.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await deviceInfoPlugin.iosInfo).identifierForVendor;
    }

    return null;
  }
}