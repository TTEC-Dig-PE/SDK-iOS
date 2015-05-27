//
//  ECSChatAddChannelMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatAddChannelMessage.h"

@implementation ECSChatAddChannelMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"from": @"from",
                                            @"mediaType": @"mediaType",
                                            @"suggestedAddress": @"suggestedAddress",
                                            @"version": @"version",
                                            }];
    return jsonMapping;
}

@end
