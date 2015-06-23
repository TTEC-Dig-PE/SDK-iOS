//
//  ECSDynamicViewController+Navigation.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/ECSActionType.h>
#import "ECSRootViewController.h"

/**
 Category to add support for requesting a view controller for a specified action type.
 */
@interface ECSRootViewController (Navigation)

+ (instancetype)ecs_viewControllerForActionType:(ECSActionType*)actionType;

- (void)ecs_navigateToViewControllerForActionType:(ECSActionType*)actionType;

@end
