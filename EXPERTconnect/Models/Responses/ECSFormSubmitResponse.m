//
//  ECSFormSubmitResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormSubmitResponse.h"

#import "ECSActionTypeClassTransformer.h"

@implementation ECSFormSubmitResponse

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"action": @"action",
             @"identity_token": @"identityToken",
             @"profile_was_updated": @"profileUpdated",
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
