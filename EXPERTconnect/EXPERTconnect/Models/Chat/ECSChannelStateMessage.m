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
    ECSChannelState returnState = ECSChannelStateUnknown;
    
    if ([self.state isEqualToString:@"answered"])
    {
        returnState = ECSChannelStateConnected;
    }
    else if([self.state isEqualToString:@"notify"])
    {
        returnState = ECSChannelStateNotify;
    }
    else if([self.state isEqualToString:@"disconnected"])
    {
        returnState = ECSChannelStateDisconnected;
    }
    else
    {
        returnState = ECSChannelStateUnknown;
    }
    
    NSLog(@"ChannelStateMessage::ChannelState = %lu. Source = %@.", (unsigned long)returnState, self.state);
    return returnState;
}


@end
