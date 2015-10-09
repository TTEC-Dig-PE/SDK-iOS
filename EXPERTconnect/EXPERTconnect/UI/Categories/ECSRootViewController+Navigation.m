//
//  ECSDynamicViewController+Navigation.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSRootViewController+Navigation.h"

#import "ECSAnswerEngineViewController.h"
#import "ECSAnswerEngineHistoryViewController.h"
#import "ECSChatLogsViewController.h"
#import "ECSDynamicLabel.h"
#import "ECSDynamicViewController.h"
#import "ECSNavigationActionType.h"
#import "ECSAnswerEngineActionType.h"
#import "ECSCallbackActionType.h"
#import "ECSCallbackViewController.h"
#import "ECSChatActionType.h"
#import "ECSChatViewController.h"
#import "ECSMessageActionType.h"
#import "ECSPreSurveyViewController.h"
#import "ECSWebActionType.h"
#import "ECSWebViewController.h"
#import "ECSFormActionType.h"
#import "ECSFormSubmittedActionType.h"
#import "ECSFormViewController.h"
#import "ECSProfileViewController.h"
#import "ECSSMSActionType.h"
#import "ECSMessageViewController.h"
#import "ECSSelectExpertViewController.h"
#import "UIViewController+ECSNibLoading.h"
#import "ECSFormSubmittedViewController.h"

@implementation ECSRootViewController (Navigation)

+ (instancetype)ecs_viewControllerForActionType:(ECSActionType*)actionType
{
    ECSRootViewController *actionViewController = nil;
    
    if ([actionType.type isEqualToString:ECSActionTypeProfile])
    {
        ECSProfileViewController *viewController = [ECSProfileViewController ecs_loadFromNib];
        actionViewController = viewController;
    }
    else if ([actionType.type isEqualToString:ECSActionTypeAnswerHistory])
    {
        actionViewController = [ECSAnswerEngineHistoryViewController ecs_loadFromNib];
    }
    else if ([actionType.type isEqualToString:ECSActionTypeChatHistory])
    {
        actionViewController = [ECSChatLogsViewController ecs_loadFromNib];
    }
    else if ([actionType.type isEqualToString:ECSActionTypeSelectExpertChat] || [actionType.type isEqualToString:ECSActionTypeSelectExpertVideo] ||
             [actionType.type isEqualToString:ECSActionTypeSelectExpertVoiceCallback] ||
             [actionType.type isEqualToString:ECSActionTypeSelectExpertVoiceChat] ||[actionType.type isEqualToString:ECSActionTypeSelectExpertAndChannel] )
    {
        actionViewController = [ECSSelectExpertViewController ecs_loadFromNib];
        actionViewController.actionType = actionType;
    }
    else if ([actionType isKindOfClass:[ECSNavigationActionType class]])
    {
        ECSDynamicViewController *viewController = [ECSDynamicViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        actionViewController = viewController;
    }
    else if ([actionType isKindOfClass:[ECSAnswerEngineActionType class]])
    {
        ECSAnswerEngineViewController *viewController = [ECSAnswerEngineViewController ecs_loadFromNib];
        viewController.actionType = [(ECSAnswerEngineActionType*)actionType copy];
        viewController.answerEngineAction = [(ECSAnswerEngineActionType*)actionType copy];
        
        actionViewController = viewController;

    }
    else if ([actionType isKindOfClass:[ECSWebActionType class]])
    {
        ECSWebViewController *viewController = [ECSWebViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        [viewController loadItemAtPath:((ECSWebActionType*)actionType).url];
        
        actionViewController = viewController;
    }
    else if ([actionType isKindOfClass:[ECSFormActionType class]])
    {
        ECSFormViewController* viewController = [ECSFormViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        
        actionViewController = viewController;
    }
    else if ([actionType isKindOfClass:[ECSFormSubmittedActionType class]])
    {
        ECSFormSubmittedViewController *viewController = [ECSFormSubmittedViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        
        actionViewController = viewController;
    }
    else if ([actionType isKindOfClass:[ECSChatActionType class]])
    {
        ECSChatViewController* viewController = [ECSChatViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        
        actionViewController = viewController;
    }
    else if ([actionType isKindOfClass:[ECSCallbackActionType class]] ||
             [actionType isKindOfClass:[ECSSMSActionType class]])
    {
        ECSCallbackViewController *viewController = [ECSCallbackViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        
        if ([actionType isKindOfClass:[ECSSMSActionType class]])
        {
            viewController.displaySMSOption = YES;
        }
        actionViewController = viewController;
    }
    else if ([actionType isKindOfClass:[ECSMessageActionType class]])
    {
        ECSMessageViewController *viewController = [ECSMessageViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        actionViewController = viewController;
    }
    else
    {
//        [[EXPERTconnect shared] recievedUnrecognizedAction:actionType.type];
//        actionViewController = [ECSRootViewController createPlaceholderViewController];
        
        ECSCallbackViewController *viewController = [ECSCallbackViewController ecs_loadFromNib];
        viewController.actionType = [actionType copy];
        
        if ([actionType isKindOfClass:[ECSSMSActionType class]])
        {
            viewController.displaySMSOption = YES;
        }
        actionViewController = viewController;
    }
    
    return actionViewController;
}

+ (ECSRootViewController*)createPlaceholderViewController
{
    ECSRootViewController *viewController = [[ECSRootViewController alloc] init];
    [viewController.view setFrame:[[UIScreen mainScreen] bounds]];
    
    ECSDynamicLabel *label = [[ECSDynamicLabel alloc] initWithFrame:CGRectMake(20, 150, 200, 44)];
    label.text = @"Not yet implemented";
    [label setTextColor:[UIColor blackColor]];
    label.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                              UIViewAutoresizingFlexibleBottomMargin);
    [viewController.view addSubview:label];
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    return viewController;
}

- (void)ecs_navigateToViewControllerForActionType:(ECSActionType*)actionType
{
    ECSRootViewController *controller = [ECSRootViewController ecs_viewControllerForActionType:actionType];
    controller.workflowDelegate = self.workflowDelegate;
    
    if (controller)
    {
        if ([self.actionType isKindOfClass:[ECSNavigationActionType class]])
        {
            ECSNavigationActionType *navAction = (ECSNavigationActionType*)self.actionType;
            controller.parentNavigationContext = navAction.navigationContext;
        }

        if (self.navigationController != nil && ![actionType.type isEqualToString:ECSActionTypeFormString])
        {
            if (controller.parentNavigationContext == nil)
            {
                controller.parentNavigationContext = self.parentNavigationContext;
            }
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            [self presentModal:controller withParentNavigationController:self.navigationController];
        }
    }
}

@end
