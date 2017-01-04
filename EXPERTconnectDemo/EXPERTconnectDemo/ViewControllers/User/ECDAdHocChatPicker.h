//
//  ECDAdHocChatPicker.h
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/4/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/EXPERTconnect.h>

#import "ECDUIPicker.h"

@interface ECDAdHocChatPicker : ECDUIPicker {
    NSMutableArray *chatSkillsArray;
    NSString *currentEnvironment;
    NSString *currentChatSkill;
    int selectedRow;
    int rowToSelect;
}

-(void)setup;

@end

