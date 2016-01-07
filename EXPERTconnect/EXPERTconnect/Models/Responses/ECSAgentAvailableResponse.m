//
//  ECSAgentAvailableResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

/*
 skills =         (
 {
 "_links" =                 {
 self =                     {
 href = "http://api.humanify.com:8080/conversationengine/v1/skills/CE_Mobile_Chat";
 };
 };
 agentsLoggedOn = 2;
 open = 1;
 skillName = "CE_Mobile_Chat";
 }
 );
 };
 */

#import "ECSAgentAvailableResponse.h"

#import "ECSConversationLink.h"

@implementation ECSAgentAvailableResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{@"_embedded.skills": @"skills",
             @"_links.self.href": @"selfLink"
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
