//
//  ECSChatNotificationMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatNotificationMessage.h"

@implementation ECSChatNotificationMessage

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"conversationId": @"conversationId",
             @"channelId": @"channelId",
             @"from": @"from",
             @"type": @"type",
             @"object": @"objectData"
             };
}

@end
