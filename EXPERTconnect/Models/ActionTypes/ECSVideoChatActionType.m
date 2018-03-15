//
//  ECSChatActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSVideoChatActionType.h"

@implementation ECSVideoChatActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeVideoChatString;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSVideoChatActionType *actionType = [super copyWithZone:zone];
    
    actionType.cafexmode = [self.cafexmode copyWithZone:zone];
    actionType.cafextarget = [self.cafextarget copyWithZone:zone];

    return actionType;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.cafexmode": @"cafexmode",
                                        @"configuration.cafextarget": @"cafextarget"
                                        }];
    
    
    return mapping;
}

@end
