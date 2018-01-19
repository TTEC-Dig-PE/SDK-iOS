//
//  ECSChatAssociateInfoMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatAssociateInfoMessage.h"

@implementation ECSChatAssociateInfoMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"id": @"messageId",
                                            @"userId": @"from",
                                            @"message": @"message",
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatAssociateInfoMessage *message = [[[self class] allocWithZone:zone] init];
    
    message.conversationId =    [self.conversationId copyWithZone:zone];
    message.channelId =         [self.channelId copyWithZone:zone];
    message.messageId =         [self.messageId copyWithZone:zone];
    message.from =              [self.from copyWithZone:zone];
    message.message =           [self.message copyWithZone:zone];
    message.fromAgent =         self.fromAgent;
    
    return message;
}

@end
