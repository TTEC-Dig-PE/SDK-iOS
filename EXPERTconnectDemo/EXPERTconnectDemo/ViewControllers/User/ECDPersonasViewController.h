//
//  ECDPersonasViewController.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 3/28/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <EXPERTconnect/ECSRootViewController.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#endif

@interface ECDPersonasViewController : ECSRootViewController
@property (weak, nonatomic) IBOutlet UIButton *btnCaseOne;
@property (weak, nonatomic) IBOutlet UIButton *btnCaseTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnCaseThree;
@property (weak, nonatomic) IBOutlet UIButton *btnCaseFour;
@property (weak, nonatomic) IBOutlet UIButton *actionItemA;
@property (weak, nonatomic) IBOutlet UIButton *actionItemB;

- (IBAction)btnCaseOne_Touch:(id)sender;
- (IBAction)btnCaseTwo_Touch:(id)sender;
- (IBAction)btnCaseThree_Touch:(id)sender;
- (IBAction)btnCaseFour_Touch:(id)sender;

- (IBAction)actionItemA_Touch:(id)sender;
- (IBAction)actionItemB_Touch:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textViewLogging;

@end
