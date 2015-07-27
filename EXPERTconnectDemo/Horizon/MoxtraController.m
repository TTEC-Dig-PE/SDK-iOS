//
//  MoxtraPanel.m
//  IMP
//
//  Created by Nathan Keeney 6/8/2015
//  Copyright (c) 2015 Humanify. All rights reserved.
//

#import "MoxtraController.h"
#import "HZAppDelegate.h"

@implementation MoxtraController

- (void)loadContent:(void(^)())successCallback
            failure:(void(^)(NSError *error))failureCallback
{
    // Fill in the App Client ID and Client Secret Key received from the app registration step from Moxtra
    NSString *APP_CLIENT_ID = @"kmj58QllU_Y";
    NSString *APP_CLIENT_SECRET = @"tEhhCeXbIQM";
    
    NSLog(@"Initializing Moxtra SDK");
    
    // Set up Moxtra SDK
    // Set the serverType to productionServer when pointing your app to production environment
    [Moxtra clientWithApplicationClientID:APP_CLIENT_ID applicationClientSecret:APP_CLIENT_SECRET serverType: sandboxServer ];
    
    NSLog(@"Registering Moxtra user %@", [EXPERTconnect shared].userToken);
    
    // Initialize user using unique user identity
    MXUserIdentity *useridentity = [[MXUserIdentity alloc] init];
    useridentity.userIdentityType = kUserIdentityTypeIdentityUniqueID;
    useridentity.userIdentity = [EXPERTconnect shared].userToken;
    
    [[Moxtra sharedClient]
     initializeUserAccount: useridentity
     orgID: nil
     firstName: [EXPERTconnect shared].userDisplayName
     lastName: @""
     avatar: nil
     devicePushNotificationToken: nil
     success:successCallback
     failure:failureCallback];
    
    NSLog(@"Starting Moxtra Meet DemoAppMeet1");
}

- (void)startMeet:(void(^)(NSString *meetID))successCallback
          failure:(void(^)(NSError *error))failureCallback {
    NSLog(@"Starting Moxtra Meet DemoAppMeet1");
    [[Moxtra sharedClient]
     startMeet: @"DemoAppMeet1"
     withDelegate: self
     inviteAttendeesBlock: nil
     success: successCallback
     failure: failureCallback];
}

- (void)endMeet {
    [[Moxtra sharedClient] stopMeet];
}

#pragma mark - MXClientMeetDelegate

- (BOOL)supportAutoStartScreenShare {
     return TRUE;
}
- (BOOL)beSupportInviteContactsBySMS {
    return FALSE;
}
- (BOOL)beSupportInviteContactsByEmail {
    return FALSE;
}
- (BOOL)hideInviteButton {
    return YES;
}
- (BOOL)supportAutoJoinAudio {
    return FALSE;
}

/**
 * Return YES if the 3rd party need hide bottom control bar automatically when start or join meet. The default value is NO;
 */
- (BOOL)autoHideControlBar {
    return YES;
}

/**
 * Return NO if the 3rd party need disable VoIP and hide the VoIP button.
 */
- (BOOL)supportVoIP {
    return NO;
}

/**
 * Return NO if the 3rd party need disable chat and hide the chat button.
 */
- (BOOL)supportChat {
    return NO;
}

- (void)meetEnded {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationScreenShareEnded" object:nil];
}

@end
