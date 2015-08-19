//
//  ECSNavigationManager.h
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

typedef void(^completionBlock)(void);

@interface ECSNavigationManager : NSObject

//TODO: easy
- (void)pushViewController:(UIViewController *)viewController completion:(completionBlock)completion;
- (void)popViewController:(UIViewController *)viewController completion:(completionBlock)completion;

//TODO: done
- (void)kickOffOnViewController:(UIViewController *)hostViewController;

- (void)presentViewControllerModally:(UIViewController *)viewController
                            animated:(BOOL)shouldAnimate
        wrapWithNavigationController:(BOOL)wrapWithNavigationController
                          completion:(completionBlock)completion;

- (void)dismissViewControllerModallyAnimated:(BOOL)shouldAnimate
                                  completion:(completionBlock)completion;

- (void)dismissAllViewControllersAnimated:(BOOL)shouldAnimate
                               completion:(completionBlock)completion;

//TODO: major
- (void)minmizeAllViewControllersWithCompletion:(completionBlock)completion;
- (void)restoreAllViewControllersWithCompletion:(completionBlock)completion;

@end
