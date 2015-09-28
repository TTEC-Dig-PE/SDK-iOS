//
//  ECDSampleDatePicker.h
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 22/09/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/EXPERTconnect.h>

#import "ECDUIDatePicker.h"

@interface ECDSampleDatePicker : ECDUIDatePicker

@property (nonatomic, strong) NSString *selection;

-(void)setup;

-(NSString *)stringFromDate:(NSDate *)date sendDateFormat:(NSString *)dateFormat;

@end
