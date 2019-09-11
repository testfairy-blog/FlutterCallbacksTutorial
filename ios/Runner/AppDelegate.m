#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate
{
    FlutterMethodChannel* channel;

    // Callbacks
    NSMutableDictionary* callbackById;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];

    // Prepare channel
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    self->channel = [FlutterMethodChannel methodChannelWithName:@"callbacks" binaryMessenger:controller];

    __weak typeof(self) weakSelf = self;
    [self->channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      @try {
          // Find a method with the same name in activity
          SEL method = NSSelectorFromString([call.method stringByAppendingString:@":result:"]);
          
          // Call method if exists
          [weakSelf performSelector: method withObject:call.arguments withObject:result];
      } @catch (NSException *exception) {
          NSLog(exception.description);
          result([FlutterError errorWithCode:@"Exception"
                                     message:exception.description
                                     details:nil]);
      } @finally {
      }
    }];


    // Prepare callback dictionary
    self->callbackById = [NSMutableDictionary new];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void) startListening:(id)args result:(FlutterResult)result {
    // Get callback id
    NSString* currentListenerId = [(NSNumber*) args stringValue];

    // Prepare a timer like self calling task
    void (^callback)(void) = ^() {
        void (^callback)(void) = [self->callbackById valueForKey:currentListenerId];
        if ([self->callbackById valueForKey:currentListenerId] != nil) {
            int time = (int) CFAbsoluteTimeGetCurrent();
            
            [self->channel invokeMethod:@"callListener"
                             arguments:@{
                                 @"id" : (NSNumber*) args,
                                 @"args" : [NSString stringWithFormat:@"Hello Listener! %d", time]
                             }
            ];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), callback);
        }
    };

    // Run task
    [self->callbackById setObject:callback forKey:currentListenerId];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), callback);

    // Return immediately
    result(nil);
}

- (void) cancelListening:(id)args result:(FlutterResult)result {
    // Get callback id
    NSString* currentListenerId = [(NSNumber*) args stringValue];

    // Remove callback
    [self->callbackById removeObjectForKey:currentListenerId];

    // Do additional stuff if required to cancel the listener
    
    result(nil);
}

@end
