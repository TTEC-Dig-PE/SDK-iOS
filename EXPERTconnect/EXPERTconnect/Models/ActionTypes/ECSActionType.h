//
//  ECSActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@class ECSPreSurvey;

// Navigation Action Type shows a table view of available actions.
FOUNDATION_EXPORT NSString *const ECSActionTypeNavigationString;

// Answer engine action type that shows the answer engine view.
FOUNDATION_EXPORT NSString *const ECSActionTypeAnswerEngineString;

// Message action type that shows a leave message view.
FOUNDATION_EXPORT NSString *const ECSActionTypeMessageString;

// Chat action type that shows a chat view.
FOUNDATION_EXPORT NSString *const ECSActionTypeChatString;

// Web action type that shows a web view
FOUNDATION_EXPORT NSString *const ECSActionTypeWebString;

// Form action type that shows a form
FOUNDATION_EXPORT NSString *const ECSActionTypeFormString;

// Action type for voice callback
FOUNDATION_EXPORT NSString *const ECSActionTypeCallbackString;

// Action type for a SMS message
FOUNDATION_EXPORT NSString *const ECSActionTypeSMSString;

// Action type for answer history
FOUNDATION_EXPORT NSString *const ECSActionTypeAnswerHistory;

// Action type for chat history
FOUNDATION_EXPORT NSString *const ECSActionTypeChatHistory;

// Action type for profile view
FOUNDATION_EXPORT NSString *const ECSActionTypeProfile;

// Action type for select expert view for chat
FOUNDATION_EXPORT NSString *const ECSActionTypeSelectExpertChat;

// Action type for select expert view for chat
FOUNDATION_EXPORT NSString *const ECSActionTypeSelectExpertVoiceCallback;

// Action type for select expert view for chat
FOUNDATION_EXPORT NSString *const ECSActionTypeSelectExpertVideo;

// Action type for select expert view for chat
FOUNDATION_EXPORT NSString *const ECSActionTypeSelectExpertAndChannel;

/**
 ECSActionType is the base type for defining available actions to the user.  This object type is 
 sent to direct the navigation of the framework views.
 */
@interface ECSActionType : ECSJSONObject <ECSJSONSerializing, NSCopying>

// The specified type of the action
@property (nonatomic, strong) NSString *type;

// The action id to be sent in various cases for tracking navigation
@property (nonatomic, strong) NSString *actionId;

// Indicates if this action should cause an immediate navigation to the view controller
// that handles this action type.
@property (nonatomic, strong) NSNumber *autoRoute;

// The name to be displayed on UI elements that reference this action.
@property (nonatomic, strong) NSString *displayName;

// URL string to the image that should be used when presenting this action.
@property (nonatomic, strong) NSString *icon;

// Indicates if this action is currently available
@property (nonatomic, strong) NSNumber *enabled;

// Specific configuration values based on the specific action type
@property (nonatomic, strong) NSDictionary *configuration;

// Presurvey for this action type
@property (nonatomic, strong) ECSPreSurvey *presurvey;

// Indicates if this action item starts a user journey
@property (nonatomic, strong) NSNumber *journeybegin;

// The navigation context for this action type
@property (nonatomic, strong) NSString *navigationContext;

// The navigation context for this action type
@property (nonatomic, strong) NSString *intent;

@end
