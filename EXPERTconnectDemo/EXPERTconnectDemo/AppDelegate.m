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

#import "ECDDefaultTheme.h"
#import "ECDRootViewController.h"
#import "ECDSplashViewController.h"
#import "ECDUserDefaultKeys.h"
#import "ECDLocalization.h"

static NSString * const ECDFirstRunComplete = @"ECDFirstRunComplete";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Log NSLog to a file, so we can do bug reports, but only for release builds ("in the field").
#ifdef DEBUG
    // No-op: Allow NSLog to go to XCode console.
#else
    [ECDBugReportEmailer setUpLogging];
#endif
    
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
        [UAPush shared].userPushNotificationsEnabled = YES;
    }
    else
    {
        [UAPush shared].userPushNotificationsEnabled = NO;
    }
    
    [[UAPush shared] resetBadge];
    
    // [Bugsnag startBugsnagWithApiKey:@"e752129652005fc3911fce42873a1573"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setTintColor:[UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1]];
    
    // Initialize the SDK
    //static NSString *const ExpertConnectBaseURL = @"https://monkeypod.io:443/mpapi/TELETECH/ExpertConnect/";
    
//    static NSString *const ExpertConnectBaseURL = @"http://uldcd-cldap02.ttechenabled.net:8080";
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName = @"EXPERTconnect Demo";
    configuration.appVersion = @"1.0";
    configuration.appId = @"12345";
    configuration.host = [self hostURLFromSettings];
    configuration.cafeXHost = @"dcapp01.ttechenabled.net"; // Demo not working yet: @"donkey.humanify.com";
    configuration.clientID = [self getClientFromSettings];
    configuration.clientSecret = @"secret123";
    configuration.defaultNavigationContext = @"personas";
    configuration.defaultNavigationDisplayName = ECDLocalizedString(ECDLocalizedLandingViewTitle, @"Personas");
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    [[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    
    // Start a new journey, then send an "app launch" breadcrumb. 
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *err) {
        if(!err) {
            
            [[EXPERTconnect shared] breadcrumbsSession:@"deviceId"
                                    phonenumber:@"phonenumbr"
                                         osVersion:@"iOSversion"
                                    ipAddress:@"10.0.0.1"
                                           geoLocation:@"geoLocation"
                                            resolution:@"resolution"];

            
            [[EXPERTconnect shared] breadcrumbsAction:@"appLaunch"
                                    actionDescription:[NSString stringWithFormat:@"Launched with client=%@, host=%@", configuration.clientID, configuration.host]
                                         actionSource:@"ECDemo"
                                    actionDestination:@"Humanify"];
        }
    }]; // Start a new journey.
    [self setThemeFromSettings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout:)
                                                 name:ECSUserSessionInvalidNotification
                                               object:nil];
    
    // Override point for customization after application launch.
    UIViewController *rootViewController = nil;
    
    NSNumber *firstRunComplete = [[NSUserDefaults standardUserDefaults] objectForKey:ECDFirstRunComplete];
    if (!firstRunComplete)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                                  forKey:ECDFirstRunComplete];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[EXPERTconnect shared] setUserName:nil];
    }
    
    // Get env/clientid config from hosted site.
    [self fetchEnvironmentJSON];
    
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

- (NSString *)hostURLFromSettings
{
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
    
    if (!url || url.length == 0)
    {
        // url = @"http://uldcd-cldap02.ttechenabled.net:8080";
        url = @"http://api.humanify.com:8080";
    }
    
    return url;
}

// Attempt to grab organization (clientid) from user defaults. Defaults otherwise.
- (NSString *)getClientFromSettings
{
    NSString *currentOrganization = nil;
    NSString *currentEnv = [[NSUserDefaults standardUserDefaults]
                            objectForKey:@"environmentName"];
    
    if (currentEnv) {
        currentOrganization = [[NSUserDefaults standardUserDefaults]
                               objectForKey:[NSString stringWithFormat:@"%@_%@", currentEnv, @"organization"]];
    }
    
    return ( currentOrganization ? currentOrganization : @"mktwebextc" );
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

// mas - 16-oct-2015 - Fetch available environments and clientID's from a JSON file hosted on our server.
- (void) fetchEnvironmentJSON {
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://dce1.humanify.com/humanify_sdk_orgs.json"];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        // The server request has completed. Parse file and store it in user defaults.
        if (!error) {
            
            NSError *serializeError;
            NSMutableDictionary *orgDictionary = [NSJSONSerialization
                                               JSONObjectWithData:data
                                               options:NSJSONReadingMutableContainers
                                               error:&serializeError];
            
            //NSLog(@"Env/Org Json: %@", orgDictionary);
            
            if ([orgDictionary objectForKey:@"environment_config"]) {
                
                NSDictionary *envConfig = [orgDictionary objectForKey:@"environment_config"];
                [[NSUserDefaults standardUserDefaults] setObject:envConfig forKey:@"environmentConfig"];
                
                //NSLog(@"Saving environment config from JSON successful.");
            }
            
        } else {
            NSLog(@"Error fetching env/org JSON file. Error=%@", error);
        }
    }];
}

@end
