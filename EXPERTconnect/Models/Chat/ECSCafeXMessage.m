//
//  ECSCafeXMessage.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/13/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCafeXMessage.h"

@implementation ECSCafeXMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"id": @"messageId",
                                            @"userId": @"from",
                                            @"parameter1": @"parameter1",
                                            @"parameter2": @"parameter2",
                                            @"start": @"start",
                                            @"guid": @"guid"
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSCafeXMessage *message = [[[self class] allocWithZone:zone] init];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.messageId = [self.messageId copyWithZone:zone];
    message.from = [self.from copyWithZone:zone];
    message.parameter1 = [self.parameter1 copyWithZone:zone];
    message.parameter2 = [self.parameter2 copyWithZone:zone];
    message.start = [self.start copyWithZone:zone];
    message.guid = [self.guid copyWithZone:zone];
    message.fromAgent = self.fromAgent;
    
    return message;
}

@end
