//
//  ECSCafeXController.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

/* CafeX To-Do:
  - Add attributes to Chat request to indicate video mode (see below) and Pass the "username" for target
    -- Until this is available, ASSUME a mode and hardcode a target username
  - IMP Needs new menu items to Dial (and logic to auto-Dial) based on above
  - Make various config items part of ECS Configuration (or elsewhere as appropriate)
  - Need to request camera access at the correct spot (when requesting a video call or when dialing one (IMP)).
  - Use the logged-in SDK username instead of below identifierForVendor  (make unique by prepending with tenant? etc?)
  - Get new iPad and test/finish video code
  - Create View / VC to house preview & remote videos and to show option buttons (transparent? fullscreen?)
  - Handle connectivity errors
  - Implement (at least for logging) all Delegate methods
  - Consumer should end Session and clear out cafeXConnection object when video session ends (or chat ends?! Decide).
 
  - OPTIONAL: Decide between tt:command vs AED for doing remote commands. Might not be needed (yet)...
  - OPTIONAL: Experiment with adding LiveAssist - ask Kevin for details
 */

/* How to access CafeXController from anywhere in SDK:

 ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
 
 // Optionally, do a login if there's no session:
 if (![cafeXController hasCafeXSession]) {
    [cafeXController setupCafeXSession];
 }

*/

/* CafeX Modes:
 
  - Video auto start [mutually exclusive with voice auto, and voice/video escalation]
  - Voice auto start [mutually exclusive with video auto, and voice/video escalation]
  - Video escalation allowed [mutually exclusive with voice and video auto start]
  - Voice escalation allowed [mutually exclusive with voice and video auto start]
  - CafeX Co-Browse escalation allowed (existing Co-Browse Button w/software switch)
 */

/* Options to expose (somewhere?)
 
  - Mute my audio
  - Mute remote audio
  - Hide my camera
  - Revert to audio-only
  - Change from audio-only to video
  - Minimize/Restore video panel
  - End video session
 */

#import "ECSConfiguration.h"
#import "ECSCafeXController.h"
#import "ECSURLSessionManager.h"
#import "ECSRootViewController.h"
#import "ECSInjector.h"
#import "UIViewController+ECSNibLoading.h"

@implementation ECSCafeXController

- (void) setupCafeXSession {
    if (cafeXConnection == nil) {
        [self loginToCafeX];
    } else {
        [cafeXConnection startSession];
    }
}

- (void) setupCafeXSessionWithTask:(void (^)(void))task {
    self.postLoginTask = task;
    if (cafeXConnection == nil) {
        [self loginToCafeX];
    } else {
        [cafeXConnection startSession];
    }
}

- (BOOL) hasCafeXSession {
    return cafeXConnection != nil;
}

- (void) loginToCafeX {
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    // TODO: Get App Server host from configuration (need to add to all host apps too)
    
    username = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    server = @"dcapp01.ttechenabled.net"; // TODO: Store somewhere
    port = @"443"; // TODO: Store somewhere
    
    NSString *URL    = [NSString stringWithFormat:@"https://%@:%@/cafexproxy/cafexproxy/getsession?u=%@", server, port, username];

    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [sessionManager externalRequestWithMethod:@"GET"
                                         path:URL
                                   parameters:nil
                                      success:^(id result, NSURLResponse *response) {
                                          if ([result isKindOfClass:[NSDictionary class]]) {
                                              configuration = [result valueForKey:@"sessionid"];
                                              NSLog(@"CafeX Got session ID: %@", configuration);
                                              cafeXConnection = [ACBUC ucWithConfiguration:configuration delegate:self];
                                              
                                              [self registerForReachabilityCallback];
                                              
                                              // TODO?
                                              /*
                                               BOOL acceptUntrustedCertificates = [[[NSUserDefaults standardUserDefaults] objectForKey:@"acceptUntrustedCertificates"] boolValue];
                                               [_uc acceptAnyCertificate:acceptUntrustedCertificates];
                                               
                                               NSNumber *useCookiesNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"useCookies"];
                                               _uc.useCookies = [useCookiesNumber boolValue];
                                               */
                                              
                                              [cafeXConnection startSession];
                                          } else {
                                              NSLog(@"CafeX Error: result is not a Dictionary!");
                                              NSMutableDictionary *userInfo = [NSMutableDictionary new];
                                              userInfo[NSLocalizedFailureReasonErrorKey] = @"Result is not a Dictionary";
                                              // can't call failure block... ?
                                          }
                                      }
                                      failure:^(id result, NSURLResponse *response, NSError *error) {
                                          NSLog(@"CafeX Error calling getSession: %@", error);
                                      }];
}

- (void)dial:(NSString *)target withVideo:(BOOL)vid andAudio:(BOOL)aud usingParentViewController:(ECSRootViewController *)parent {
    [ECSCafeXController requestCameraAccess];
    
    _cafeXVideoViewController = [ECSCafeXVideoViewController ecs_loadFromNib];
    [parent presentModal:_cafeXVideoViewController withParentNavigationController:parent.navigationController];
    
    ACBClientPhone* phone = cafeXConnection.phone;
    phone.delegate = self;
    phone.previewView = _cafeXVideoViewController.previewVideoView;
    ACBClientCall* call = [phone createCallToAddress:target audio:aud video:vid delegate:self];
    
    if (call)
    {
        call.videoView = _cafeXVideoViewController.remoteVideoView;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"ERROR (for call)" message:@"A call must be created with media." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void) endCafeXSession {
    NSLog(@"CafeX Starting logout - Server %@ Configuration %@", server, configuration);
    
    NSString *URL = [NSString stringWithFormat:@"https://%@:%@/cafexproxy/cafexproxy/endsession?id=%@", server, port, configuration];
    
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [sessionManager externalRequestWithMethod:@"GET"
                                         path:URL
                                   parameters:nil
                                      success:^(id result, NSURLResponse *response) {
                                          // TODO
                                      }
                                      failure:^(id result, NSURLResponse *response, NSError *error) {
                                          NSLog(@"CafeX Error calling endSession: %@", error);
                                      }];
}

+ (void) requestCameraAccess {
    [ACBClientPhone requestMicrophoneAndCameraPermission:TRUE video:TRUE];
}

#pragma mark - ACBUCDelegate


/**
 * A notification to indicate that the session has been initialised successfully.
 */
- (void) ucDidStartSession:(ACBUC *)uc
{
    NSLog(@"CafeX DidStartSession (Success)");
    
    if (self.postLoginTask) {
        self.postLoginTask();
    }
}

/**
 * A notification to indicate that initialisation of the session failed.
 */
- (void) ucDidFailToStartSession:(ACBUC *)uc
{
    // TODO: Translate
    NSLog(@"CafeX DidFailToStartSession");
    [[[UIAlertView alloc] initWithTitle:@"Registration error" message:@"CafeX Registration failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

/**
 * A notification to indicate that the session has been invalidated due to a network drop.
 *
 * @param uc
 *            The UC.
 */
- (void) ucDidLoseConnection:(ACBUC *)uc
{
        // TODO: Translate
    NSLog(@"CafeX DidLoseConnection");
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"CafeX Lost network connection. Please log in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self endCafeXSession];
    // TODO On loss of connection - perform new login
}

- (void) ucDidReceiveSystemFailure:(ACBUC *)uc
{
        // TODO: Translate
    NSLog(@"CafeX DidReceiveSystemFailure");
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"CafeX System failure. Please log in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self endCafeXSession];
}

# pragma mark - ACBClientCallDelegate

- (void) phone:(ACBClientPhone*)phone didReceiveCall:(ACBClientCall*)call
{
    // TODO: Pop up a answer/reject dialog?
    [call answerWithAudio:YES video:YES];
}

- (void) call:(ACBClientCall *)call didReceiveCallRecordingPermissionFailure:(NSString *)message
{
    // TODO: Translate
    NSLog(@"CafeX Error: No permission to access camera or microphone! %@", message);
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to initiate call: You have not given permission to access the camera or microphone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    // TODO: Kill session?
}

#pragma mark - Reachability
- (void)registerForReachabilityCallback
{
    // Do any additional setup after loading the view.
    self.reachabilityManager = [[ReachabilityManager alloc] init];
    [self.reachabilityManager addListener:self];
    [self.reachabilityManager registerForReachabilityTo:server];
}

- (void)unregisterForReachabilityCallback
{
    // remove the reachability callback listener
    if (self.reachabilityManager != nil)
    {
        [self.reachabilityManager removeListener:self];
    }
}

#pragma mark - ReachabilityManagerListener
- (void) reachabilityDetermined:(BOOL)reachability
{
    NSLog(@"Network reachability changed to:%@ - here the application has the chance to inform the user that connectivitiy is lost", reachability ? @"YES" : @"NO");
    [cafeXConnection setNetworkReachable:reachability];
}

@end