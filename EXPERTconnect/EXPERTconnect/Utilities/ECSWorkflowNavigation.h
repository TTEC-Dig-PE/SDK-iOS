//
//  ECSWorkflowNavigation.h
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

typedef void(^completionBlock)(void);

@interface ECSWorkflowNavigation : NSObject

- (instancetype)initWithHostViewController:(UIViewController *)hostViewController;

- (void)presentViewControllerInNavigationControllerModally:(UIViewController *)viewController
                                                  animated:(BOOL)shouldAnimate
                                                completion:(completionBlock)completion;

- (void)presentViewControllerModally:(UIViewController *)viewController
                            animated:(BOOL)shouldAnimate
                          completion:(completionBlock)completion;

- (void)dismissViewControllerModallyAnimated:(BOOL)shouldAnimate
                                  completion:(completionBlock)completion;

- (void)dismissAllViewControllersAnimated:(BOOL)shouldAnimate
                               completion:(completionBlock)completion;

- (void)minmizeAllViewControllersWithCompletion:(completionBlock)completion;
- (void)restoreAllViewControllersWithCompletion:(completionBlock)completion;

@end
