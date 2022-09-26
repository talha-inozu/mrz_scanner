import 'package:flutter/cupertino.dart';
import 'mrz_scan_platform_interface.dart';


class MrzScan {
  Future<String?> getPlatformVersion() {
    return MrzScanPlatform.instance.getPlatformVersion();
  }
  Future<Map?>  openOCR(BuildContext context) {
    return MrzScanPlatform.instance.openOCR(context);
  }
}
