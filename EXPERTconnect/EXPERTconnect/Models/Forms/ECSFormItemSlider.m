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
    NSInteger value = [self.formValue integerValue];
    return value >= [self.minValue integerValue] && value <= [self.maxValue integerValue];
}

@end
