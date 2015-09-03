//
//  ECSChatActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatActionType.h"

@implementation ECSChatActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeChatString;
        _shouldTakeSurvey = YES;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSChatActionType *actionType = [super copyWithZone:zone];
    
    actionType.agentId = [self.agentId copyWithZone:zone];
    actionType.agentSkill = [self.agentSkill copyWithZone:zone];
    actionType.shouldTakeSurvey = self.shouldTakeSurvey;
    
    return actionType;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.agentId": @"agentId",
                                        @"configuration.agentSkill": @"agentSkill"
                                        }];
    
    
    return mapping;
}

@end
