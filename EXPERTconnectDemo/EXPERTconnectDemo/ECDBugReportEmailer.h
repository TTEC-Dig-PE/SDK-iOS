//
//  ECDBugReportEmailer.h
//  HorizonConnectDemo
//
//  Created by Nathan Keeney on 10/5/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef ECDBugReportEmailer_h
#define ECDBugReportEmailer_h

#import <MessageUI/MessageUI.h>

@interface ECDBugReportEmailer: NSObject <MFMailComposeViewControllerDelegate>

- (void)reportBug;
+ (void)setUpLogging;
+ (void)resetLogging;

@end

#endif
