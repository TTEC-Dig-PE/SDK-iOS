//
//  EXPERTconnect.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// Model Imports
#import <EXPERTconnect/ECSJSONObject.h>
#import <EXPERTconnect/ECSActionType.h>
#import <EXPERTconnect/ECSAnswerEngineActionType.h>
#import <EXPERTconnect/ECSAnswerEngineResponse.h>
#import <EXPERTconnect/ECSAnswerEngineTopQuestionsResponse.h>
#import <EXPERTconnect/ECSCallbackActionType.h>
#import <EXPERTconnect/ECSChatActionType.h>
#import <EXPERTconnect/ECSVideoChatActionType.h>
#import <EXPERTconnect/ECSFormActionType.h>
#import <EXPERTconnect/ECSForm.h>
#import <EXPERTconnect/ECSFormItem.h>
#import <EXPERTconnect/ECSFormSubmitResponse.h>
#import <EXPERTconnect/ECSMessageActionType.h>
#import <EXPERTconnect/ECSSMSActionType.h>
#import <EXPERTconnect/ECSWebActionType.h>
#import <EXPERTconnect/ECSStartJourneyResponse.h>
#import <EXPERTconnect/ECSAgentAvailableResponse.h>
#import <EXPERTconnect/ECSJSONSerializer.h>
#import <EXPERTconnect/ECSNavigationActionType.h>
#import <EXPERTconnect/ECSNavigationContext.h>
#import <EXPERTconnect/ECSNavigationSection.h>

// UI Imports
#import <EXPERTconnect/ECSCachingImageView.h>
#import <EXPERTconnect/ECSCircleImageView.h>
#import <EXPERTconnect/ECSDynamicViewController.h>
#import <EXPERTconnect/ECSFeaturedTableViewCell.h>
#import <EXPERTconnect/ECSRootViewController.h>
#import <EXPERTconnect/ECSRootViewController+Navigation.h>
#import <EXPERTconnect/ECSWebViewController.h>

//#import <EXPERTconnect/ECSBinaryRating.h>
//#import <EXPERTconnect/ECSBinaryImageView.h>
#import <EXPERTconnect/ECSCalendar.h>
#import <EXPERTconnect/ECSRichTextEditor.h>

// Core Networking

#import <EXPERTconnect/ECSStompChatClient.h>
#import <EXPERTconnect/ECSStompCallbackClient.h>
#import <EXPERTconnect/ECSChannelStateMessage.h>
#import <EXPERTconnect/ECSChatMessage.h>
#import <EXPERTconnect/ECSChatStateMessage.h>
#import <EXPERTconnect/ECSAddressableChatMessage.h>
#import <EXPERTconnect/ECSChatVoiceAuthenticationMessage.h>
#import <EXPERTconnect/ECSChatAddParticipantMessage.h>
#import <EXPERTconnect/ECSInjector.h>
#import <EXPERTconnect/ECSChatTextMessage.h>
#import <EXPERTconnect/ECSConversationCreateResponse.h>
#import <EXPERTconnect/ECSConversationLink.h>
#import <EXPERTconnect/ECSChannelConfiguration.h>
#import <EXPERTconnect/ECSChannelCreateResponse.h>

// #import <EXPERTconnect/ECSRatingView.h>     // kdw: causes "Include of non-modular header inside framework module EXPERTconnect.ECSRatingView"
#import <EXPERTconnect/UIView+ECSNibLoading.h>
#import <EXPERTconnect/ECSViewControllerStack.h>
#import <EXPERTconnect/ECSAnswerRatingView.h>

#import <EXPERTconnect/ECSButton.h>
#import <EXPERTconnect/ECSDynamicLabel.h>
#import <EXPERTconnect/ECSFormTextField.h>
#import <EXPERTconnect/ECSLoadingView.h>
#import <EXPERTconnect/ECSSectionHeader.h>
#import <EXPERTconnect/ECSTheme.h>
#import <EXPERTconnect/ECSUserProfile.h>

#import <EXPERTconnect/ECSJSONSerializing.h>
#import <EXPERTconnect/ECSNotifications.h>
#import <EXPERTconnect/ECSConfiguration.h>

#import <EXPERTconnect/ECSLocalization.h>
#import <EXPERTconnect/ECSURLSessionManager.h>

#import <EXPERTconnect/ECSWorkflow.h>
#import <EXPERTconnect/ECSWorkflowNavigation.h>
#import <EXPERTconnect/ECSMediaInfoHelpers.h>
#import <EXPERTconnect/ECSAuthenticationToken.h>

//! Project version number for EXPERTconnect.
FOUNDATION_EXPORT double EXPERTconnectVersionNumber;

//! Project version string for EXPERTconnect.
FOUNDATION_EXPORT const unsigned char EXPERTconnectVersionString[];

#pragma mark -
//Delegate for the Host App to handle events.
@protocol ExpertConnectDelegate <NSObject>

@end

@interface EXPERTconnect : NSObject

@property (readonly, nonatomic) BOOL authenticationRequired;
@property (strong, nonatomic) ECSTheme *theme;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *userIntent;
@property (copy, nonatomic) NSString *userDisplayName;
@property (copy, nonatomic) NSString *userCallbackNumber;
@property (copy, nonatomic) NSString *customerType;
@property (copy, nonatomic) NSString *treatmentType;
@property (copy, nonatomic) NSString *lastSurveyScore;
@property (copy, nonatomic) NSString *surveyFormName;
@property (readonly, nonatomic) ECSURLSessionManager *urlSession;
@property (weak) id <ExpertConnectDelegate> externalDelegate;
@property (copy, nonatomic) NSString *journeyID;
@property (copy, nonatomic) NSString *sessionID;

@property (readonly, nonatomic) NSString *EXPERTconnectVersion;
@property (readonly, nonatomic) NSString *EXPERTconnectBuildVersion;

+ (instancetype)shared;

/**
 Initializes the Humanify SDK components with the given configuration. Refer to Humanify documentation
 to read what the ECSConfiguration object should be populated with.
 */
- (void)initializeWithConfiguration:(ECSConfiguration*)configuration;

/**
 Initializes video components (video chat and co-browse capability). Video module addon required.
 */
- (void)initializeVideoComponents;

/**
 Returns a view controller for an EXPERTconnect Chat session.
 
 @param chatSkill the Agent Chat Skill for the Chat
 @param displayName for the View Controller
 @param shouldTakeSurvey, determains
 @return the view controller for the Chat
 */
- (UIViewController*)startChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName withSurvey:(BOOL)shouldTakeSurvey;

- (UIViewController*)startChat:(NSString*)chatSkill
               withDisplayName:(NSString*)displayName
                    withSurvey:(BOOL)shouldTakeSurvey
            withChannelOptions:(NSDictionary *)channelOptions;

/**
 Returns a view controller for an EXPERTconnect Chat session, with CafeX Video parameters.
 
 @param chatSkill the Agent Chat Skill for the Chat
 @param displayName for the View Controller
 
 @return the view controller for the Chat
 */
- (UIViewController*)startVideoChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName;

/**
 Returns a view controller for an EXPERTconnect Chat session, with CafeX Voice parameters.
 
 @param chatSkill the Agent Chat Skill for the Chat
 @param displayName for the View Controller
 
 @return the view controller for the Chat
 */
- (UIViewController*)startVoiceChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName;

/**
 Returns a view controller for an EXPERTconnect Voice Callback session.
 
 @param chatSkill the Agent Skill for the Callback
 @param displayName for the View Controller
 
 @return the view controller for the Callback
 */
- (UIViewController*)startVoiceCallback:(NSString*)chatSkill withDisplayName:(NSString*)displayName;

/**
 Returns a view controller for an EXPERTconnect Answer Engine session.
 
 @param aeContext the Answer Engine Context to post the question to
 
 @return the view controller for the Answer Engine Session
 */
- (UIViewController*)startAnswerEngine:(NSString*)aeContext withDisplayName:(NSString*)displayName;

- (UIViewController*)startAnswerEngine:(NSString *)aeContext
                       withDisplayName:(NSString *)displayName
                         showSearchBar:(BOOL)showSearchBar;

/**
 Returns a view controller for an EXPERTconnect Survey
 
 @param form the Name of the Form to launch
 
 @return the view controller for the Survey
 */
- (UIViewController*)startSurvey:(NSString*)formName;

/**
 Returns a view controller for an EXPERTconnect User Profile Form for the current user
 
 @return the view controller for the User Profile Controller
 */
- (UIViewController*)startUserProfile;

/**
 Returns a view controller for an EXPERTconnect Email Message
 
 @return the view controller for the Messaging Controller
 */
- (UIViewController*)startEmailMessage;
- (UIViewController*)startEmailMessage:(ECSActionType *)messageAction;

/**
 Returns a view controller for an EXPERTconnect SMS Message
 
 @return the view controller for the Messaging Controller
 */
- (UIViewController*)startSMSMessage;

/**
 Returns a view controller for an EXPERTconnect Web Page View
 
 @return the view controller for the Web Page Controller
 */
- (UIViewController*)startWebPage:(NSString *)url;

/**
 Returns a view controller for an EXPERTconnect Answer Engine History View
 
 @return the view controller for the Web Page Controller
 */
- (UIViewController*)startAnswerEngineHistory;

/**
 Returns a view controller for an EXPERTconnect Chat History View
 
 @return the view controller for the Web Page Controller
 */
- (UIViewController*)startChatHistory;

/**
 Returns a view controller for an EXPERTconnect SelectAgent Chat mode
 
 @return the view controller for the Web Page Controller
 */
- (UIViewController*)startSelectExpertChat;
- (UIViewController*)startSelectExpertVideo;
- (UIViewController*)startSelectExpertAndChannel;

/**
 Convenience (wrapper) method for accessing VoiceIt
 
 @param username the Username to attempt to authenticate against.
 @param authCallback a void/String block that handles the callback for a voiceit auth response

 */
- (void)voiceAuthRequested:(NSString *)username callback:(void (^)(NSString *))authCallback;

/**
 Convenience (wrapper) method for accessing VoiceIt to record a new voice print.
 
 */
- (void)recordNewEnrollment;

/**
 Convenience (wrapper) method for accessing VoiceIt to clear existing recordings.
 
 */
- (void)clearEnrollments;

/**
 Logout support. Does not change UI - just removes user token and unauthenticates user.
 
 */
- (void) logout;

/**
 Login support
 
 @param username the Name of the user attempting to login
 
 @return the Form returned from the login attempt
 */
- (void) login:(NSString *) username withCompletion:(void (^)(ECSForm *, NSError *))completion;

/**
 Returns a view controller for a specified EXPERTconnect action. If no view controller is
 implemented, then nil is returned.
 
 @param actionType the EXPERTconnect action to get the view controller for.
 
 @return the view controller for the action or nil if no view controller exists to present the 
         action
 */
- (UIViewController*)viewControllerForActionType:(ECSActionType*)actionType;


/**
 Sets a host app delegate to be used for Moxtra event handling. This is TEMPORARY until Moxtra releases an embeddable framework.
 
 @param delegate The ExpertConnectDelegate instance that the host app would like to use to receive Moxtra events.
 */
- (void)setDelegate:(id)delegate;

/**
 Returns a landing view controller that points to the default view controller for the SDK
 */
- (UIViewController*)landingViewController;

/**
 *  Starts SDK workflow with a workflowName(workflowID), a delegate, and a viewController to present it on
 */
- (void)startWorkflow:(NSString *)workFlowName
           withAction:(NSString *)actionType
              delgate:(id <ECSWorkflowDelegate>)workflowDelegate
       viewController:(UIViewController *)viewController;

/**
    Starts a workflow but instead of displaying a view controller modally, this will pass it back to display
    in whichever mode the integrator would like.
 */
- (UIViewController *)workflowViewWithAction:(NSString *)actionType
                                    delegate:(id <ECSWorkflowDelegate>)workflowDelegate;

/**
 *  Starts Chat workflow with a workflowName(workflowID), skill name, a delegate, and a viewController to present it on
 */
- (void)startChatWorkflow:(NSString *)workFlowName
                withSkill:(NSString *)skillName
               withSurvey:(BOOL)shouldTakeSurvey
                  delgate:(id <ECSWorkflowDelegate>)workflowDelegate
           viewController:(UIViewController *)viewController;

// Check availability on a singlar skill
- (void) agentAvailabilityWithSkill:(NSString *)skill
                         completion:(void(^)(NSDictionary *status, NSError *error))completion;

- (void) getDetailsForSkill:(NSString *)skill
                 completion:(void(^)(NSDictionary *details, NSError *error))completion;

/**
 Starts a fresh journey. When a conversation is started, it will use the journeyID fetched by this call if it had
 been invoked beforehand. Otherwise, the conversation begin will fetch a new journeyID. 
 */
- (void) startJourneyWithCompletion:(void (^)(NSString *, NSError *))completion;

// Send user profile to server.
- (void)setUserProfile:(ECSUserProfile *)userProfile withCompletion:(void (^)(NSString *, NSError *))completion;

/**
 Directly set the authToken. This method is used if the host app is fetching an authToken from Humanify servers
 outside of the framework. That token is then plugged into this function call to authenticate any future SDK functions.
 */
- (void)setUserIdentityToken:(NSString *)token;

/**
 Set the authentication token delegate. This object should contain the function that will refresh
 the token. The EXPERTconnect SDK will call this function if it detects an HTTP 401 (not authorized) error. 
 */
- (void)setAuthenticationTokenDelegate:(id<ECSAuthenticationTokenDelegate>)delegate;

- (void)setUserAvatar:(UIImage *)userAvatar;

/**
 *
 */
-(void)recievedUnrecognizedAction:(NSString *)action;

-(void)setClientID:(NSString *)theClientID;

-(void)setHost:(NSString *)theHost;

- (void) breadcrumbWithAction: (NSString *)actionType
                  description: (NSString *)actionDescription
                       source: (NSString *)actionSource
                  destination: (NSString *)actionDestination
                  geolocation: (CLLocation *)geolocation;

- (void) breadcrumbNewSessionWithCompletion:(void(^)(NSString *, NSError *))completion;

// Dispatch to the server any queued up breadcrumbs. These could be     queued if
// configured to wait a time period or number of breadcrumbs before sending.
- (void) breadcrumbDispatch;

/**
 Set the debug level.
 0 - None
 1 - Error
 2 - Warning
 3 - Debug
 4 - Verbose
 */
- (void)setDebugLevel:(int)logLevel;

@end

