import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mrz_scan/mrz_scan_method_channel.dart';

void main() {
  MethodChannelMrzScan platform = MethodChannelMrzScan();
  const MethodChannel channel = MethodChannel('mrz_scan');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
