#import "YsPlayPlugin.h"
#if __has_include(<ys_play/ys_play-Swift.h>)
#import <ys_play/ys_play-Swift.h>
#else

#import "ys_play-swift.h"
#endif

@implementation YsPlayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftYsPlayPlugin registerWithRegistrar:registrar];
}
@end
