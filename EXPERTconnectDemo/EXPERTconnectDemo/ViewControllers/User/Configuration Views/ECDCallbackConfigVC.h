//
//  ECDCallbackConfigVC.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/6/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECDSimpleCallbackVC.h"

@interface ECDCallbackConfigVC : UIViewController {
    NSMutableArray *chatSkillsArray;
    NSString *currentEnvironment;
    NSString *currentChatSkill;
    int selectedRow;
    int rowToSelect;
    bool _chatActive;
}

@property (weak, nonatomic) IBOutlet UIPickerView *pickerChatSkill;
@property (weak, nonatomic) IBOutlet UILabel *chatSkillLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblAgentAvailability;

- (IBAction)btnHighLevelCallback_Touch:(id)sender;
- (IBAction)btnLowLevelCallback_Touch:(id)sender;

@end
