//
//  ECSCallbackActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCallbackActionType.h"

@implementation ECSCallbackActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeCallbackString;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [dictionary addEntriesFromDictionary:@{
                                          @"configuration.agentId": @"agentId",
                                          @"configuration.agentSkill": @"agentSkill"
                                          }];
    return dictionary;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSCallbackActionType *actionType = [super copyWithZone:zone];
    
    actionType.agentId = [self.agentId copyWithZone:zone];
    actionType.agentSkill = [self.agentSkill copyWithZone:zone];
    
    return actionType;
}


@end
