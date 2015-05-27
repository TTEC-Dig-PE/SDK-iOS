//
//  ECSNavigationActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSNavigationActionType.h"

@implementation ECSNavigationActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeNavigationString;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{@"configuration.navigationContext": @"navigationContext"}];

    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSNavigationActionType *actionType = [super copyWithZone:zone];
    
    actionType.navigationContext = [self.navigationContext copyWithZone:zone];
    
    return actionType;
}

@end
