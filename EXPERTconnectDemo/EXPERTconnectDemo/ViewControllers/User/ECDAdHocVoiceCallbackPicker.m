//
//  ECDAdHocVoiceCallbackPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/6/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocVoiceCallbackPicker.h"

@implementation ECDAdHocVoiceCallbackPicker

static NSString *const lastVoiceSkillSelected = @"lastVoiceSkillSelected";

-(void)setup {
    [super setup];
    
    int rowToSelect = [[[NSUserDefaults standardUserDefaults] objectForKey:lastVoiceSkillSelected] intValue];
    
    [self selectRow:rowToSelect inComponent:0 animated:YES];
    
    self.selection = [self.dataArray objectAtIndex:rowToSelect];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row] forKey:lastVoiceSkillSelected];
}

@end