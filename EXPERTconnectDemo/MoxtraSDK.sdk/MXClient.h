//
//  MXClient.h
//  MoxtraSDK
//
// Created by KenYu on 6/16/14.
// Copyright (c) 2013 Moxtra, Inc. All rights reserved.
//
// Check detail information in Moxtra SDK API documents.
//

// The domain for error responses from API calls
extern NSString *const MXClientErrorDomain;

// The MXClient may also return other NSError objects from other domains, such as
// * NSURLError domain

//Error code
typedef NS_ENUM(NSInteger, MXClientErrorCode) {
    
    MXClientErrorUnknownStatusCode = -3000,
    
    MXClientErrorNetworkError = 101,
    
    MXClientErrorUserLoginFailed = 102,
    MXClientErrorUserLoginCancelled = 103,     //The login operation failed because the user dismissed the dialog without logging in.
    MXClientErrorUserAccountAlreadyExist = 104,
    MXClientErrorUserAccountSetupFailed = 105,
    MXClientErrorInvalidUniqueID = 106,
    MXClientErrorInvalidAccessToken = 107,
    MXClientErrorGetAccessTokenFailed = 108,
    
    //Update user's profile
    MXClientErrorUpdateUserProfileFailed = 130,
    
    //Meet
    MXClientErrorMeetAlreadyStarted = 200,
    MXClientErrorMeetStartFailed = 201,
    MXClientErrorMeetJoinFailed = 202,
    MXClientErrorInvalidMeetID = 203,
};


#pragma mark -
//Delegate
@protocol MXClientMeetDelegate <NSObject>
@optional

/**
 * Called when the Moxtra Screen Share Meet is ending.
 */
- (void)meetEnded;

/**
 * Return YES if the 3rd party need hide invite button.
 */
- (BOOL)hideInviteButton;

/**
 * Return YES if the 3rd party need join audio automatically when start or join meet. The default values is YES.
 */
- (BOOL)supportAutoJoinAudio;

/**
 * Return YES if the 3rd party need start screen share automatically when start meet. The default values is YES.
 */
- (BOOL)supportAutoStartScreenShare;

/**
 * Called when the user invite attendees via pressing invite button in meet. The default values are both YES.
 */
- (BOOL)supportInviteContactsBySMS;
- (BOOL)supportInviteContactsByEmail;

/**
 * Called when the user invite attendees via pressing invite button in meet. Return the customized subject/body.
 * There will be default subject/body if return value is null.
 */
- (NSString *)bodyOfSMSContentWithMeetLink:(NSString*)meetLink;
- (NSString *)subjectOfEmailContent;
- (NSString *)HTMLBodyOfEmailContentWithMeetLink:(NSString*)meetLink;

/**
 * Called when the 3rd party need customize invite message in chat panel in meet. Return the customized invite message.
 * There will be default invite message if return value is null.
 */
- (NSString *)customizedInviteMessage:(NSString *)meetLink withBeJoinedAudio:(BOOL)beJoinedAudio withBeStartedSharing:(BOOL)beStartedSharing;

/**
 * Return YES if the 3rd party need hide bottom control bar automatically when start or join meet. The default value is NO;
 */
- (BOOL)autoHideControlBar;

/**
 * Return NO if the 3rd party need disable VoIP and hide the VoIP button.
 */
- (BOOL)supportVoIP;

/**
 * Return NO if the 3rd party need disable chat and hide the chat button.
 */
- (BOOL)supportChat;

@end


#pragma mark -
/**
 * There are three user identity types and use for different cases.
 * User case one (kUserIdentityTypeEmail): you do have a Moxtra account, and when you start meet there will be a pop up dialog to let you login if you never logged. and when you join meet you need not to login even if you never logged.
 * User case two (kUserIdentityTypeIdentityUniqueID): you do not have a Moxtra account, and you just need to provide a unique id to initilize account before use Moxtra client functions.
 * User case three (kUserIdentityTypeSSOAccessToken): you provide an access token to initilize account before use Moxtra client functions.
 *
 */
typedef enum enumUserIdentityType {
    kUserIdentityTypeEmail = 0,
    kUserIdentityTypeIdentityUniqueID,
    kUserIdentityTypeSSOAccessToken
}eUserIdentityType;


@interface MXUserIdentity : NSObject
@property (nonatomic, assign) eUserIdentityType userIdentityType;
@property (nonatomic, copy) NSString *userIdentity;
@end


#pragma mark -
@protocol MXClient <NSObject>
@required

#pragma mark initialize user
/**
 * Setup user information. It need OAuth login with Moxtra Account.
 * The 3rd party should not call any other APIs except clientWithApplicationClientID before initializeUserAccount success block call back.
 *
 * @param userIdentity
 *            The user identity.
 * @param orgID
 *            The user org identity.
 * @param firstName
 *            Ignore this parameter when user's identity type is kUserIdentityTypeEmail.
 *            User's firstName.
 * @param lastName
 *            Ignore this parameter when user's identity type is kUserIdentityTypeEmail.
 *            User's lastName.
 * @param avatar
 *            Ignore this parameter when user's identity type is kUserIdentityTypeEmail.
 *            User's avatar image. If need we will resize it according to the image size.
 * @param devicePushNotificationToken
 *            The device push notification token if the 3rd paryt need support notification for Moxtra client.
 * @param success
 *            Callback interface for notifying the calling application when
 *            setup user successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            setup user failed.
 */
- (void)initializeUserAccount:(MXUserIdentity*)userIdentity
                            orgID:(NSString*)orgID
                        firstName:(NSString*)firstName
                         lastName:(NSString*)lastName
                           avatar:(UIImage*)avatar
      devicePushNotificationToken:(NSData*)deviceToken
                          success:(void(^)())success
                          failure:(void(^)(NSError *error))failure;


@optional

#pragma mark update user's profile
/**
 * Ignore this API when user's identity type is kUserIdentityTypeEmail that set in the initializeUserAccount.
 * If user need update their profile, you can call this API to update them.
 *
 * @param firstName
 *            User's firstName.
 * @param lastName
 *            User's lastName.
 * @param avatar
 *            User's avatar image. If need we will resize it according to the image size.
 * @param success
 *            Callback interface for notifying the calling application when
 *            update user's profile successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            update user's profile failed.
 */
- (void)updateUserProfile:(NSString*)firstName
                 lastName:(NSString*)lastName
                   avatar:(UIImage*)avatar
                  success:(void(^)())success
                  failure:(void(^)(NSError *error))failure;


#pragma mark meet SDK
/**
 * Start a online meeting.
 *
 * See http://developer.moxtra.com/moxo/docs-ios-sdk/ for more details.
 *
 * @param topic
 *            The meet topic.
 * @param delegate
 *            Callback interface for notifying the calling application during
 *            the meet.
 * @param inviteAttendeesBlock
 *            Callback interface for notifying the invite button has been pressed.
 *            If value is nil, the default invite panel will be popped up.
 * @param success
 *            Callback interface for notifying the calling application when
 *            the meet has started.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            the meet start failed.
 */
- (void)startMeet:(NSString*)topic
     withDelegate:(id<MXClientMeetDelegate>)delegate
inviteAttendeesBlock:(void(^)(NSString *meetID))inviteAttendeesBlock
          success:(void(^)(NSString *meetID))success
          failure:(void(^)(NSError *error))failure;


/**
 * Join the online meeting.
 *
 * See http://developer.moxtra.com/moxo/docs-ios-sdk/ for more details.
 *
 * @param meetID
 *            The meet ID.
 * @param userName
 *            The user name in meet in the case user is not logged firstly.
 *            The default name will be setted if the value is nil.
 * @param delegate
 *            Callback interface for notifying the calling application during
 *            the meet.
 * @param inviteAttendeesBlock
 *            Callback interface for notifying the invite button has been pressed.
 *            If value is nil, the default invite panel will be popped up.
 * @param success
 *            Callback interface for notifying the calling application when
 *            the user has joined the meet.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            the user join meet failed.
 */
- (void)joinMeet:(NSString*)meetID
    withUserName:(NSString*)userName
    withDelegate:(id<MXClientMeetDelegate>)delegate
inviteAttendeesBlock:(void(^)(NSString *meetID))inviteAttendeesBlock
         success:(void(^)(NSString *meetID))success
         failure:(void(^)(NSError *error))failure;


/**
 * 3rd party notification support
 *
 * Update device push notification token if the 3rd paryt need support notification for Moxtra client.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 */
- (void)updateRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;

/**
 * Handle the remote notification if the 3rd paryt need support notification for Moxtra client.
 * Reture NO if Moxtra client could not handle the remote notification.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 */
- (BOOL)receiveRemoteNotificationWithUserInfo:(NSDictionary*)userInfo;


/**
 * Set meet skin
 *
 * The default color: [UIColor colorWithRed:228.0/255.0 green:130.0/255.0 blue:24.0/255.0 alpha:1.0].
 */
- (void)setMeetStyleWithColor:(UIColor*)color;


/**
 * Invite attendees after start/join meet successed.
 *
 * @param userIdentityArray
 *            The user identity array. The objects in the array are MXUserIdentity.
 */
- (void)inviteAttendeesWithUserIdentityArray:(NSArray*)userIdentityArray;


#pragma mark unlink
/**
 * Unlink Moxtra account.
 */
- (void)unlinkAccount:(void(^)(BOOL success))completion;


#pragma mark other APIs
// Stop Moxtra Meet
- (void)stopMeet;

// Meet start status
- (BOOL)isMeetStarted;

// Meet ID
- (NSString*)getMeetID;

// Meet URL
- (NSString*)getMeetURL;

// User login status
- (BOOL)isUserLoggedIn;

// User last name
- (NSString*)getUserLastName;

// User first name
- (NSString*)getUserFirstName;
@end
