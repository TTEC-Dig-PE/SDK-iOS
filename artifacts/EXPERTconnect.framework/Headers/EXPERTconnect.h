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

#import <EXPERTconnect/ECSButton.h>
#import <EXPERTconnect/ECSDynamicLabel.h>
#import <EXPERTconnect/ECSFormTextField.h>
#import <EXPERTconnect/ECSLoadingView.h>
#import <EXPERTconnect/ECSSectionHeader.h>
#import <EXPERTconnect/ECSTheme.h>

#import <EXPERTconnect/ECSJSONSerializing.h>
#import <EXPERTconnect/ECSNotifications.h>
#import <EXPERTconnect/ECSConfiguration.h>

#import <EXPERTconnect/ECSLocalization.h>
#import <EXPERTconnect/ECSURLSessionManager.h>

//! Project version number for EXPERTconnect.
FOUNDATION_EXPORT double EXPERTconnectVersionNumber;

//! Project version string for EXPERTconnect.
FOUNDATION_EXPORT const unsigned char EXPERTconnectVersionString[];

@interface EXPERTconnect : NSObject

@property (readonly, nonatomic) BOOL authenticationRequired;
@property (strong, nonatomic) ECSTheme *theme;
@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSString *userIntent;
@property (strong, nonatomic) NSString *userDisplayName;
@property (strong, nonatomic) NSString *userCallbackNumber;
@property (readonly, nonatomic) ECSURLSessionManager *urlSession;

@property (readonly, nonatomic) NSString *EXPERTconnectVersion;

+ (instancetype)shared;

- (void)initializeWithConfiguration:(ECSConfiguration*)configuration;

/**
 Returns a view controller for a specified EXPERTconnect action. If no view controller is 
 implemented, then nil is returned.
 
 @param actionType the EXPERTconnect action to get the view controller for.
 
 @return the view controller for the action or nil if no view controller exists to present the 
         action
 */
- (UIViewController*)viewControllerForActionType:(ECSActionType*)actionType;

/**
 Returns a landing view controller that points to the default view controller for the SDK
 */
- (UIViewController*)landingViewController;

@end

