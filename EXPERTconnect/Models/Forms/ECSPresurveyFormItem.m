//
//  ECSPresurveyFormItem.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSPresurveyFormItem.h"

@implementation ECSPresurveyFormItem

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"name" : @"name",
             @"value": @"value",
             @"metadata": @"metadata",
             @"response" : @"response",
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSPresurveyFormItem *formItem = [[[self class] allocWithZone:zone] init];
    formItem.name = [self.name copyWithZone:zone];
    formItem.value = [self.value copyWithZone:zone];
    formItem.metadata = [self.metadata copyWithZone:zone];
    
    return formItem;
}
@end
