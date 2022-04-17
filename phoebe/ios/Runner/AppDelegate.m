#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Firebase.h>
#include "FlutterDownloaderPlugin.h"

@implementation AppDelegate

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
  if (![registry hasPlugin:@"FlutterDownloaderPlugin"]) {
     [FlutterDownloaderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterDownloaderPlugin"]];
  }
}


- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    int flutter_native_splash = 1;
    UIApplication.sharedApplication.statusBarHidden = false;

 
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [FlutterDownloaderPlugin setPluginRegistrantCallback:registerPlugins];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
