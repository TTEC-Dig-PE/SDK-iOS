//
//  ECDAdHocChatPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/4/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocChatPicker.h"

@implementation ECDAdHocChatPicker

static NSString *const lastSkillSelected = @"lastSkillSelected";

NSMutableArray *chatSkillsArray;

-(void)setup {
    chatSkillsArray = [NSMutableArray new];
    
    [chatSkillsArray addObject:@"CE_Mobile_Chat"];
    [chatSkillsArray addObject:@"Finance"];
    [chatSkillsArray addObject:@"Sales"];
    [chatSkillsArray addObject:@"webnav"];
    [chatSkillsArray addObject:@"wgenQs"];
    [chatSkillsArray addObject:@"wmtvte"];
    [chatSkillsArray addObject:@"wppv"];
    [chatSkillsArray addObject:@"wtrack"];
    [chatSkillsArray addObject:@"Calls for ken_mktwebextc"];
    [chatSkillsArray addObject:@"Calls for nathan_mktwebextc"];
    [chatSkillsArray addObject:@"Calls for ken_horizon"];
    [chatSkillsArray addObject:@"Calls for nathan_horizon"];
    [chatSkillsArray addObject:@"Calls for samantha_horizon"];
    [chatSkillsArray addObject:@"Calls for chris_horizon"];
    
    int rowToSelect = [[[NSUserDefaults standardUserDefaults] objectForKey:lastSkillSelected] intValue];

    [super setup:chatSkillsArray withSelection:rowToSelect];
    [self setFrame: CGRectMake(0.0f, 0.0f, 320.0f, 180.0f)];
    
    [self performSelector:@selector(getAgentsForLastSelected) withObject:nil afterDelay:0.5]; 
}

-(void)getAgentsForLastSelected {
    int rowToSelect = [[[NSUserDefaults standardUserDefaults] objectForKey:lastSkillSelected] intValue];
    [self getAgentsAvailableForSkill:rowToSelect];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row] forKey:lastSkillSelected];
    
    [self getAgentsAvailableForSkill:(int)row];
}

-(void)getAgentsAvailableForSkill:(int)index {
    [[EXPERTconnect shared] agentAvailabilityWithSkill:[chatSkillsArray objectAtIndex:index]
                                            completion:^(NSDictionary *data, NSError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatSkillAgentInfoUpdated"
                                                             object:nil
                                                           userInfo:data];
         
     }];
}

@end