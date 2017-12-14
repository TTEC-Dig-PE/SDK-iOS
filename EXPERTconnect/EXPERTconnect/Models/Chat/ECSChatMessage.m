//
//  ECSChatMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

@implementation ECSChatMessage

- (NSDictionary *)ECSJSONMapping
{
    return @{};
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatMessage *message = [[self class] new];
    message.fromAgent = self.fromAgent;
    message.conversationId = self.conversationId;
    
    return message;
}

@end
