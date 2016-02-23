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

@interface AppDelegate () {
    AppConfig *myAppConfig;
}

@end

@implementation AppDelegate

- (void)setApplicationDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
                                                            forKey:@"beaconIdentifier"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
}

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
    
    [self setApplicationDefaults]; 
    
    // Initialize the SDK
    ECSConfiguration *configuration = [ECSConfiguration new];
    myAppConfig = [AppConfig sharedAppConfig];
    
    configuration.appName = @"EXPERTconnect Demo";
    configuration.appVersion = @"1.0";
    configuration.appId = @"12345";
    configuration.cafeXHost = @"dce1.humanify.com"; // Demo not working yet: @"donkey.humanify.com";
    configuration.cafeXAssistHost = @"https://cafex.dts.humanify.com:443";
    
    // Old authentication method.
    configuration.host = [myAppConfig getHostURL];
    configuration.clientID = [myAppConfig getClientID];
    
    //configuration.host = @"http://demo.humanify.com";
    //configuration.clientID = @"horizon";
    configuration.clientSecret = @"secret123";
    
    // New authentication method.
    // Note: To use new method, grab token from debug and put here. Then, comment out clientID and secret.
    // How to get token: put debug marker on "authToken" and po it from command line.
    //[[EXPERTconnect shared] setUserIdentityToken:@"760a0282-ac35-462e-89e8-28644c6b22c9"];
    //[[EXPERTconnect shared] setUserIdentityToken:@"65c6af55-db6c-4fd2-a1dd-d2ffd01f6fe9"];
    
    configuration.defaultNavigationContext = @"personas";
    configuration.defaultNavigationDisplayName = ECDLocalizedString(ECDLocalizedLandingViewTitle, @"Personas");
    
    configuration.breadcrumbCacheCount = 3; // Wait for 3 breadcrumbs before sending.
    configuration.breadcrumbCacheTime = 25; // Wait 25 seconds before sending breadcrumbs.
    
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
    
    // Fetch the authToken from our webApp
    
    [myAppConfig fetchAuthenticationToken:^(NSString *authToken, NSError *error)
    {
         [[EXPERTconnect shared] setUserIdentityToken:authToken];
         
         [myAppConfig startBreadcrumbSession];
    }];
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    [[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    
    [myAppConfig setupAuthenticationDelegate]; // Sets the auth retry delegate
    
    [self setThemeFromSettings];
    
    // Setup the theme to look similar to Ford.
    [self setupThemeLikeFord];
    
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

- (void)setupThemeLikeFord
{
    /* These are test settings for FORD */
    ECSTheme *myTheme = [EXPERTconnect shared].theme;
    myTheme.chatBubbleCornerRadius = 8;
    myTheme.chatBubbleHorizMargins = 12;
    myTheme.chatBubbleVertMargins = 10;
    
    myTheme.primaryBackgroundColor = [UIColor whiteColor];
    myTheme.secondaryBackgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    myTheme.disabledButtonColor = [UIColor lightGrayColor];
    
    myTheme.userChatTextColor = [UIColor whiteColor];
    myTheme.agentChatTextColor = [UIColor whiteColor];
    myTheme.userChatBackground = [UIColor grayColor];
    myTheme.agentChatBackground =  [UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1];
	 
	 if([[[NSUserDefaults standardUserDefaults]
		  stringForKey:[NSString stringWithFormat:@"%@", ECDShowAvatarImagesKey]] isEqualToString:@"0"])
	 {
		  myTheme.showAvatarImages = NO;
	 }
	 else{
		  myTheme.showAvatarImages = YES;
	 }
	 
	 if([[[NSUserDefaults standardUserDefaults]
		  stringForKey:[NSString stringWithFormat:@"%@", ECDShowChatBubbleTailsKey]] isEqualToString:@"0"])
	 {
		  myTheme.showChatBubbleTails = NO;
	 }
	 else{
		  myTheme.showChatBubbleTails = YES;
	 }

    myTheme.chatFont = [UIFont fontWithName:@"Verdana" size:14];
    [EXPERTconnect shared].theme = myTheme;
    /* End test settings */
}

/*
// mas - 16-oct-2015 - Fetch available environments and clientID's from a JSON file hosted on our server.
- (void) fetchEnvironmentJSON {
    
    //NSURL *url = [[NSURL alloc] initWithString:@"https://tce1.humanify.com/humanify_sdk_orgs.json"];
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

// This function is called by both this app (host app) and the SDK as the official auth token fetch function.
- (void)fetchAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion
{
    
    // add /ust for new method
    NSURL *url = [[NSURL alloc] initWithString:
                  [NSString stringWithFormat:@"%@/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                   [self hostURLFromSettings],
                   [EXPERTconnect shared].userName,
                   [self getClientFromSettings]]];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
         NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         if(!error && (statusCode == 200 || statusCode == 201))
         {
             NSLog(@"Successfully fetched authToken: %@", returnToken);
             completion([NSString stringWithFormat:@"%@", returnToken], nil);
         }
         else
         {
             // If the new way didn't work, try the old way once.
             NSLog(@"ERROR FETCHING AUTHENTICATION TOKEN! StatusCode=%ld, Payload=%@", statusCode, returnToken);
             [self fetchOldAuthenticationToken:completion];
         }
     }];
}

// This function is called by both this app (host app) and the SDK as the official auth token fetch function.
- (void)fetchOldAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion
{
    
    // add /ust for new method
    NSURL *url = [[NSURL alloc] initWithString:
                  [NSString stringWithFormat:@"%@/authServerProxy/v1/tokens?username=%@&client_id=%@",
                   [self hostURLFromSettings],
                   [EXPERTconnect shared].userName,
                   [self getClientFromSettings]]];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
         NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         if(!error && (statusCode == 200 || statusCode == 201))
         {
             NSLog(@"Successfully fetched authToken: %@", returnToken);
             completion([NSString stringWithFormat:@"%@", returnToken], nil);
         }
         else
         {
             NSLog(@"ERROR FETCHING OLD AUTHENTICATION TOKEN! StatusCode=%ld, Payload=%@", statusCode, returnToken);
             
         }
     }];
}
*/

@end
