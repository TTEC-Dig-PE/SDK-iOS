//
//  ECSWebActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWebActionType.h"

@implementation ECSWebActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeWebString;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{@"configuration.url": @"url"}];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSWebActionType *actionType = [super copyWithZone:zone];
    
    actionType.url = [self.url copyWithZone:zone];
    
    return actionType;
}

@end
