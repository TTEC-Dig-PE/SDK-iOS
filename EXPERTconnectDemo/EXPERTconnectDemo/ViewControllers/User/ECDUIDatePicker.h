//
//  ECDUIDatePicker.h
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 22/09/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDUIDatePicker : UIDatePicker

-(void)setup:(NSString *)datePickerMode getDateFormat:(NSString *)dateFormat dateShow:(NSString *)dateString;

-(NSDate *)dateFromString:(NSString *)dateString sendDateFormat:(NSString *)dateFormat;

@end
