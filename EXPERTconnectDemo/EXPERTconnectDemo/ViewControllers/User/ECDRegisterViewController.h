//
//  ECDRegisterViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/ECSRootViewController.h>
#import "ECDLocalization.h"

@class ECDRegisterViewController;

@protocol ECSRegisterViewControllerDelegate <NSObject>

@required

- (void)registerViewController:(ECDRegisterViewController*)viewController didCompleteWithUser:(id)userInfo;

@end

/**
 View controller to support registering a new user
 */
@interface ECDRegisterViewController : ECSRootViewController

@property(nonatomic, weak) id<ECSRegisterViewControllerDelegate> delegate;

@end
