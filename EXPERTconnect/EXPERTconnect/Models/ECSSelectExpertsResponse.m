//
//  ECSSelectExpertsResponse.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSelectExpertsResponse.h"

#import "ECSActionTypeClassTransformer.h"

@implementation ECSSelectExpertsResponse

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"action": @"action"
             };
}

- (NSDictionary*)ECSJSONTransformMapping
{
    return @{
             @"action": [ECSActionTypeClassTransformer class],
             };
}

@end
