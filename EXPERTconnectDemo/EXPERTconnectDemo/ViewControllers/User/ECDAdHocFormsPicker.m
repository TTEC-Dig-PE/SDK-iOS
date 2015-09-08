//
//  ECDAdHocFormsPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/5/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ECDAdHocFormsPicker.h"

@implementation ECDAdHocFormsPicker

static NSString *const lastFormSelected = @"lastFormSelected";

-(void)setup {
    NSMutableArray *formsArray = [NSMutableArray new];
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];

    [sessionManager getFormNamesWithCompletion:^(NSArray *formNames, NSError *error) {
        if (error == nil) {
            for(NSString *formName in formNames)  {
                [formsArray addObject:formName];
            }
            
            int rowToSelect = [[[NSUserDefaults standardUserDefaults] objectForKey:lastFormSelected] intValue];
            
            [super setup:formsArray withSelection:rowToSelect];
            
            [self setFrame: CGRectMake(0.0f, 0.0f, 320.0f, 180.0f)];
        }
    }];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row] forKey:lastFormSelected];
}

@end