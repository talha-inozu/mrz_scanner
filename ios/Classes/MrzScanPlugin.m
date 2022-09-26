#import "MrzScanPlugin.h"
#if __has_include(<mrz_scan/mrz_scan-Swift.h>)
#import <mrz_scan/mrz_scan-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mrz_scan-Swift.h"
#endif

@implementation MrzScanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMrzScanPlugin registerWithRegistrar:registrar];
}
@end
