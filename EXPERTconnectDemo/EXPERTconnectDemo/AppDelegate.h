//
//  AppDelegate.h
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECDBugReportEmailer.h"
#import "AppConfig.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ECDBugReportEmailer *bugReportEmailer;
@property (strong, nonatomic) NSMutableString *logMessages;

- (void)reportBug;
- (void)reportBug:(NSMutableString *)message;

@end


