//
//  ECDUIDatePicker.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 22/09/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDUIDatePicker.h"

@implementation ECDUIDatePicker

-(void)setup:(NSString *)datePickerMode getDateFormat:(NSString *)dateFormat dateShow:(NSString *)dateString
{
    [self addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [self setFrame: CGRectMake(200.0f, 0.0f, 320.0f, 180.0f)];
    if([datePickerMode isEqualToString:@"UIDatePickerModeDate"])
    {
        self.datePickerMode = UIDatePickerModeDate;
    }
    else if([datePickerMode isEqualToString:@"UIDatePickerModeDateAndTime"])
    {
        self.datePickerMode = UIDatePickerModeDateAndTime;
    }
    else if([datePickerMode isEqualToString:@"UIDatePickerModeCountDownTimer"])
    {
        self.datePickerMode = UIDatePickerModeCountDownTimer;
    }
    else if([datePickerMode isEqualToString:@"UIDatePickerModeTime"])
    {
        self.datePickerMode = UIDatePickerModeTime;
    }
    else
    {
        self.datePickerMode = UIDatePickerModeDate;
    }
    self.date = [self dateFromString:dateString sendDateFormat:dateFormat];
}

//string to date conversion
-(NSDate *)dateFromString:(NSString *)dateString sendDateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

-(void)dateChanged
{
    
}

@end
