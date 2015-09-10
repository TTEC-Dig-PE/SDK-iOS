//
//  ECDAdHocAnswerEngineContextPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/4/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocAnswerEngineContextPicker.h"

@implementation ECDAdHocAnswerEngineContextPicker

static NSString *const lastAnswerEngineContextSelected = @"lastAnswerEngineContextSelected";

-(void)setup {
    NSMutableArray *answerEngineContextsArray = [NSMutableArray new];
    
    [answerEngineContextsArray addObject:@"Telecommunications"];
    [answerEngineContextsArray addObject:@"SDK Demo Technical Support"];
    [answerEngineContextsArray addObject:@"SDK Demo Account Support"];
    [answerEngineContextsArray addObject:@"SDK Demo Technical Support FR"];
    [answerEngineContextsArray addObject:@"SDK Demo Account Support FR"];
    [answerEngineContextsArray addObject:@"SDK Demo Technical Support ES"];
    [answerEngineContextsArray addObject:@"SDK Demo Account Support ES"];
    [answerEngineContextsArray addObject:@"Demo AppT1"];
    [answerEngineContextsArray addObject:@"Demo AppT2"];
    [answerEngineContextsArray addObject:@"Demo AppT3"];
    [answerEngineContextsArray addObject:@"Demo AppT4"];
    [answerEngineContextsArray addObject:@"Cable"];
    [answerEngineContextsArray addObject:@"Live Connect"];
    [answerEngineContextsArray addObject:@"Financial Services"];
    
    int rowToSelect = [[[NSUserDefaults standardUserDefaults] objectForKey:lastAnswerEngineContextSelected] intValue];
    
    [super setup:answerEngineContextsArray withSelection:rowToSelect];
    [self setFrame: CGRectMake(0.0f, 0.0f, 420.0f, 180.0f)];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row] forKey:lastAnswerEngineContextSelected];
}

@end