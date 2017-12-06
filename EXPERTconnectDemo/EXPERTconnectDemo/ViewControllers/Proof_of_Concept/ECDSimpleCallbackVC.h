//
//  ECDSimpleCallbackVC.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/6/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDSimpleCallbackVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblEstimatedWait;
- (IBAction)btnCallBack_Touch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCallBack;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnCallback;

@property (strong, nonatomic) NSString *callbackSkill; 
@end

