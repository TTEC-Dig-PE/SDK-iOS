//
//  ECSAnswerEngineTopQuestionsResponse.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/13/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerEngineTopQuestionsResponse.h"

#import "ECSActionTypeClassTransformer.h"

@implementation ECSAnswerEngineTopQuestionsResponse

// Not Used: Top Questions response is an NSArray 
//
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
