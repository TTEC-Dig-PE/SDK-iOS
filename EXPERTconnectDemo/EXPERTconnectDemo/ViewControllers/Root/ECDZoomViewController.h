//
//  ECDZoomViewController.h
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDZoomViewController : UIViewController

- (BOOL)isLeftViewVisible;
- (void)hideLeftViewController;
- (void)showLeftViewController;

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIView *backgroundView;

@end

@interface UIViewController (ECDZoomViewController)

@property (nonatomic, readonly) ECDZoomViewController *ecd_zoomViewController;

@end
