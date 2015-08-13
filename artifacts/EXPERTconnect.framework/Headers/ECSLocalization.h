//
//  ECSLocalization.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ECSLocalization provides methods to load localized strings.
 */

// Keys used in localization files
static NSString* const ECSLocalizeCompanyNameKey = @"ECSLocalizedCompanyNameKey";
static NSString* const ECSLocalizeCloseKey = @"ECSLocalizedCloseKey";
static NSString* const ECSLocalizeErrorKey = @"ECSLocalizeErrorKey";

static NSString* const ECSLocalizeLogoutTitle = @"ECSLocalizeLogoutTitle";
static NSString* const ECSLocalizeLogoutText = @"ECSLocalizeLogoutText";

static NSString* const ECSLocalizeAskAQuestionKey = @"ECSLocalizedAskAQuestionKey";
static NSString* const ECSLocalizeFrequentlyAskedQuestionsKey = @"ECSLocalizedFrequentlyAskedQuestionsKey";
static NSString* const ECSLocalizeShortFAQKey = @"ECSLocalizeShortFAQKey";
static NSString* const ECSLocalizeShortHideFAQKey = @"ECSLocalizeShortHideFAQKey";
static NSString* const ECSLocalizeEmailFieldPlaceholder = @"ECSLocalizeEmailFieldPlaceholder";
static NSString* const ECSLocalizeMobileNumberFieldPlaceholder = @"ECSLocalizeMobileNumberFieldPlaceholder";
static NSString* const ECSLogInPromptText = @"ECSLogInPromptText";
static NSString* const ECSLocalizeCreateAccountPromptKey = @"ECSCreateAccountPromptKey";
static NSString* const ECSLocalizeFullNameFieldPlaceholderKey = @"ECSLocalizeFullNameFieldPlaceholderKey";
static NSString* const ECSLocalizeCreateAccountKey = @"ECSLocalizeCreateAccountKey";
static NSString* const ECSLocalizeAllFieldsRequired = @"ECSLocalizeAllFieldsRequired";
static NSString* const ECSLocalizeRegisterErrorMissingRequiredFields = @"ECSLocalizeRegisterErrorMissingRequiredFields";
static NSString* const ECSLocalizeLoginErrorMissingRequiredFields = @"ECSLocalizeLoginErrorMissingRequiredFields";
static NSString* const ECSLocalizeLogInButton = @"ECSLocalizeLogInButton";
static NSString *const ECSLocalizedLogoutButton = @"ECSLocalizedLogoutButton";
static NSString* const ECSLocalizeNextQuestionKey = @"ECSLocalizeNextQuestionKey";
static NSString* const ECSLocalizePreviousQuestionKey = @"ECSLocalizePreviousQuestionKey";
static NSString* const ECSLocalizeOptionalKey = @"ECSLocalizeOptionalKey";
static NSString* const ECSLocalizeRequiredKey = @"ECSLocalizeRequiredKey";
static NSString* const ECSLocalizeSelectAllThatApplyKey = @"ECSLocalizeSelectAllThatApplyKey";
static NSString* const ECSLocalizeSubmitKey = @"ECSLocalizeSubmitKey";

static NSString* const ECSLocalizePossibleAnswer = @"ECSLocalizePossibleAnswer";
static NSString *const ECSLocalizeOthersAlsoAsked = @"ECSLocalizeOthersAlsoAsked";
static NSString *const ECSLocalizeWasThisResponseHelpful = @"ECSLocalizeWasThisResponseHelpful";

static NSString *const ECSLocalizedViewPreviousAnswer = @"ECSLocalizedViewPreviousAnswer";
static NSString *const ECSLocalizedViewNextAnswer = @"ECSLocalizedViewNextAnswer";

static NSString *const ECSLocalizedAnswerNotFoundTitle = @"ECSLocalizedAnswerNotFoundTitle";
static NSString *const ECSLocalizedAnswerNotFoundMessage = @"ECSLocalizedAnswerNotFoundMessage";
static NSString *const ECSLocalizedOkButton = @"ECSLocalizedOkButton";

// Chat View
static NSString *const ECSLocalizedChatViewPlaceholder = @"ECSLocalizedChatViewPlaceholder";
static NSString *const ECSLocalizeTakeAPhoto = @"ECSLocalizeTakeAPhoto";
static NSString *const ECSLocalizeRecordVideo = @"ECSLocalizeRecordVideo";
static NSString *const ECSLocalizeExistingFromAlbum = @"ECSLocalizeExistingFromAlbum";
static NSString *const ECSLocalizeSend = @"ECSLocalizeSend";
static NSString *const ECSLocalizeCancel = @"ECSLocalizeCancel";
static NSString *const ECSLocalizeChatJoin = @"ECSLocalizeChatJoin";

static NSString *const ECSLocalizeWelcome = @"ECSLocalizeWelcome";
static NSString *const ECSLocalizeWelcomeWithUsername = @"ECSLocalizeWelcomeWithUsername";
static NSString *const ECSLocalizeGenericWaitTime = @"ECSLocalizeGenericWaitTime";
static NSString *const ECSLocalizeWaitTime = @"ECSLocalizeWaitTime";

static NSString *const ECSLocalizeReachabilityErrorKey = @"ECSLocalizeReachabilityErrorKey";

static NSString *const ECSLocalizeChatReachabilityErrorKey = @"ECSLocalizeChatReachabilityErrorKey";
static NSString *const ECSLocalizeChatReachabilityReconnectErrorKey = @"ECSLocalizeChatReachabilityReconnectErrorKey";
static NSString *const ECSLocalizeChatReachabilityReconnectButtonKey = @"ECSLocalizeChatReachabilityReconnectButtonKey";

static NSString *const ECSLocalizeIdleMessageKey = @"ECSLocalizeIdleMessageKey";
static NSString *const ECSLocalizeContinueChattingKey = @"ECSLocalizeContinueChattingKey";
static NSString *const ECSLocalizedStayConnectedKey = @"ECSLocalizedStayConnectedKey";

static NSString *const ECSLocalizeChatDisconnected = @"ECSLocalizeChatDisconnected";

static NSString *const ECSLocalizeInfoKey = @"ECSLocalizeInfoKey";
static NSString *const ECSLocalizeWarningKey = @"ECSLocalizeWarningKey";
static NSString *const ECSLocalizeChatDisconnectPrompt = @"ECSLocalizeChatDisconnectPrompt";
static NSString *const ECSLocalizeChatDisconnectPromptSurvey = @"ECSLocalizeChatDisconnectPromptSurvey";
static NSString *const ECSLocalizeYes = @"ECSLocalizeYes";
static NSString *const ECSLocalizeNo = @"ECSLocalizeNo";
static NSString *const ECSLocalizeTapToRespond = @"ECSLocalizeTapToRespond";
static NSString *const ECSLocalizeRequestAPhoneCall = @"ECSLocalizeRequestAPhoneCall";
static NSString *const ECSLocalizeRequestASMS = @"ECSLocalizeRequestASMS";

static NSString *const ECSLocalizedChatSessionEnded = @"ECSLocalizedChatSessionEnded";
static NSString *const ECSLocalizedChatSessionEndedSubtitle = @"ECSLocalizedChatSessionEndedSubtitle";
static NSString *const ECSLocalizedChatSessionEndedDirections = @"ECSLocalizedChatSessionEndedDirections";
static NSString *const ECSLocalizedExitChatButton = @"ECSLocalizedExitChatButton";

// Call View
static NSString *const ECSLocalizeCallNavigationTitle = @"ECSLocalizeCallNavigationTitle";
static NSString *const ECSLocalizeRequestCallButton = @"ECSLocalizeRequestCallButton";
static NSString *const ECSLocalizeRequestCallText= @"ECSLocalizeRequestCallText";
static NSString *const ECSLocalizeRequestCallDisclaimerText = @"ECSLocalizeRequestCallDisclaimerText";
static NSString *const ECSLocalizeProcessingButton = @"ECSLocalizeProcessingButton";

// SMS View
static NSString *const ECSLocalizeSMSNavigationTitle = @"ECSLocalizeSMSNavigationTitle";
static NSString *const ECSLocalizeRequestSMSButton = @"ECSLocalizeRequestSMSButton";
static NSString *const ECSLocalizeRequestSMSText= @"ECSLocalizeRequestSMSText";
static NSString *const ECSLocalizeRequestSMSDisclaimerText = @"ECSLocalizeRequestSMSDisclaimerText";

// Call Cancel View
static NSString *const ECSLocalizeCallCancelTitle = @"ECSLocalizeCallCancelTitle";
static NSString *const ECSLocalizeCallCancelDescription = @"ECSLocalizeCallCancelDescription";
static NSString *const ECSLocalizeCallCancelButton = @"ECSLocalizeCallCancelButton";

// SMS Cancel View
static NSString *const ECSLocalizeSMSCancelTitle = @"ECSLocalizeSMSCancelTitle";
static NSString *const ECSLocalizeSMSCancelDescription = @"ECSLocalizeSMSCancelDescription";
static NSString *const ECSLocalizeCallbackWaitTime = @"ECSLocalizeCallbackWaitTime";
static NSString *const ECSLocalizeSMSCancelButton = @"ECSLocalizeSMSCancelButton";

static NSString *const ECSLocalizeMinutes = @"ECSLocalizeMinutes";
static NSString *const ECSLocalizeMinute = @"ECSLocalizeMinute";


// Settings View
static NSString *const ECSLocalizedPushNotificationsHeader = @"ECSLocalizedPushNotificationsHeader";
static NSString *const ECSLocalizedBeaconsHeader = @"ECSLocalizedBeaconsHeader";
static NSString *const ECSLocalizedVersionHeader = @"ECSLocalizedVersionHeader";

static NSString *const ECSLocalizedReceiveNotificationsRow = @"ECSLocalizedReceiveNotificationsRow";
static NSString *const ECSLocalizedEnableBeaconsRow = @"ECSLocalizedEnableBeaconsRow";
static NSString *const ECSLocalizedLicensesRow = @"ECSLocalizedLicensesRow";

static NSString *const ECSLocalizeError = @"ECSLocalizeError";
static NSString *const ECSLocalizeErrorText = @"ECSLocalizeErrorText";

// Profile View

static NSString *const ECSLocalizeProfile =  @"ECSLocalizeProfile";
static NSString *const ECSLocalizeChatLogs = @"ECSLocalizeChatLogs";
static NSString *const ECSLocalizeHistory = @"ECSLocalizeHistory";
static NSString *const ECSLocalizeUpdateProfile = @"ECSLocalizeUpdateProfile";
static NSString *const ECSLocalizeEditProfile = @"ECSLocalizeEditProfile";
static NSString *const ECSLocalizeProfileError = @"ECSLocalizeProfileError";

static NSString *const ECSLocalizedSubmittedFormHeaderLabel = @"ECSLocalizedSubmittedFormHeaderLabel";
static NSString *const ECSLocalizedSubmittedFormDescriptionLabel = @"ECSLocalizedSubmittedFormDescriptionLabel";
static NSString *const ECSLocalizedSubmittedFormCloseLabel = @"ECSLocalizedSubmittedFormCloseLabel";

static NSString *const ECSLocalizeAnswers = @"ECSLocalizeAnswers";

static NSString *const ECSLocalizeDirections = @"ECSLocalizeDirections";

/**
 Loads a localized string first from the main bundle and if not found, then defaults to the localized
 string in the framework bundle.
 
 @param key the key for the localized string
 @param comment an optional comment describing what the string is used for.
 
 @return a localized string or the key if the string is not found.
 */
FOUNDATION_EXPORT NSString* ECSLocalizedString(NSString *key, NSString *comment);
