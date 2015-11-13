//
//  ECDLocalization.h
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/20/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef EXPERTconnectDemo_ECDLocalization_h
#define EXPERTconnectDemo_ECDLocalization_h

#import <Foundation/Foundation.h>

/**
 ECDLocalization provides methods to load localized strings specific to the Host App.
 */

// Keys used in localization files
//
static NSString* const ECDLocalizedLandingViewTitle = @"ECDLocalizedLandingViewTitle";
static NSString* const ECDLocalizedUnknownUser = @"ECDLocalizedUnknownUser";
static NSString* const ECDLocalizedLoginButton = @"ECDLocalizedLoginButton";
static NSString* const ECDLocalizedRegisterButton = @"ECDLocalizedRegisterButton";
static NSString* const ECDLocalizedSkipRegistrationButton = @"ECDLocalizedSkipRegistrationButton";
static NSString* const ECDLocalizedEnvironmentsHeader = @"ECDLocalizedEnvironmentsHeader";
static NSString* const ECDLocalizedOrganizationHeader = @"ECDLocalizedOrganizationHeader";
static NSString* const ECDLocalizedVoiceItHeader = @"ECDLocalizedVoiceItHeader";
static NSString* const ECDLocalizedRunModeHeader = @"ECDLocalizedRunModeHeader";
static NSString* const ECDLocalizeProfileWasUpdatedKey = @"ECDLocalizeProfileWasUpdatedKey";
static NSString* const ECDLocalizeConfigWasUpdatedKey = @"ECDLocalizeConfigWasUpdatedKey";

static NSString* const ECDLocalizedStartChatHeader = @"ECDLocalizedStartChatHeader";
static NSString* const ECDLocalizedStartVideoChatHeader = @"ECDLocalizedStartVideoChatHeader";
static NSString* const ECDLocalizedStartAnswerEngineHeader = @"ECDLocalizedStartAnswerEngineHeader";
static NSString* const ECDLocalizedStartFormsHeader = @"ECDLocalizedStartFormsHeader";
static NSString* const ECDLocalizedStartUserProfileHeader = @"ECDLocalizedStartUserProfileHeader";
static NSString* const ECDLocalizedStartVoiceCallbackHeader = @"ECDLocalizedStartVoiceCallbackHeader";
static NSString* const ECDLocalizedStartEmailMessageHeader = @"ECDLocalizedStartEmailMessageHeader";
static NSString* const ECDLocalizedStartSMSMessageHeader = @"ECDLocalizedStartSMSMessageHeader";
static NSString* const ECDLocalizedStartWebPageHeader = @"ECDLocalizedStartWebPageHeader";
static NSString* const ECDLocalizedStartAnswerEngineHistoryHeader = @"ECDLocalizedStartAnswerEngineHistoryHeader";
static NSString* const ECDLocalizedStartChatHistoryHeader = @"ECDLocalizedStartChatHistoryHeader";
static NSString* const ECDLocalizedStartSelectExpertHeader = @"ECDLocalizedStartSelectExpertHeader";
static NSString* const ECDLocalizedStartExtendedUserProfileHeader = @"ECDLocalizedStartExtendedUserProfileHeader";
static NSString* const ECDLocalizedStartAPIConfigHeader = @"ECDLocalizedStartAPIConfigHeader";
static NSString* const ECDLocalizedStartSubmitFormHeader = @"ECDLocalizedStartSubmitFormHeader";
static NSString* const ECDLocalizedStartDatePickerHeader = @"ECDLocalizedStartDatePickerHeader";
static NSString* const ECDLocalizedStartWYSIWYGEditorHeader = @"ECDLocalizedStartWYSIWYGEditorHeader";

static NSString* const ECDLocalizedStartEscalateToChatHeader = @"ECDLocalizedStartEscalateToChatHeader";
static NSString* const ECDLocalizedStartChatWithPostSurveyHeader = @"ECDLocalizedStartChatWithPostSurveyHeader";
static NSString* const ECDLocalizedStartChatWithPreSurveyHeader = @"ECDLocalizedStartChatWithPreSurveyHeader";

static NSString* const ECDLocalizedStartChatLabel = @"ECDLocalizedStartChatLabel";
static NSString* const ECDLocalizedStartVideoChatLabel = @"ECDLocalizedStartVideoChatLabel";
static NSString* const ECDLocalizedStartAnswerEngineLabel = @"ECDLocalizedStartAnswerEngineLabel";
static NSString* const ECDLocalizedStartFormsLabel = @"ECDLocalizedStartFormsLabel";
static NSString* const ECDLocalizedStartUserProfileLabel = @"ECDLocalizedStartUserProfileLabel";
static NSString* const ECDLocalizedStartVoiceCallbackLabel = @"ECDLocalizedStartVoiceCallbackLabel";
static NSString* const ECDLocalizedStartEmailMessageLabel = @"ECDLocalizedStartEmailMessageLabel";
static NSString* const ECDLocalizedStartSMSMessageLabel = @"ECDLocalizedStartSMSMessageLabel";
static NSString* const ECDLocalizedStartWebPageLabel = @"ECDLocalizedStartWebPageLabel";
static NSString* const ECDLocalizedStartAnswerEngineHistoryLabel = @"ECDLocalizedStartAnswerEngineHistoryLabel";
static NSString* const ECDLocalizedStartChatHistoryLabel = @"ECDLocalizedStartChatHistoryLabel";
static NSString* const ECDLocalizedStartSelectExpertLabel = @"ECDLocalizedStartSelectExpertLabel";
static NSString* const ECDLocalizedStartExtendedUserProfileLabel = @"ECDLocalizedStartExtendedUserProfileLabel";
static NSString* const ECDLocalizedStartAPIConfigLabel = @"ECDLocalizedStartAPIConfigLabel";
static NSString* const ECDLocalizedStartSubmitFormLabel = @"ECDLocalizedStartSubmitFormLabel";
static NSString* const ECDLocalizedStartDatePickerLabel = @"ECDLocalizedStartDatePickerLabel";
static NSString* const ECDLocalizedStartWYSIWYGEditorLabel = @"ECDLocalizedStartWYSIWYGEditorLabel";

static NSString* const ECDLocalizedStartWorkflowEscalateToChatLabel = @"ECDLocalizedStartWorkflowEscalateToChatLabel";
static NSString* const ECDLocalizedStartWorkflowChatWithPostSurveyLabel = @"ECDLocalizedStartWorkflowChatWithPostSurveyLabel";
static NSString* const ECDLocalizedStartWorkflowChatWithPreSurveyLabel = @"ECDLocalizedStartWorkflowChatWithPreSurveyLabel";

/**
 Loads a localized string first from the main bundle and if not found, then defaults to the localized
 string in the application bundle.
 
 @param key the key for the localized string
 @param comment an optional comment describing what the string is used for.
 
 @return a localized string or the key if the string is not found.
 */
FOUNDATION_EXPORT NSString* ECDLocalizedString(NSString *key, NSString *comment);

#endif
