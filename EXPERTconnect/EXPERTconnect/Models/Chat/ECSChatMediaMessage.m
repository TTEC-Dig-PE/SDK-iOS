//
//  ECSChatImageMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMediaMessage.h"

@implementation ECSChatMediaMessage

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

@end
