//
//  ECSJSONObject.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSJSONObject.h"

@implementation ECSJSONObject

- (NSDictionary *)ECSJSONMapping
{
    return @{};
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{};
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
