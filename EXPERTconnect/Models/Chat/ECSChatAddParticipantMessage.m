//
//  ECSChatAddParticipantMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatAddParticipantMessage.h"

@implementation ECSChatAddParticipantMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"fullName": @"fullName",
                                            @"userId": @"userId",
                                            @"version": @"version",
                                            @"firstName": @"firstName",
                                            @"lastName": @"lastName",
                                            @"avatarUrl": @"avatarURL",
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatAddParticipantMessage *message = [[[self class] allocWithZone:zone] init];
    
    message.conversationId =    [self.conversationId copyWithZone:zone];
    message.channelId =         [self.channelId copyWithZone:zone];
//    message.messageId =         [self.messageId copyWithZone:zone];
    message.fullName =          [self.fullName copyWithZone:zone];
    message.userId =            [self.userId copyWithZone:zone];
    message.firstName =         [self.firstName copyWithZone:zone];
    message.lastName =          [self.lastName copyWithZone:zone];
    message.avatarURL =         [self.avatarURL copyWithZone:zone];
    
    
    return message;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<AddParticipantMessage : name=%@ %@, userId=%@, avatarURL=%@, conversationId=%@, channelId=%@>",
            self.firstName, self.lastName, self.userId, self.avatarURL, self.conversationId, self.channelId];
}

@end
