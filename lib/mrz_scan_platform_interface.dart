import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mrz_scan_method_channel.dart';

import 'package:flutter/material.dart';

abstract class MrzScanPlatform extends PlatformInterface {
  /// Constructs a MrzScanPlatform.
  MrzScanPlatform() : super(token: _token);

  static final Object _token = Object();

  static MrzScanPlatform _instance = MethodChannelMrzScan();

  /// The default instance of [MrzScanPlatform] to use.
  ///
  /// Defaults to [MethodChannelMrzScan].
  static MrzScanPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MrzScanPlatform] when
  /// they register themselves.
  static set instance(MrzScanPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

   Future<Map?> openOCR(BuildContext context) {
    throw UnimplementedError('openOCR() has not been implemented.');
  }
  
}
