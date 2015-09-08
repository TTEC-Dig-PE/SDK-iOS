//
//  ECSWorkflow.m
//  EXPERTconnect
//
//  Created by Shammi Didla on 19/08/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWorkflow.h"

#import "ECSActionType.h"
#import "ECSMappingReference.h"

@interface ECSWorkflow ()

@property (nonatomic, strong) ECSWorkflowNavigation *navigationManager;
@property (nonatomic, weak) id <ECSWorkflowDelegate> workflowDelegate;
@property (nonatomic, copy) NSString *workflowName;

@end

@implementation ECSWorkflow

#pragma mark - Setup

- (instancetype)initWithWorkflowName:(NSString *)workflowName
                    workflowDelegate:(id<ECSWorkflowDelegate>)workflowDelegate
                   navigationManager:(ECSWorkflowNavigation *)navigationManager {
    
    self = [super init];
    if (self) {
        _workflowName = workflowName;
        _workflowDelegate = workflowDelegate;
        _navigationManager = navigationManager;
    }
    return self;
}

- (void)start {
    
}

- (void)end {
    [self.navigationManager dismissAllViewControllersAnimated:YES completion:nil];
}

#pragma mark - ECSWorkflowNavigationDelegate Method

- (void)invalidResponseOnAnswerEngineWithCount:(NSInteger)count {
    NSDictionary *actions = nil;
    if ([self.workflowDelegate respondsToSelector:@selector(workflowResponseForWorkflow:requestCommand:requestParams:)]) {
       actions = [self.workflowDelegate workflowResponseForWorkflow:self.workflowName
                                                     requestCommand:nil
                                                      requestParams:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:count] forKey:@"InvalidResponseCount"]];
    }
    if (actions) {
        NSString *actionType = [actions valueForKey:@"ActionType"];
        if ([actionType isEqualToString:ECSRequestVideoAction] ||
            [actionType isEqualToString:ECSRequestChatAction] || [actionType isEqualToString:ECSRequestCallbackAction]) {
            __weak __typeof(self)weakSelf = self;
            [self.navigationManager displayAlertForActionType:actionType completion:^(BOOL selected) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (selected) {
                    [strongSelf presentViewControllerForActionType:[strongSelf selectedActionTypeForActionType:actionType]];
                }
            }];
        } else {
            [self presentViewControllerForActionType:actionType];
        }
    }
}

- (void)requestedValidQuestionsOnAnswerEngineCount:(NSInteger)count {
    NSDictionary *actions = nil;
    if ([self.workflowDelegate respondsToSelector:@selector(workflowResponseForWorkflow:requestCommand:requestParams:)]) {
        actions = [self.workflowDelegate workflowResponseForWorkflow:self.workflowName
                                                      requestCommand:nil
                                                       requestParams:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:count] forKey:@"QuestionsAsked"]];
    }
    
    if (actions) {
        NSString *actionType = [actions valueForKey:@"ActionType"];
        if ([actionType isEqualToString:ECSRequestCallbackAction]) {
            __weak __typeof(self)weakSelf = self;
            [self.navigationManager displayAlertForActionType:actionType completion:^(BOOL selected) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (selected) {
                    [strongSelf presentViewControllerForActionType:[strongSelf selectedActionTypeForActionType:actionType]];
                }
            }];
        } else {
            [self presentViewControllerForActionType:actionType];
        }
    }
}

- (NSString *)selectedActionTypeForActionType:(NSString *)actionType {
    if ([actionType isEqualToString:ECSRequestVideoAction]) {
        return ECSActionTypeSelectExpertVideo;
    } else if ([actionType isEqualToString:ECSRequestChatAction]) {
        return ECSActionTypeChatString;
    } else if ([actionType isEqualToString:ECSRequestCallbackAction]) {
        return ECSActionTypeCallbackString;
    }
    
    return ECSActionTypeSelectExpertAndChannel;
}

- (void)endWorkFlow {
    [self end];
}

- (void)voiceCallBackEnded {
    [self presentViewControllerForActionType:ECSActionTypeFormString];
}

- (void)disconnectedFromVoiceCallBack {
    
}
- (void)disconnectedFromChat {
    [self presentViewControllerForActionType:ECSActionTypeFormString];
}

- (void)disconnectedFromVideoChat {
    [self presentViewControllerForActionType:ECSActionTypeFormString];
}

- (void)minimizeButtonTapped:(id)sender {
    [self.navigationManager minmizeAllViewControllersWithCompletion:nil];
}

- (void)receivedUnrecognizedAction:(NSString *)action {
    [self.workflowDelegate unrecognizedAction:action];
}

- (void)form:(NSString *)formName submittedWithValue:(NSString *)formValue {
    NSDictionary *actions = nil;
    if ([self.workflowDelegate respondsToSelector:@selector(workflowResponseForWorkflow:requestCommand:requestParams:)]) {
        actions = [self.workflowDelegate workflowResponseForWorkflow:self.workflowName
                                                      requestCommand:nil
                                                       requestParams:@{@"formName":formName,
                                                                       @"formValue":formValue}];
        if (actions) {
            NSString *actionType = [actions valueForKey:@"ActionType"];
            if ([actionType isEqualToString:ECSActionTypeSelectExpertChat]) {
                [self presentViewControllerForActionType:ECSActionTypeSelectExpertChat];
            } else {
                [self presentViewControllerForActionType:ECSActionTypeFormSubmitted];
            }
        } else {
            [self presentViewControllerForActionType:ECSActionTypeFormSubmitted];
        }
    }
}

#pragma mark - Helper methods

- (void)presentViewControllerForActionType:(NSString *)actionType {
    ECSRootViewController *viewController = [[ECSMappingReference new] viewControllerForAction:actionType];
    viewController.workflowDelegate = self;
    [self.navigationManager presentViewControllerInNavigationControllerModally:viewController
                                                                      animated:YES completion:nil];
}

@end
