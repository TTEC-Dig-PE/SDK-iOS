//
//  ECSConverstaionCreateResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSConversationCreateResponse.h"

#import "ECSConversationLink.h"

@implementation ECSConversationCreateResponse

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"channelCount": @"channelCount",
             @"id": @"conversationID",
             @"journeyId": @"journeyID",
             @"location": @"location",
             @"deviceid": @"deviceID",
             @"creationDate": @"creationDate",
             @"lastModifiedDate": @"lastModifiedDate",
             @"expirationDate": @"expirationDate",
             @"state": @"state",
             @"_links.channels.href": @"channelLink",
             @"_links.close.href": @"closeLink",
             @"_links.journey.href": @"journeyLink",
             @"_links.self.href": @"selfLink",
             };
}

@end
