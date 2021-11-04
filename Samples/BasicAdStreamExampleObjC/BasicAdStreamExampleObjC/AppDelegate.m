//
//  AppDelegate.m
//  BasicAdStreamExampleObjC
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

#import "AppDelegate.h"
#import <AdswizzSDK/AdswizzSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize AASDKAdswizzSDK.
    // Note that AASDKAdswizzSDK expects the following in your app's info.plist:
    //  1. an installationId
    //  2. a playerId
    // More details in AASDKAdswizzSettingsKeys.
    NSError *error = nil;
    [AASDKAdswizzSDK.shared initializeWith:nil error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    // Set optional settings for AASDKAdswizzSDK.
    // You can set/change them at any time and the SDK will update accordingly.
    
    // Set the companion banner to stay on screen longer than default (0 seconds)
    AASDKAdCompanionOptions *options = [AASDKAdCompanionOptions new];
    options.extraExposureTime = 5.0; // in seconds
    // Set preferred resource type for companion banner and AdswizzSDK will attempt to match the desired resource.
    // This setting takes effect when the ad(s) start playing and AdswizzSDK selects the media resource to render it for the created companion(s).
    // Otherwise it defaults to first valid resource.
    options.preferredResourceType = AASDKAdCompanionResourceTypeHtml; // default value is AASDKAdCompanionResourceTypeFirstResourceAvailable
    [AASDKAdswizzSDK setAdCompanionOptions:options];
    
    // You may want to pass the GDPR consent status if it applies to your app.
    // You can set the .gdprConsent property whenever you have the info available from your users.
    // Defaults to .notApplicable which means the rules of the GDPR do not apply.
    [[AASDKAdswizzSDK shared] setGdprConsent:AASDKGDPROptionGranted];

    // Same as .gdprConsent, through the .ccpaConfig
    // you define the U.S privacy string if it applies to your app.
    // Defaults to .notApplicable which means the rules of the CCPA do not apply.
    AASDKAdswizzCCPAConfig *ccpaConfig = [[[[[AASDKAdswizzCCPAConfigBuilder new] withExplicitNotice:AASDKCCPAOptionYes] withOptOut:AASDKCCPAOptionNo] withLspa:AASDKCCPAOptionYes] build];
    [[AASDKAdswizzSDK shared] setCcpaConfig:ccpaConfig];
    
    // These settings affect how the SDK handles location if permission is granted at any time.
    // Otherwise they have no effect.
    [[AASDKAdswizzSDK shared] setLocationAccuracy:1000.0]; // in meters
    [[AASDKAdswizzSDK shared] setEnableLocationSignificantChanges:NO];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
