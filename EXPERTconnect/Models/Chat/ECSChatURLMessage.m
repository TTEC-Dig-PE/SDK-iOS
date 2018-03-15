//
//  ECSChatURLMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatURLMessage.h"

@implementation ECSChatURLMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"from": @"from",
                                            @"url": @"url",
                                            @"urlType": @"urlType",
                                            @"comment": @"comment",
                                            @"version": @"version"
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatURLMessage *message = [[[self class] allocWithZone:zone] init];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.from = [self.from copyWithZone:zone];
    message.url = [self.url copyWithZone:zone];
    message.urlType = [self.urlType copyWithZone:zone];
    message.comment = [self.comment copyWithZone:zone];
    message.version = [self.version copyWithZone:zone];
    
    return message;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<URLMessage : from=%@, url=%@, urlType=%@, comment=%@, conversationId=%@, channelId=%@>",
            self.from, self.url, self.urlType, self.comment, self.conversationId, self.channelId];
}

@end
