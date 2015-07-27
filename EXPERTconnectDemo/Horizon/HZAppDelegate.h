//
//  HZAppDelegate.h
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 18/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>

#import "MoxtraController.h"

#import "HZMainScreenViewController.h"
#import "HZPerformanceViewController.h"
#import "HZResearchViewController.h"
#import "HZRiskViewController.h"

@interface HZAppDelegate : UIResponder <UIApplicationDelegate, ExpertConnectDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MoxtraController *moxtraController;

@property (nonatomic, strong, readonly) HZMainScreenViewController *mainViewController;
@property (nonatomic, strong, readonly) HZPerformanceViewController *performanceViewController;
@property (nonatomic, strong, readonly) HZResearchViewController *researchViewController;
@property (nonatomic, strong, readonly) HZRiskViewController *riskViewController;

- (void)showLoginScreen;
- (void)showDrawerAndMainScreen;

- (void)dismissChatWindow;
- (void)minimizeChatWindow;
- (void)presentChatWindow;
- (void)maximizeChatWindow;

@end
