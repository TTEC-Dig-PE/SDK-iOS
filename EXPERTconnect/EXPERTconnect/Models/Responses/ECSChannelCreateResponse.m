//
//  ECSChannelCreateResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChannelCreateResponse.h"

#import "ECSConversationLink.h"

@implementation ECSChannelCreateResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{@"id": @"channelId",
             @"conversationId": @"conversationId",
             @"mediaType": @"mediaType",
             @"creationDate": @"creationDate",
             @"lastModifiedDate": @"lastModifiedDate",
             @"expirationDate": @"expirationDate",
             @"state": @"state",
             @"_links.chatState.href": @"chatStateLink",
             @"_links.close.href": @"closeLink",
             @"_links.messages.href": @"messagesLink",
             @"_links.mself.href": @"selfLink",
             };
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
    for (NSString *property in self.ECSJSONMapping.allValues)
    {
        [string appendString:[NSString stringWithFormat:@"%@: %@\n", property, [self valueForKey:property]]];
    }
    
    return string;
}

@end
