//
//  ECDLoginViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/ECSRootViewController.h>

@class ECDLoginViewController;

@protocol ECDLoginViewControllerDelegate <NSObject>

@required

- (void)loginViewController:(ECDLoginViewController*)login didLoginWithUserInfo:(id)userInfo;

@end

/**
 View controller used to support Humanify controlled log in
 */
@interface ECDLoginViewController : ECSRootViewController

@property (nonatomic, weak) id<ECDLoginViewControllerDelegate> delegate;

@end
