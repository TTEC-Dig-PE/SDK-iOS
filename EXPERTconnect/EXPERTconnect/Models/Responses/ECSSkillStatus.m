//
//  ECSSkillStatus.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSkillStatus.h"

@implementation ECSSkillStatus

- (NSDictionary *)ECSJSONMapping
{
    return @{@"agentsLoggedOn": @"agentsLoggedOn",
             @"open": @"open",
             @"skillName": @"skillName",
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
