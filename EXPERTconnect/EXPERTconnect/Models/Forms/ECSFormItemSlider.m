//
//  ECSFormItemSlider.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemSlider.h"

@implementation ECSFormItemSlider

- (NSDictionary*)ECSJSONMapping
{
    NSMutableDictionary* mapping = [[super ECSJSONMapping] mutableCopy];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.minValue": @"minValue",
                                        @"configuration.maxValue": @"maxValue",
                                        @"configuration.minLabel": @"minLabel",
                                        @"configuration.maxLabel": @"maxLabel"
                                        }];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormItemSlider *formItem = [super copyWithZone:zone];
    formItem.minValue = [self.minValue copy];
    formItem.maxValue = [self.maxValue copy];
    formItem.minLabel = [self.minLabel copy];
    formItem.maxLabel = [self.maxLabel copy];
    
    return formItem;
}


- (BOOL)answered
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *value = [f numberFromString:self.formValue];
    //return value  >= self.minValue  && value <= self.maxValue;
    return ([value compare:self.minValue] == NSOrderedDescending && [value compare:self.maxValue] == NSOrderedAscending);
}

@end
