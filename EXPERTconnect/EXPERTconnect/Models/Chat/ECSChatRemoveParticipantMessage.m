//
//  ECSChatAddParticipantMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatRemoveParticipantMessage.h"

@implementation ECSChatRemoveParticipantMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"reason": @"reason",
                                            @"userId": @"userId",
                                            @"version": @"version",
                                            @"fullName": @"fullName",
                                            @"firstName": @"firstName",
                                            @"lastName": @"lastName"
                                            }];

    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatRemoveParticipantMessage *message = [[[self class] allocWithZone:zone] init];
    
    message.conversationId =    [self.conversationId copyWithZone:zone];
    message.channelId =         [self.channelId copyWithZone:zone];
    message.reason =            [self.reason copyWithZone:zone];
    message.fullName =          [self.fullName copyWithZone:zone];
    message.userId =            [self.userId copyWithZone:zone];
    message.firstName =         [self.firstName copyWithZone:zone];
    message.lastName =          [self.lastName copyWithZone:zone];
    
    return message;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<RemoveParticipantMessage : name=%@ %@, userId=%@, reason=%@, conversationId=%@, channelId=%@>",
            self.firstName, self.lastName, self.userId, self.reason, self.conversationId, self.channelId];
}

@end
