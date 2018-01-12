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

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatNotificationMessage *message = [[[self class] allocWithZone:zone] init];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.from = [self.from copyWithZone:zone];
    message.type = [self.type copyWithZone:zone];
    message.objectData = [self.objectData copyWithZone:zone];
    
    return message;
}

@end
