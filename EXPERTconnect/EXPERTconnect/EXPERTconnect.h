//
//  EXPERTconnect.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


// Model Imports
#import <EXPERTconnect/ECSJSONObject.h>
#import <EXPERTconnect/ECSActionType.h>
#import <EXPERTconnect/ECSAnswerEngineActionType.h>
#import <EXPERTconnect/ECSAnswerEngineResponse.h>
#import <EXPERTconnect/ECSAnswerEngineTopQuestionsResponse.h>
#import <EXPERTconnect/ECSCallbackActionType.h>
#import <EXPERTconnect/ECSChatActionType.h>
#import <EXPERTconnect/ECSFormActionType.h>
#import <EXPERTconnect/ECSForm.h>
#import <EXPERTconnect/ECSFormItem.h>
#import <EXPERTconnect/ECSFormSubmitResponse.h>
#import <EXPERTconnect/ECSMessageActionType.h>
#import <EXPERTconnect/ECSSMSActionType.h>
#import <EXPERTconnect/ECSWebActionType.h>

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

#import <EXPERTconnect/ECSBinaryRating.h>
#import <EXPERTconnect/ECSBinaryImageView.h>
// #import <EXPERTconnect/ECSRatingView.h>     // kdw: causes "Include of non-modular header inside framework module EXPERTconnect.ECSRatingView"

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

#import <EXPERTconnect/ECSWorkflowNavigation.h>
#import <EXPERTconnect/ECSMediaInfoHelpers.h>

//! Project version number for EXPERTconnect.
FOUNDATION_EXPORT double EXPERTconnectVersionNumber;

//! Project version string for EXPERTconnect.
FOUNDATION_EXPORT const unsigned char EXPERTconnectVersionString[];

#pragma mark -
//Delegate for the Host App to handle Moxtra events. This is TEMPORARY until Moxtra releases an embeddable framework.
@protocol ExpertConnectDelegate <NSObject>
/**
 * Called when Expert requests a Moxtra meeting
 */
- (void)meetRequested:(void(^)(NSString *meetID))meetStartedCallback;
- (void)meetNeedstoEnd;

@end

@interface EXPERTconnect : NSObject

@property (readonly, nonatomic) BOOL authenticationRequired;
@property (strong, nonatomic) ECSTheme *theme;
@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSString *userIntent;
@property (strong, nonatomic) NSString *userDisplayName;
@property (strong, nonatomic) NSString *userCallbackNumber;
@property (readonly, nonatomic) ECSURLSessionManager *urlSession;
@property (weak) id <ExpertConnectDelegate> externalDelegate;
@property (strong, nonatomic) ECSWorkflowNavigation *navigationManager;

@property (readonly, nonatomic) NSString *EXPERTconnectVersion;

+ (instancetype)shared;

- (void)initializeWithConfiguration:(ECSConfiguration*)configuration;


/**
 Returns a view controller for an EXPERTconnect Chat session.
 
 @param chatSkill the Agent Chat Skill for the Chat
 @param displayName for the View Controller
 
 @return the view controller for the Chat
 */
- (UIViewController*)startChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName;

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
- (UIViewController*)startAnswerEngine:(NSString*)aeContext;

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
 Returns a view controller for an EXPERTconnect Answer Engine History View
 
 @return the view controller for the Web Page Controller
 */
- (UIViewController*)startSelectExpert;

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
 *  Uses a ViewController passed to it as a base for all SDK operations
 */
-(void)startWorkflowOnViewController:(UIViewController *)vc;
@end

