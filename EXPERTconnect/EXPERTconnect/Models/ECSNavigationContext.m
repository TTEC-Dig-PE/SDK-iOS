//
//  ECSNavigationContext.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSNavigationContext.h"

#import "ECSNavigationSection.h"

@implementation ECSNavigationContext

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"title": @"title",
             @"sections": @"sections",
             };
}

- (NSDictionary*)ECSJSONTransformMapping
{
    return @{
             @"sections": [ECSNavigationSection class],
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSNavigationContext *context = [[[self class] allocWithZone:zone] init];
    
    context.title = [self.title copyWithZone:zone];
    context.sections = [self.sections copyWithZone:zone];
    
    return context;
}

@end
