//
//  ECDAdHocChatPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/4/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocVideoChatPicker.h"

@implementation ECDAdHocVideoChatPicker

static NSString *const lastSkillSelectedKey = @"lastVoiceSkillSelected";

NSMutableArray *chatSkillsArray;
NSString *currentEnvironment;
NSInteger currentChatSkillIndex;
int selectedRow;

-(void)setup {
    
    currentEnvironment = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentName"];
    if(!currentEnvironment) {
        currentEnvironment = @"IntDev";
    }
    
    if (![self addChatSkillsFromServer]) {
        [self addChatSkillsHardcoded];
    }
    
    // Attempt to load the selected organization for the selected environment
    currentChatSkillIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastSkillSelectedKey]];
    
    if (!currentChatSkillIndex || currentChatSkillIndex > chatSkillsArray.count) {
        currentChatSkillIndex = 0;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentChatSkillIndex]
                                                  forKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastSkillSelectedKey]];
    }
    
    [super setup:chatSkillsArray withSelection:(int)currentChatSkillIndex];
    
    double width = (UIScreen.mainScreen.traitCollection.horizontalSizeClass == 1 ? 200.0f : 320.0f);
    [self setFrame: CGRectMake(0.0f, 0.0f, width, 180.0f)];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row]
                                              forKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastSkillSelectedKey]];
    
}

-(BOOL)addChatSkillsFromServer {
    
    NSArray *environmentConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentConfig"];
    
    if (!environmentConfig) {
        return NO;
    }
    
    for( NSDictionary *envData in environmentConfig) {
        
        if (envData[@"name"] && [envData[@"name"] isEqualToString:currentEnvironment]) {
            
            if(envData[@"agent_skills"]) {
                
                chatSkillsArray = [NSMutableArray new];
                for ( NSString *skill in envData[@"agent_skills"] ) {
                    [chatSkillsArray addObject:skill];
                }
            }
        }
    }
    
    return YES;
}

-(void)addChatSkillsHardcoded {
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
}

@end