//
//  ECSAgentAvailableResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

/*
 {"lastModifiedDate":1445295974709,
 "expirationDate":null,
 "conversationCount":0,
 "creationDate":1445295974709,
 "organization":null,
 "_links":
    {"self":
        {"href":"http://api.dce1.humanify.com/conversationengine/v1/journeys/journey_e7b3ea04-9d93-48d7-9e65-48475dc3f586_mktwebextc"},
    "conversations":
        {"href":"http://api.dce1.humanify.com/conversationengine/v1/conversations"}
    },
"id":"journey_e7b3ea04-9d93-48d7-9e65-48475dc3f586_mktwebextc",
"_embedded":
    {"conversations":[]}
 }
 */

#import "ECSAgentAvailableResponse.h"

#import "ECSConversationLink.h"

@implementation ECSAgentAvailableResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{@"lastModifiedDate": @"lastModifiedDate",
             @"expirationDate": @"expirationDate",
             @"conversationCount": @"conversationCount",
             @"creationDate": @"creationDate",
             @"organization": @"organization",
             @"id": @"journeyID",
             @"_links.self.href": @"selfLink",
             @"_links.conversations.href": @"conversationLink",
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
