//
//  ECSAnswerEngineRateResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerEngineRateResponse.h"

#import "ECSActionTypeClassTransformer.h"

@implementation ECSAnswerEngineRateResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"actions": @"actions",
             };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"actions": [ECSActionTypeClassTransformer class]};
}

@end
