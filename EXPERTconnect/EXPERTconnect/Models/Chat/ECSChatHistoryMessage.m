//
//  ECSChatHistoryMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatHistoryMessage.h"

@implementation ECSChatHistoryMessage


- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"actionId": @"actionId",
             @"context": @"context",
             @"date": @"dateString",
             @"id": @"messageId",
             @"journeyId": @"journeyId",
             @"request": @"request",
             @"response": @"response",
             @"title": @"title",
             @"type": @"type"
             };
             
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{
             @"responses": [NSDictionary class]
             };
}

@end
