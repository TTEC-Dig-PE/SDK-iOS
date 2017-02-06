//
//  ECDReportBugViewController.h
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 03/01/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/ECSRootViewController.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import "AppDelegate.h"

@interface ECDReportBugViewController : ECSRootViewController

@property (weak, nonatomic) IBOutlet ECSButton *reportBug;

- (IBAction)reportBug_Touch:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textViewLogging;

@end
