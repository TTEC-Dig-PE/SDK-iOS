//
//  ECSConversationLink.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSConversationLink.h"

@implementation ECSConversationLink

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"rel": @"linkType",
             @"href": @"URL",
             };
}

@end
