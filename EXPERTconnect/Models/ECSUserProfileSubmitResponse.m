//
//  ECSUserProfileSubmitResponse.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSUserProfileSubmitResponse.h"

#import "ECSActionTypeClassTransformer.h"

@implementation ECSUserProfileSubmitResponse

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"action": @"action",
             @"submitted": @"submitted"
             };
}

- (NSDictionary*)ECSJSONTransformMapping
{
    return @{
             @"action": [ECSActionTypeClassTransformer class],
             };
}

@end
