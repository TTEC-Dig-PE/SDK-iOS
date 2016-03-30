//
//  ECSSkillDetail.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

/*
 active = 0;
 chatCapacity = 4;
 chatReady = 4;
 description = "Mobile Chat Skill for Testing";
 estWait = 0;
 inQueue = 0;
 queueOpen = 1;
 skillName = "CE_Mobile_Chat";
 voiceCapacity = 1;
 voiceReady = 1;
 */

#import "ECSSkillDetail.h"
//#import "ECSConversationLink.h"

@implementation ECSSkillDetail

- (NSDictionary *)ECSJSONMapping
{
    /*return @{@"_embedded.skills": @"skills",
             @"_links.self.href": @"selfLink"
             };*/
    return @{@"active": @"active",
             @"chatCapacity": @"chatCapacity",
             @"chatReady": @"chatReady",
             @"description": @"skillDescription",
             @"estWait": @"estWait",
             @"inQueue": @"inQueue",
             @"queueOpen": @"queueOpen",
             @"skillName": @"skillName",
             @"voiceCapacity": @"voiceCapacity",
             @"voiceReady": @"voiceReady"
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
