//
//  ECSChannelConfiguration.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChannelConfiguration.h"

@implementation ECSChannelConfiguration

- (NSDictionary *)ECSJSONMapping
{
    return @{
             
             @"to": @"to",
             @"from": @"from",
             @"subject": @"subject",
             @"mediaType": @"mediaType",
             @"priority": @"priority",
             @"sourceType": @"sourceType",
             @"sourceAddress": @"sourceAddress",
             @"location": @"location",
             @"deviceId": @"deviceId",
             @"features": @"features",
             @"options": @"options",
             @"state": @"state"
             };
}

-(BOOL)ignoreNilValues {
    return YES;
}

- (ECSChannelState)channelState
{
    NSString *theState = [self.state lowercaseString];
    
    if ([theState isEqualToString:@"pending"]) {
        return ECSChannelStatePending;
    } else if ([theState isEqualToString:@"queued"]) {
        return ECSChannelStateQueued;
    } else if ([theState isEqualToString:@"answered"]) {
        return ECSChannelStateAnswered;
    } else if ([theState isEqualToString:@"disconnected"]) {
        return ECSChannelStateDisconnected;
    } else if ([theState isEqualToString:@"failed"]) {
        return ECSChannelStateFailed;
    } else if ([theState isEqualToString:@"notify"]) {
        return ECSChannelStateNotify;
    } else if ([theState isEqualToString:@"timeout"]) {
        return ECSChannelStateTimeout;
    }
    return ECSChannelStateUnknown;
}

@end
