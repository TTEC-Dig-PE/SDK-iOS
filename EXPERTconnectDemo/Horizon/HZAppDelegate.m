//
//  HZAppDelegate.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 18/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZAppDelegate.h"
#import "HZDrawerViewController.h"
#import "HZRootViewController.h"
#import "HZLoginViewController.h"

#import "HZExpertConnectSDKTheme.h"

#import <MMDrawerController/MMDrawerController.h>

//#define ENVIRONMENT_DEMO 1
#define ENVIRONMENT_DEV 1

@interface HZAppDelegate ()
@property (nonatomic, strong) MMDrawerController *drawerController;

@property (nonatomic, strong) HZMainScreenViewController *mainViewController;
@property (nonatomic, strong) HZPerformanceViewController *performanceViewController;
@property (nonatomic, strong) HZResearchViewController *researchViewController;
@property (nonatomic, strong) HZRiskViewController *riskViewController;

@property (strong, nonatomic) UINavigationController *chatNavigationController;
@property (strong, nonatomic) UIView *dimmingOverlayView;
@property (strong, nonatomic) UIButton *chatBubble;

@end


@implementation HZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setUpEXPERTConnectSDK];
    [self setUpWindow];

    if ([[EXPERTconnect shared] authenticationRequired]) {
        [self showLoginScreen];
    }
    else {
        [self showDrawerAndMainScreen];
    }
    
    return YES;
}

- (void)setUpWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setTintColor:[UIColor colorWithRed:0.859f green:0.173f blue:0.137f alpha:1.0f]];
    [self.window makeKeyAndVisible];
}

- (void)showLoginScreen {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    HZLoginViewController *loginVC = [[HZLoginViewController alloc] initWithNibName:nil bundle:nil];
    [self updateRootViewControllerAnimated:loginVC];
}

- (void)showDrawerAndMainScreen {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _mainViewController = [[HZMainScreenViewController alloc] initWithNibName:nil bundle:nil];
    HZDrawerViewController *drawerVC = [[HZDrawerViewController alloc] initWithNibName:nil bundle:nil];
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:_mainViewController
                                                            leftDrawerViewController:drawerVC];
    
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    self.drawerController.shouldStretchDrawer = NO;
    self.drawerController.maximumLeftDrawerWidth = 320.0;
    [self updateRootViewControllerAnimated:self.drawerController];
}

#pragma mark - ExpertConnectSDK set up methods

- (void)setUpEXPERTConnectSDK {

    // ECS logout notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout:)
                                                 name:ECSUserSessionInvalidNotification
                                               object:nil];

    // ECS configuration
    ECSConfiguration *configuration = [ECSConfiguration new];
    configuration.appName = @"EXPERTconnect Demo";
    configuration.appVersion = @"1.0";
    configuration.appId = @"M2M00001";
    configuration.host = [self EXPERTConnectSDKhostURLFromSettings];
    configuration.clientID = @"horizon";
    configuration.clientSecret = @"secret123";
    configuration.defaultNavigationContext = @"personas";
    configuration.defaultNavigationDisplayName = @"Horizon Customer Care";
    configuration.defaultAnswerEngineContext = @"Telecommunications";
    configuration.defaultSurveyFormName = @"Mutual Fund Satisfaction";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    [[EXPERTconnect shared] setDelegate:self];
    [self setUpEXPERTConnectSDKThemeFromSettings];

    // Reset current user
    [[EXPERTconnect shared] setUserToken:nil];
    
    // Reset current user
    [[EXPERTconnect shared] setUserToken:nil];
    
    // Moxtra
    // NK 6/17
    _moxtraController = [[MoxtraController alloc] init];
}

- (void)logout:(NSNotification*)notification {
    [self showLoginScreen];
}

- (NSString *)EXPERTConnectSDKhostURLFromSettings {
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
    if (!url || url.length == 0) {
        //url = @"http://uldcd-cldap02.ttechenabled.net:8080";
#ifdef ENVIRONMENT_DEMO
        url = @"http://demo.humanify.com";
#else
        url = @"http://api.humanify.com:8080";
#endif
    }
    
    return url;
}

- (void)setUpEXPERTConnectSDKThemeFromSettings {
    [[EXPERTconnect shared] setTheme:[HZExpertConnectSDKTheme new]];

//    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
//    
//    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
//    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
//    
//    NSString *theme = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeType"];
//    if ([theme isEqualToString:@"Dark Theme"])
//    {
//        [[EXPERTconnect shared] setTheme:[HZExpertConnectSDKTheme new]];
//        return;
//    }
//    
//    
//    for (NSDictionary *item in preferences) {
//        NSString *key = [item objectForKey:@"Key"];
//        if ([key isEqualToString:@"themeType"]) {
//            if ([item objectForKey:@"DefaultValue"]) {
//                if ([[item objectForKey:@"DefaultValue"] isEqualToString:@"Dark Theme"])
//                {
//                    [[EXPERTconnect shared] setTheme:[HZExpertConnectSDKTheme new]];
//                    break;
//                }
//            }
//        }
//    }
}

#pragma mark - ExpertConnectSDK delegate methods

// Implementation of ExpertConnectDelegate
- (void)meetRequested:(void(^)(NSString *meetID))meetStartedCallback {
    
    // Initialize Moxtra and send a tt:command back with the MeetID:
    [[self moxtraController] loadContent:^{
        NSLog(@"Setup user account successfully");
        
        [[self moxtraController] startMeet:^(NSString *meetID) {
            NSLog(@"Start meet successfully with MeetID [%@]", meetID);
            
            meetStartedCallback(meetID);
        } failure: ^(NSError *error) {
            NSLog(@"Start meet failed, %@", [NSString stringWithFormat:@"error code [%d] description: [%@] info [%@]", [error code], [error localizedDescription], [[error userInfo] description]]);
            
            meetStartedCallback(nil);
        }];
    } failure: ^(NSError *error) {
        NSLog(@"Setup user account failed, %@", [NSString stringWithFormat:@"error code [%d] description: [%@] info [%@]", [error code], [error localizedDescription], [[error userInfo] description]]);
        
        if ([error code] == 104) {
            // User already logged in. Continue.
            [[self moxtraController] startMeet:^(NSString *meetID) {
                NSLog(@"Start meet successfully with MeetID [%@]", meetID);
                
                meetStartedCallback(meetID);
            } failure: ^(NSError *error) {
                NSLog(@"Start meet failed, %@", [NSString stringWithFormat:@"error code [%d] description: [%@] info [%@]", [error code], [error localizedDescription], [[error userInfo] description]]);
                
                meetStartedCallback(nil);
            }];
        }
    }];
}

- (void)meetNeedstoEnd {
    [_moxtraController endMeet];
}

- (void)expertConnectCloseButtonTapped:(EXPERTconnect *)connect {
    [self dismissChatWindow];
}

- (void)expertConnectMinimizeButtonTapped:(EXPERTconnect *)connect {
    [self minimizeChatWindow];
}

#pragma mark - Helper methods

- (void)updateRootViewControllerAnimated:(UIViewController *)viewController {
    
    viewController.view.frame = self.window.bounds;
    
    if (self.window.rootViewController) {
        [UIView
         transitionFromView:self.window.rootViewController.view
         toView:viewController.view
         duration:0.25f
         options:UIViewAnimationOptionTransitionCrossDissolve
         completion:^(BOOL finished){
             [self.window setRootViewController:viewController];
         }];
    }
    else {
        [self.window setRootViewController:viewController];
    }
}

#pragma mark - Chat Window

- (void)minimizeChatWindow {
    
    // enable side drawer swipe
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    CGSize targetSize = CGSizeMake(66, 66);
    UIEdgeInsets insets = UIEdgeInsetsMake(80, 20, 20, 20);
    
    CGRect superBounds = self.drawerController.view.bounds;
    CGRect targetFrame = CGRectMake(superBounds.size.width - targetSize.width - insets.right,
                                    insets.top,
                                    targetSize.width,
                                    targetSize.height);
    
    
    //chat bubble
    self.chatBubble = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chatBubble.backgroundColor = [UIColor darkGrayColor];
    self.chatBubble.layer.cornerRadius = 10.0;
    self.chatBubble.layer.borderWidth = 2.0;
    self.chatBubble.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.chatBubble setTitle:@"chat" forState:UIControlStateNormal];
    [self.chatBubble addTarget:self action:@selector(maximizeChatWindow) forControlEvents:UIControlEventTouchUpInside];
    
    [self.drawerController.view addSubview:self.chatBubble];
    
    
    // animate
    [self.chatBubble setFrame:self.chatNavigationController.view.frame];
    [self.chatBubble setAlpha:0.0];
    [self.dimmingOverlayView setAlpha:1.0];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.chatNavigationController.view setFrame:targetFrame];
        [self.chatBubble setFrame:self.chatNavigationController.view.frame];
        [self.chatBubble setAlpha:1.0];
        [self.dimmingOverlayView setAlpha:0.0];
    
    } completion:^(BOOL finished) {
    
    }];
}

- (void)maximizeChatWindow {

    // enable side drawer swipe
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    CGRect chatFrame = CGRectMake(0, 100, [self chatWindowSize].width, [self chatWindowSize].height);

    // animate
    [self.chatBubble setAlpha:1.0];
    [self.dimmingOverlayView setAlpha:0.0];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.chatBubble setFrame:chatFrame];
        [self.chatBubble setCenter:self.drawerController.view.center];
        [self.chatNavigationController.view setFrame:chatFrame];
        [self.chatNavigationController.view setCenter:self.drawerController.view.center];
        
        [self.chatBubble setAlpha:0.0];
        [self.dimmingOverlayView setAlpha:1.0];
        
    } completion:^(BOOL finished) {
        [self.chatBubble removeFromSuperview];
    }];

}


- (void)presentChatWindow {
    
    UIView *dummyView = [[UIView alloc] init];
    dummyView.backgroundColor = [UIColor redColor];
    
    // prevent side drawer swipe
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    UIViewController *controller = [[EXPERTconnect shared] landingViewController];
    self.chatNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.chatNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.chatNavigationController.navigationBar.translucent = NO;
    
    //this is a hack to make it look like a UIModalPresentationFormSheet
    //also note that the inital yposition of the frame is offset by 100, or the navbar becomes 64
    //instead of 44.0;
    CGRect chatFrame = CGRectMake(0, 100, [self chatWindowSize].width, [self chatWindowSize].height);
    self.chatNavigationController.view.frame = chatFrame;

    // add dimming overlay
    self.dimmingOverlayView = [[UIView alloc] initWithFrame:self.drawerController.view.bounds];
    self.dimmingOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.drawerController.view addSubview:self.dimmingOverlayView];

    // add as childViewController
    [self.dimmingOverlayView addSubview:self.chatNavigationController.view];
    [self.drawerController addChildViewController:self.chatNavigationController];
    [self.drawerController didMoveToParentViewController:self.chatNavigationController];

    // visuals
    self.chatNavigationController.view.layer.cornerRadius = 10.0;
    self.chatNavigationController.view.layer.borderWidth = 1.0;
    self.chatNavigationController.view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.chatNavigationController.view.clipsToBounds = YES;

    // animate
    CGPoint endCenter = self.drawerController.view.center;
    CGPoint startCenter = CGPointMake(endCenter.x, endCenter.y + 1000);

    [self.chatNavigationController.view setCenter:startCenter];
    [self.dimmingOverlayView setAlpha:0.0];
    [UIView animateWithDuration:0.5 animations:^{
        [self.chatNavigationController.view setCenter:endCenter];
        [self.dimmingOverlayView setAlpha:1.0];
    }];
}

- (void)dismissChatWindow {
    
    // enable side drawer swipe
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    // animate out
    CGPoint endCenter = self.drawerController.view.center;
    CGPoint startCenter = CGPointMake(endCenter.x, endCenter.y + 1000);
    
    [self.chatNavigationController.view setCenter:endCenter];
    [self.dimmingOverlayView setAlpha:1.0];
    [UIView animateWithDuration:0.5 animations:^{
        [self.chatNavigationController.view setCenter:startCenter];
        [self.dimmingOverlayView setAlpha:0.0];
    } completion:^(BOOL finished) {
        
        //finally remove
        [self.dimmingOverlayView removeFromSuperview];
        [self.chatNavigationController willMoveToParentViewController:nil];
        [self.chatNavigationController.view removeFromSuperview];
        [self.chatNavigationController removeFromParentViewController];
    }];
    
}

#pragma mark - Helpers

- (CGSize)chatWindowSize {
    return CGSizeMake(540, 620);
}

#pragma mark - Drawer View Controllers

- (HZMainScreenViewController *)mainViewController {
    if (_mainViewController == nil) {
        _mainViewController = [[HZMainScreenViewController alloc] initWithNibName:nil bundle:nil];
    }
    return _mainViewController;
}

- (HZPerformanceViewController *)performanceViewController {
    if (_performanceViewController == nil) {
        _performanceViewController = [[HZPerformanceViewController alloc] initWithNibName:nil bundle:nil];
    }
    return _performanceViewController;
}

- (HZResearchViewController *)researchViewController {
    if (_researchViewController == nil) {
        _researchViewController = [[HZResearchViewController alloc] initWithNibName:nil bundle:nil];
    }
    return _researchViewController;
}

- (HZRiskViewController *)riskViewController {
    if (_riskViewController == nil) {
        _riskViewController = [[HZRiskViewController alloc] initWithNibName:nil bundle:nil];
    }
    return _riskViewController;
}

@end
