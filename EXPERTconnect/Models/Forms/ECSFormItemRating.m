//
//  ECSFormItemRating.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemRating.h"

@implementation ECSFormItemRating

- (NSDictionary*)ECSJSONMapping
{
    NSMutableDictionary* mapping = [[super ECSJSONMapping] mutableCopy];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.maxValue": @"maxValue"
                                        }];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormItemRating *formItem = [super copyWithZone:zone];
    formItem.maxValue = [self.maxValue copy];
    
    return formItem;
}

- (BOOL)answered
{
    NSInteger value = [self.formValue integerValue];
    return value > 0 && value <= [self.maxValue integerValue];
}
@end
