//
//  ECSSMSActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSMSActionType.h"

@implementation ECSSMSActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeSMSString;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [dictionary addEntriesFromDictionary:@{
                                           @"agentID": @"agentId",
                                           @"agentSkill": @"agentSkill"
                                           }];
    return dictionary;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSSMSActionType *actionType = [super copyWithZone:zone];
    
    actionType.agentId = [self.agentId copyWithZone:zone];
    actionType.agentSkill = [self.agentSkill copyWithZone:zone];
    
    return actionType;
}

@end
