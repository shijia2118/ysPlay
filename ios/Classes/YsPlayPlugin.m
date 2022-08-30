#import "YsPlayPlugin.h"
#if __has_include(<ys_play/ys_play-Swift.h>)
#import <ys_play/ys_play-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ys_play-Swift.h"
#endif

@implementation YsPlayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYsPlayPlugin registerWithRegistrar:registrar];
}
@end
