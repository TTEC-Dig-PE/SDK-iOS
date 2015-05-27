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
             };
}

@end
