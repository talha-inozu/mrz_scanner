import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrz_scan/mrz_scan.dart';
import 'package:mrz_scan/mrz_scan_platform_interface.dart';
import 'package:mrz_scan/mrz_scan_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMrzScanPlatform
    with MockPlatformInterfaceMixin
    implements MrzScanPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map?> openOCR(BuildContext context) {
    // TODO: implement openOCR
    throw UnimplementedError();
  }
}

void main() {
  final MrzScanPlatform initialPlatform = MrzScanPlatform.instance;

  test('$MethodChannelMrzScan is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMrzScan>());
  });

  test('getPlatformVersion', () async {
    MrzScan mrzScanPlugin = MrzScan();
    MockMrzScanPlatform fakePlatform = MockMrzScanPlatform();
    MrzScanPlatform.instance = fakePlatform;

    expect(await mrzScanPlugin.getPlatformVersion(), '42');
  });
}
