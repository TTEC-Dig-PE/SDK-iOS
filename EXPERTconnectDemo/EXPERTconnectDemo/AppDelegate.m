//
//  AppDelegate.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "Bugsnag.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <AirshipKit/AirshipKit.h>
#import <AirshipKit/UAPush.h>

#import "ECDDefaultTheme.h"
#import "ECDRootViewController.h"
#import "ECDSplashViewController.h"
#import "ECDUserDefaultKeys.h"
#import "ECDLocalization.h"

static NSString * const ECDFirstRunComplete = @"ECDFirstRunComplete";

@interface AppDelegate () {
    AppConfig *myAppConfig;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Log NSLog to a file, so we can do bug reports, but only for release builds ("in the field").
#ifdef DEBUG
    // No-op: Allow NSLog to go to XCode console.
#else
    [ECDBugReportEmailer setUpLogging];
#endif
    
    [self setupUrbanAirship];
    
    // [Bugsnag startBugsnagWithApiKey:@"e752129652005fc3911fce42873a1573"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setTintColor:[UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1]];
    
    // Override point for customization after application launch.
    UIViewController *rootViewController = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout:)
                                                 name:ECSUserSessionInvalidNotification
                                               object:nil];
    
    NSNumber *firstRunComplete = [[NSUserDefaults standardUserDefaults] objectForKey:ECDFirstRunComplete];
    if (!firstRunComplete)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                                  forKey:ECDFirstRunComplete];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[EXPERTconnect shared] setUserName:nil];
    }
    
    [self setApplicationDefaults]; 
    
    
    
    // Initialize the SDK
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    myAppConfig = [AppConfig sharedAppConfig];
    
    configuration.appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    configuration.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    configuration.appId = @"12345";
    configuration.cafeXHost = @"dce1.humanify.com"; // Demo not working yet: @"donkey.humanify.com";
    configuration.cafeXAssistHost = @"https://cafex.dts.humanify.com:443";
    
    // Old authentication method.
    configuration.host = [myAppConfig getHostURL];
    configuration.clientSecret = @"secret123";
    
    configuration.defaultNavigationContext = @"personas";
    configuration.defaultNavigationDisplayName = ECDLocalizedString(ECDLocalizedLandingViewTitle, @"Personas");
    
    configuration.breadcrumbCacheCount = 3; // Wait for 3 breadcrumbs before sending.
    configuration.breadcrumbCacheTime = 25; // Wait 25 seconds before sending breadcrumbs.
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    [[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    
    // Fetch the authToken from our webApp
    [myAppConfig setupAuthenticationDelegate]; // Sets the auth retry delegate
    
    [myAppConfig fetchAuthenticationToken:^(NSString *authToken, NSError *error)
     {
         if (!error) {
             [[EXPERTconnect shared] setUserIdentityToken:authToken];
         }
        
         [myAppConfig startBreadcrumbSession];
     }];
    
    [self setThemeFromSettings];
    
    // Setup the theme to look similar to Ford.
    //[self setupThemeLikeFord];
    
    [[EXPERTconnect shared] setUserAvatar:[UIImage imageNamed:@"default_avatar_medium"]];
    
    // Get env/clientid config from hosted site.
    [myAppConfig fetchEnvironmentJSON];
    
    [[EXPERTconnect shared] setUserIntent:@"mutual funds"];
        
    // If we are authenticated, skip the login view.
    if ([[EXPERTconnect shared] authenticationRequired])
    {
        rootViewController = [[ECDSplashViewController alloc] init];
    }
    else
    {
        rootViewController = [[ECDRootViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    [self.window setRootViewController:rootViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UA_LTRACE(@"APNS device token: %@", deviceToken);
    
    // Updates the device token and registers the token with UA. This won't occur until
    // push is enabled if the outlined process is followed. This call is required.
    [[UAirship push] appRegisteredForRemoteNotificationsWithDeviceToken:deviceToken];
    [EXPERTconnect shared].pushNotificationID = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Display an in-app alert for push notifications.
    NSString *pushAlertText = [userInfo valueForKeyPath:@"aps.alert"];
    if (pushAlertText && pushAlertText.length > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Alert"
                                                        message:pushAlertText
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark Helper Functions 

- (void)setApplicationDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
                                                            forKey:@"beaconIdentifier"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
}

- (void)setupUrbanAirship {
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    
#ifdef DEBUG
    config.inProduction = NO;
#else
    config.inProduction = YES;
#endif
    
    // You can also programmatically override the plist values:
    // config.developmentAppKey = @"YourKey";
    // etc.
    
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    
    NSNumber *pushEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:ECDPushNotificationsEnabledKey];
    
    if (!pushEnabled || pushEnabled.boolValue)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:ECDPushNotificationsEnabledKey];
        
        [UAirship push].userNotificationTypes = (UIUserNotificationTypeAlert |
                                                 UIUserNotificationTypeBadge |
                                                 UIUserNotificationTypeSound);
        [UAirship push].userPushNotificationsEnabled = YES;
    }
    else
    {
        [UAirship push].userPushNotificationsEnabled = NO;
    }
    
    [[UAirship push] resetBadge];
    
    NSLog(@"Urban Airship Channel ID=%@, DeviceToken=%@",[UAirship push].channelID, [UAirship push].deviceToken);
}

- (void)reportBug {
    if (_bugReportEmailer == nil) {
        _bugReportEmailer = [[ECDBugReportEmailer alloc] init];
    }
    [_bugReportEmailer reportBug];
}

- (void)logout:(NSNotification*)notification
{    
    ECDSplashViewController *splashController = [[ECDSplashViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = splashController;
    [self.window makeKeyAndVisible];
}

- (void)setThemeFromSettings
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSString *theme = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeType"];
    if ([theme isEqualToString:@"Dark Theme"])
    {
        [[EXPERTconnect shared] setTheme:[ECDDefaultTheme new]];
        return;
    }

    
    for (NSDictionary *item in preferences) {
        NSString *key = [item objectForKey:@"Key"];
        if ([key isEqualToString:@"themeType"]) {
            if ([item objectForKey:@"DefaultValue"]) {
                if ([[item objectForKey:@"DefaultValue"] isEqualToString:@"Dark Theme"])
                {
                    [[EXPERTconnect shared] setTheme:[ECDDefaultTheme new]];
                    break;
                }
            }
        }
    }
}

@end
