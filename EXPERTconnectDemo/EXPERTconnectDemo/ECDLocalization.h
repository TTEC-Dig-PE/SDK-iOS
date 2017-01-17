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
static NSString* const ECDLocalizedBeaconHeader = @"ECDLocalizedBeaconHeader";
static NSString* const ECDLocalizedVoiceItHeader = @"ECDLocalizedVoiceItHeader";
static NSString* const ECDLocalizedRunModeHeader = @"ECDLocalizedRunModeHeader";
static NSString* const ECDLocalizeProfileWasUpdatedKey = @"ECDLocalizeProfileWasUpdatedKey";
static NSString* const ECDLocalizeConfigWasUpdatedKey = @"ECDLocalizeConfigWasUpdatedKey";
static NSString* const ECDLocalizedCustomizeThemeHeader = @"ECDLocalizedCustomizeThemeHeader";


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
static NSString* const ECDLocalizedStartSurveyLeadsToBranchHeader = @"ECDLocalizedStartSurveyLeadsToBranchHeader";

static NSString* const ECDLocalizedStartShowAvatarImagesHeader = @"ECDLocalizedStartShowAvatarImagesHeader";
static NSString* const ECDLocalizedStartShowChatBubbleTailsHeader = @"ECDLocalizedStartShowChatBubbleTailsHeader";
static NSString* const ECDLocalizedStartShowChatTimeStampHeader = @"ECDLocalizedStartShowChatTimeStampHeader";

static NSString* const ECDLocalizedStartChatLabel = @"ECDLocalizedStartChatLabel";
static NSString* const ECDLocalizedContinueChatLabel = @"ECDLocalizedContinueChatLabel";
static NSString* const ECDLocalizedEndChatLabel = @"ECDLocalizedEndChatLabel";
static NSString* const ECDLocalizedBreadcrumbLabel = @"ECDLocalizedBreadcrumbLabel";
static NSString* const ECDLocalizedTestChatLabel = @"ECDLocalizedTestChatLabel";
static NSString* const ECDLocalizedTestBreadcrumbsLabel = @"ECDLocalizedTestBreadcrumbsLabel";
static NSString* const ECDLocalizedTestJourneyLabel = @"ECDLocalizedTestJourneyLabel";
static NSString* const ECDLocalizedTestDecisionLabel = @"ECDLocalizedTestDecisionLabel";
static NSString* const ECDLocalizedTestDebugLabel = @"ECDLocalizedTestDebugLabel";
static NSString* const ECDLocalizedStartVideoChatLabel = @"ECDLocalizedStartVideoChatLabel";
static NSString* const ECDLocalizedStartAnswerEngineLabel = @"ECDLocalizedStartAnswerEngineLabel";
static NSString* const ECDLocalizedUtilityFunctionLabel = @"ECDLocalizedUtilityFunctionLabel"; 
static NSString* const ECDLocalizedStartFormsLabel = @"ECDLocalizedStartFormsLabel";
static NSString* const ECDLocalizedStartUserProfileLabel = @"ECDLocalizedStartUserProfileLabel";
static NSString* const ECDLocalizedBeaconLabel = @"ECDLocalizedBeaconLabel";
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
static NSString* const ECDLocalizedStartWorkflowSurveyLeadsToBranchLabel = @"ECDLocalizedStartWorkflowSurveyLeadsToBranchLabel";

static NSString* const ECDLocalizedStartShowAvatarImagesLabel = @"ECDLocalizedStartShowAvatarImagesLabel";
static NSString* const ECDLocalizedStartShowChatBubbleTailsLabel = @"ECDLocalizedStartShowChatBubbleTailsLabel";
static NSString* const ECDLocalizedStartShowChatTimeStampLabel = @"ECDLocalizedStartShowChatTimeStampLabel";


static NSString* const ECDLocalizedNoAgents = @"ECDLocalizedNoAgents";
static NSString* const ECDLocalizedWaitString = @"ECDLocalizedWaitString";
static NSString* const ECDLocalizedMinuteString = @"ECDLocalizedMinuteString";
static NSString* const ECDLocalizedAgentString = @"ECDLocalizedAgentString";


static NSString* const ECDLocalizedChatSkillLabel = @"ECDLocalizedChatSkillLabel";
static NSString* const ECDLocalizedCustomNavBarButtonsLabel = @"ECDLocalizedCustomNavBarButtonsLabel";
static NSString* const ECDLocalizedUseImageForSendButtonLabel = @"ECDLocalizedUseImageForSendButtonLabel";
static NSString* const ECDLocalizedImageUploadButtonLabel = @"ECDLocalizedImageUploadButtonLabel";

static NSString* const ECDLocalizedCurrentJourneyInfoLabel = @"ECDLocalizedCurrentJourneyInfoLabel";
static NSString* const ECDLocalizedNameLabel = @"ECDLocalizedNameLabel";
static NSString* const ECDLocalizedContextLabel = @"ECDLocalizedContextLabel";
static NSString* const ECDLocalizedNamePlaceholderLabel = @"ECDLocalizedNamePlaceholderLabel";
static NSString* const ECDLocalizedContextPlaceholderLabel = @"ECDLocalizedContextPlaceholderLabel";
static NSString* const ECDLocalizedStartJourneyLabel = @"ECDLocalizedStartJourneyLabel";
static NSString* const ECDLocalizedStartJourneyContextLabel = @"ECDLocalizedStartJourneyContextLabel";

static NSString* const ECDLocalizedTypeLabel = @"ECDLocalizedTypeLabel";
static NSString* const ECDLocalizedDescribtionLabel = @"ECDLocalizedDescribtionLabel";
static NSString* const ECDLocalizedSourceLabel = @"ECDLocalizedSourceLabel";
static NSString* const ECDLocalizedDestinationLabel = @"ECDLocalizedDestinationLabel";
static NSString* const ECDLocalizedTypePlaceholderLabel = @"ECDLocalizedTypePlaceholderLabel";
static NSString* const ECDLocalizedDescribtionPlaceholderLabel = @"ECDLocalizedDescribtionPlaceholderLabel";
static NSString* const ECDLocalizedSourcePlaceholderLabel = @"ECDLocalizedSourcePlaceholderLabel";
static NSString* const ECDLocalizedDestinationPlaceholderLabel = @"ECDLocalizedDestinationPlaceholderLabel";
static NSString* const ECDLocalizedBulkConfigLabel = @"ECDLocalizedBulkConfigLabel";
static NSString* const ECDLocalizedGeoLocationDataLabel = @"ECDLocalizedGeoLocationDataLabel";
static NSString* const ECDLocalizedSecondsLabel = @"ECDLocalizedSecondsLabel";
static NSString* const ECDLocalizedCountLabel = @"ECDLocalizedCountLabel";
static NSString* const ECDLocalizedSendOneButtonLabel = @"ECDLocalizedSendOneButtonLabel";
static NSString* const ECDLocalizedQueueBulkButtonLabel = @"ECDLocalizedQueueBulkButtonLabel";


static NSString* const ECDLocalizedRequestDecisionLabel = @"ECDLocalizedRequestDecisionLabel";
static NSString* const ECDLocalizedResponseDecisionLabel = @"ECDLocalizedResponseDecisionLabel";
static NSString* const ECDLocalizedPostConsumerButtonLabel = @"ECDLocalizedPostConsumerButtonLabel";

static NSString* const ECDLocalizedEmailDebugButtonLabel = @"ECDLocalizedEmailDebugButtonLabel";

/**
 Loads a localized string first from the main bundle and if not found, then defaults to the localized
 string in the application bundle.
 
 @param key the key for the localized string
 @param comment an optional comment describing what the string is used for.
 
 @return a localized string or the key if the string is not found.
 */
FOUNDATION_EXPORT NSString* ECDLocalizedString(NSString *key, NSString *comment);

#endif
