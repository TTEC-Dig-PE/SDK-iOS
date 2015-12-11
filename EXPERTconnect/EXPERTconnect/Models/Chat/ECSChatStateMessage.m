//
//  ECSChatStateMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatStateMessage.h"

@implementation ECSChatStateMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                           @"conversationId": @"conversationId",
                                           @"channelId": @"channelId",
                                           @"from": @"from",
                                           @"to": @"to",
                                           @"state": @"state",
                                           @"version": @"version",
                                           @"object": @"object",
                                           @"type": @"type"
                                           }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatStateMessage *message = [[self class] new];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.from = [self.from copyWithZone:zone];
    message.to = [self.to copyWithZone:zone];
    message.state = [self.state copyWithZone:zone];
    message.version = [self.version copyWithZone:zone];
    message.object = [self.object copyWithZone:zone];
    message.type = [self.object copyWithZone:zone];

    return message;
}

- (ECSChatState)chatState
{
    if ([self.state isEqualToString:@"paused"])
    {
        return ECSChatStateTypingPaused;
    }
    else if ([self.state isEqualToString:@"composing"])
    {
        return ECSChatStateComposing;
    }
    
    return ECSChatStateUnknown;
}
@end
