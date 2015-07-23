//
//  ECDRunModePicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/22/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDRunModePicker.h"

@implementation ECDRunModePicker

static NSString *const applicationRunMode = @"applicationRunMode";

-(void)setup {
    NSMutableArray *runModeArray = [NSMutableArray new];
    
    [runModeArray addObject:@"Expert Demo"];  // 0 - startExpertDemo in main()
    [runModeArray addObject:@"Horizon Demo"]; // 1 - startHorizonDemo in main()
    
    [super setup:runModeArray];
    
    // Always Select "Expert Demo" to start. Other Apps will have to have their own settings
    // to set this back to "Expert Demo"
    //
    int rowToSelect = 0;
    [self selectRow:rowToSelect inComponent:0 animated:YES];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row] forKey:applicationRunMode];
}

@end