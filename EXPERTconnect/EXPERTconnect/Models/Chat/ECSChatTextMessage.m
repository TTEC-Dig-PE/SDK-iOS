//
//  ECSChatTextMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTextMessage.h"

@implementation ECSChatTextMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"id": @"messageId",
                                            @"from": @"from",
                                            @"body": @"body",
                                            @"chatState": @"chatState",
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatTextMessage *message = [[[self class] allocWithZone:zone] init];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.messageId = [self.messageId copyWithZone:zone];
    message.from = [self.from copyWithZone:zone];
    message.body = [self.body copyWithZone:zone];
    message.chatState = [self.chatState copyWithZone:zone];
    message.fromAgent = self.fromAgent;
    message.timeStamp = [self.timeStamp copyWithZone:zone];
	 
    return message;
}

- (NSData*)socketMessage
{
    NSDictionary *socketMessage = @{
                                    @"from": self.from,
                                    @"body": self.body,
                                    };
    return [NSKeyedArchiver archivedDataWithRootObject:socketMessage];
}

@end
