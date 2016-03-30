//
//  ECDPersonasViewController.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 3/28/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/ECSRootViewController.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>

@interface ECDPersonasViewController : ECSRootViewController
@property (weak, nonatomic) IBOutlet UIButton *btnCaseOne;
- (IBAction)btnCaseOne_Touch:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textViewLogging;

@end
