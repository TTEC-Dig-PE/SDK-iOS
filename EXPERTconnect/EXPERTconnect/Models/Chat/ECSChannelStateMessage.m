//
//  ECSChannelStateMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChannelStateMessage.h"

@implementation ECSChannelStateMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"state": @"state",
                                            @"estimatedWait": @"estimatedWait",
                                            @"version": @"version",
                                            }];
    return jsonMapping;
}

- (ECSChannelState)channelState
{
    if ([self.state isEqualToString:@"answered"])
    {
        return ECSChannelStateConnected;
    }
    
    return ECSChannelStateDisconnected;
}


@end
