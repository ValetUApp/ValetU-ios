//
//  AppDelegate.m
//  valetu
//
//  Created by imobile on 2016-09-05.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

+ (void)initialize
{
    [FBSDKProfilePictureView class];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
    // China based apps should specify the region
  //  [UBSDKConfiguration setRegion:RegionChina];
    // If true, all requests will hit the sandbox, useful for testing
    [UBSDKConfiguration setSandboxEnabled:NO];
    // If true, Native login will try and fallback to using Authorization Code Grant login (for privileged scopes). Otherwise will redirect to App store
    [UBSDKConfiguration setFallbackEnabled:YES];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
        
    [Mixpanel sharedInstanceWithToken:MIX_PANEL_TOKEN];
    
    [self initVariables];

    return YES;
}

- (void) initVariables
{
    [Parkinglot sharedModel].selectedLocationId = -1;
    
    [[Mixpanel sharedInstance] track:@"Valetu"
         properties:@{ @"Event": @"Start" }];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
}

// iOS 9+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

// iOS 8
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
