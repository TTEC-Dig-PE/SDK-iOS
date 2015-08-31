//
//  ECSMappingReference.m
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSMappingReference.h"

/**
 *  Base View Controllers
 */

#import "ECSNavigationController.h"
#import "ECSRootViewController.h"
#import "ECSCafeXVideoViewController.h"
#import "ECSAnswerEngineHistoryViewController.h"
#import "ECSChatLogsViewController.h"
#import "ECSTopQuestionsViewController.h"
#import "ECSAnswerViewController.h"
#import "ECSCallbackViewController.h"
#import "ECSCancelCallbackViewController.h"
#import "ECSChatViewController.h"
#import "ECSInlineFormViewController.h"
#import "ECSSelectExpertViewController.h"
#import "ECSSendConfirmationViewController.h"
#import "ECSCheckboxFormItemViewController.h"
#import "ECSFormItemViewController.h"
#import "ECSFormViewController.h"
#import "ECSRatingFormItemViewController.h"
#import "ECSSliderFormItemViewController.h"
#import "ECSTextAreaFormItemViewController.h"
#import "ECSTextFormItemViewController.h"
#import "ECSFormSubmittedViewController.h"
#import "ECSDynamicViewController.h"
#import "ECSWebViewController.h"
#import "ECSMessageViewController.h"
#import "ECSPhotoViewController.h"
#import "ECSProfileViewController.h"
#import "ECSAnswerEngineViewController.h"

/**
 *  Support
 */

#import "ECSRootViewController+Navigation.h"
#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"
#import "ECSCafeXController.h"
#import "ECSNavigationActionType.h"
#import "ECSActionType.h"
#import "ECSUserManager.h"
#import "ECSInjector.h"

/**
 *  Action Types
 */

#import "ECSActionTypeClassTransformer.h"
#import "ECSAnswerEngineActionType.h"
#import "ECSCallbackActionType.h"
#import "ECSChatActionType.h"
#import "ECSFormActionType.h"
#import "ECSMessageActionType.h"
#import "ECSNavigationActionType.h"
#import "ECSSMSActionType.h"
#import "ECSWebActionType.h"

@implementation ECSMappingReference

- (ECSRootViewController *)viewControllerForAction:(NSString *)actionType {
    ECSRootViewController *actionViewController = nil;
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    
    if ([actionType isEqualToString:ECSActionTypeProfile]) {
        return [self startUserProfile];
    }
    else if ([actionType isEqualToString:ECSActionTypeAnswerHistory]) {
        return [self startAnswerEngineHistory];
    }
    else if ([actionType isEqualToString:ECSActionTypeChatHistory]) {
        return [self startChatHistory];
    }
    else if ([actionType isEqualToString:ECSActionTypeSelectExpertChat]) {
        return [self startSelectExpertChat];
    }
    else if([actionType isEqualToString:ECSActionTypeSelectExpertVideo]) {
        return [self startSelectExpertVideo];
    }
    else if ([actionType isEqualToString:ECSActionTypeSelectExpertVoiceCallback]) {
        return [self startSelectExpertVoiceCallBack];
    }
    else if ([actionType isEqualToString:ECSActionTypeSelectExpertAndChannel])
    {
        return [self startSelectExpertAndChannel];
    }
    else if ([actionType isKindOfClass:[ECSNavigationActionType class]]) {
        return [self landingViewController];
    }
    else if ([actionType isKindOfClass:[ECSAnswerEngineActionType class]])
    {
        return [self startAnswerEngine:ecsConfiguration.defaultAnswerEngineContext];
        
    }
    else if([actionType isEqualToString:ECSActionTypeFormString]) {
        return [self startSurvey:ecsConfiguration.defaultSurveyFormName];
    }
    else if ([actionType isEqualToString:ECSActionTypeCallbackString]) {
        return [self startVoiceCallback:ecsConfiguration.defaultCallBack
                        withDisplayName:@"Voice callback with agent"];
    }
    else {
        return [self viewControllerForActionType:nil];
    }
    
    return actionViewController;
}

- (ECSRootViewController *)startChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName
{
    ECSChatActionType *chatAction = [ECSChatActionType new];
    chatAction.actionId = @"";
    chatAction.agentSkill = chatSkill;
    chatAction.displayName = displayName;
    
    ECSRootViewController *chatController = [self viewControllerForActionType:chatAction];
    
    return chatController;
}

- (ECSRootViewController *)startVoiceCallback:(NSString*)callSkill withDisplayName:(NSString*)displayName
{
    ECSCallbackActionType *cbAction = [ECSCallbackActionType new];
    cbAction.actionId = @"";
    cbAction.agentSkill = callSkill;
    cbAction.displayName = displayName;
    cbAction.type = ECSActionTypeCallbackString;
    
    ECSRootViewController *cbController = [self viewControllerForActionType:cbAction];
    
    return cbController;
}

- (ECSRootViewController *)startAnswerEngine:(NSString*)aeContext
{
    ECSAnswerEngineActionType *answerEngineAction = [ECSAnswerEngineActionType new];
    
    answerEngineAction.defaultQuestion = @"How do I get wireless Internet?";  // just an example, does nothing
    answerEngineAction.journeybegin = [NSNumber numberWithBool:YES];
    answerEngineAction.actionId = @"";
    answerEngineAction.answerEngineContext = aeContext;
    answerEngineAction.navigationContext = @"";
    
    ECSRootViewController *answerEngineController = [self viewControllerForActionType:answerEngineAction];
    ((ECSAnswerEngineViewController *)answerEngineController).parentNavigationContext = @"";
    
    return answerEngineController;
}

- (ECSRootViewController *)startSurvey:(NSString*)formName
{
    ECSFormActionType *formAction = [ECSFormActionType new];
    formAction.actionId = formName;  // kwashington: Can't load the Form Synchronously, so set the actionId to the formName so the ECSFormViewController can do that in viewDidLoad()
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    formAction.navigationContext = [ecsConfiguration defaultNavigationContext];
    
    ECSRootViewController *formController = [self viewControllerForActionType:formAction];
    
    return formController;
}

- (ECSRootViewController *)startUserProfile
{
    ECSActionType *profileAction = [ECSActionType new];
    profileAction.type = ECSActionTypeProfile;
    profileAction.actionId = self.userDisplayName;
    
    ECSRootViewController *profileController = [self viewControllerForActionType:profileAction];
    
    return profileController;
}

- (NSString *)userDisplayName
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    return userManager.userDisplayName;
}

- (ECSRootViewController *)startEmailMessage
{
    ECSMessageActionType *messageAction = [ECSMessageActionType new];
    messageAction.actionId = @"";
    messageAction.email = ECSLocalizedString(@"callcenter@humanify.com", @"callcenter@humanify.com");
    messageAction.messageHeader = ECSLocalizedString(@"Leave a Message", @"Leave a Message");
    messageAction.hoursText = ECSLocalizedString(@"The Call Center is open between the hours of 8:00 AM and 8:00 PM.", @"The Call Center is open between the hours of 8:00 AM and 8:00 PM.");
    messageAction.messageText = ECSLocalizedString(@"The call center is closed!", @"The call center is closed!");
    messageAction.emailSubject = ECSLocalizedString(@"Important Message", @"Important Message");
    messageAction.emailButtonText = ECSLocalizedString(@"Submit Message", @"Submit Message");
    
    return [self startEmailMessage:messageAction];
}

- (ECSRootViewController *)startEmailMessage:(ECSActionType *)messageAction
{
    ECSRootViewController *messageController = [self viewControllerForActionType:messageAction];
    return messageController;
}

- (ECSRootViewController *)startSMSMessage
{
    ECSSMSActionType *smsAction = [ECSSMSActionType new];
    smsAction.type = ECSActionTypeSMSString;
    smsAction.actionId = @"";
    
    ECSRootViewController *smsController = [self viewControllerForActionType:smsAction];
    
    return smsController;
}

- (ECSRootViewController *)startWebPage:(NSString *)url
{
    ECSWebActionType *webAction = [ECSWebActionType new];
    webAction.actionId = @"";
    webAction.url = url;
    
    ECSRootViewController *webController = [self viewControllerForActionType:webAction];
    
    return webController;
}

- (ECSRootViewController *)startAnswerEngineHistory
{
    ECSActionType *aeAction = [ECSActionType new];
    aeAction.type = ECSActionTypeAnswerHistory;
    aeAction.actionId = @"";
    
    ECSRootViewController *aeController = [self viewControllerForActionType:aeAction];
    
    return aeController;
}

- (ECSRootViewController *)startChatHistory
{
    ECSActionType *chistAction = [ECSActionType new];
    chistAction.type = ECSActionTypeChatHistory;
    chistAction.actionId = @"";
    
    ECSRootViewController *chistController = [self viewControllerForActionType:chistAction];
    
    return chistController;
}

- (ECSRootViewController *)startSelectExpertChat
{
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertChat;
    expertAction.actionId = @"";
    expertAction.displayName = @"Chat With an Expert";
    
    ECSRootViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (ECSRootViewController *)startSelectExpertVideo {
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertVideo;
    expertAction.actionId = @"";
    expertAction.displayName = @"VideoChat With an Expert";
    
    ECSRootViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (ECSRootViewController *)startSelectExpertVoiceCallBack {
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertVoiceCallback;
    expertAction.actionId = @"";
    expertAction.displayName = @"Voice Callback With an Expert";
    
    ECSRootViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (ECSRootViewController *)startSelectExpertAndChannel {
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertAndChannel;
    expertAction.actionId = @"";
    expertAction.displayName = @"Select an Expert";
    
    ECSRootViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (ECSRootViewController *)landingViewController
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    ECSNavigationActionType *navigationAction = [ECSNavigationActionType new];
    navigationAction.displayName = configuration.defaultNavigationDisplayName;
    navigationAction.navigationContext = configuration.defaultNavigationContext;
    
    return [ECSRootViewController ecs_viewControllerForActionType:navigationAction];
}

- (ECSRootViewController *)viewControllerForActionType:(ECSActionType *)actionType {
    ECSRootViewController *vc = [ECSRootViewController ecs_viewControllerForActionType:actionType];
    return vc;
}

@end
