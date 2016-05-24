//
//  ECSChannelTimeoutWarningMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChannelTimeoutWarningMessage.h"

@implementation ECSChannelTimeoutWarningMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                           @"conversationId": @"conversationId",
                                           @"channelId": @"channelId",
                                           @"timeoutSeconds": @"timeoutSeconds",
                                           @"version": @"version"
                                           }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChannelTimeoutWarningMessage *message = [[self class] new];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.timeoutSeconds = [self.timeoutSeconds copyWithZone:zone];
    message.version = [self.version copyWithZone:zone];

    return message;
}

@end
