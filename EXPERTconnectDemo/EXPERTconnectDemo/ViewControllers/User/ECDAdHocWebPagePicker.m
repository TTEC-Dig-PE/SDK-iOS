//
//  ECDAdHocWebPagePicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/6/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocWebPagePicker.h"

@implementation ECDAdHocWebPagePicker

static NSString *const lastWebPageSelected = @"lastWebPageSelected";

-(void)setup {
    NSMutableArray *webPagesArray = [NSMutableArray new];
    
    [webPagesArray addObject:@"http://www.humanify.com"];
    [webPagesArray addObject:@"http://www.yahoo.com"];
    [webPagesArray addObject:@"http://www.google.com"];
    [webPagesArray addObject:@"http://www.pinterest.com"];
    [webPagesArray addObject:@"http://www.facebook.com"];
    
    int rowToSelect = [[[NSUserDefaults standardUserDefaults] objectForKey:lastWebPageSelected] intValue];
    
    [super setup:webPagesArray withSelection:rowToSelect];
    double width = (UIScreen.mainScreen.traitCollection.horizontalSizeClass == 1 ? 200.0f : 320.0f);
    [self setFrame: CGRectMake(0.0f, 0.0f, width, 180.0f)];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row] forKey:lastWebPageSelected];
}

@end