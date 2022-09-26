import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mrz_scan_platform_interface.dart';
import 'widgets/ocr_page.dart';
import 'package:flutter/material.dart';

/// An implementation of [MrzScanPlatform] that uses method channels.
class MethodChannelMrzScan extends MrzScanPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mrz_scan');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
      @override
  Future<Map?> openOCR(BuildContext context) async {
    final ocr_result =  await Navigator.push(context,MaterialPageRoute(builder: (newcontext) => OCRPage( ctx: newcontext,)));
    return ocr_result;
  }

}
