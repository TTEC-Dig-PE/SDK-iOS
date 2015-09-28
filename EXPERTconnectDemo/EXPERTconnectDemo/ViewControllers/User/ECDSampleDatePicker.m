//
//  ECDSampleDatePicker.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 22/09/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDSampleDatePicker.h"

@implementation ECDSampleDatePicker

static NSString *const datePickerMode = @"UIDatePickerModeDate";
static NSString *const lastDateSelected = @"lastDateSelected";
static NSString *const dateFormat = @"MM-dd-yyyy";

-(void)setup
{
    [self setFrame: CGRectMake(200.0f, 0.0f, 320.0f, 180.0f)];
    NSDate *date = self.date;
    self.selection = [[NSUserDefaults standardUserDefaults] objectForKey:lastDateSelected];
    if(!self.selection)
    {
        self.selection = [self stringFromDate:date sendDateFormat:dateFormat];
    }
    [self setup:datePickerMode getDateFormat:dateFormat dateShow:self.selection];
}

-(void)dateChanged
{
    if(self.datePickerMode == UIDatePickerModeDate)
    {
        NSDate *date = self.date;
        [[NSUserDefaults standardUserDefaults] setObject:[self stringFromDate:date sendDateFormat:dateFormat] forKey:lastDateSelected];
    }
}

//date to string conversion
-(NSString *)stringFromDate:(NSDate *)date sendDateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end
