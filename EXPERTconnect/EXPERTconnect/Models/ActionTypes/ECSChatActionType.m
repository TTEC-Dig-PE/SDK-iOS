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
        
        // The old default values.
        self.subject = @"help";
        self.location = @"mobile";
        self.sourceType = @"Mobile";
        self.mediaType = @"Chat";

//        self.priority = kECSChatPriorityUseServerDefault;
        self.priority = kECSChatPriorityLow; // TODO: Change to kECSChatPriorityUseServerDefault when PAAS-2323 is finished.;

    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSChatActionType *actionType = [super copyWithZone:zone];
    
    actionType.agentId = [self.agentId copyWithZone:zone];
    actionType.agentSkill = [self.agentSkill copyWithZone:zone];
    actionType.subject = [self.subject copyWithZone:zone];
    actionType.location = [self.location copyWithZone:zone];
    actionType.sourceType = [self.sourceType copyWithZone:zone];
    actionType.mediaType = [self.mediaType copyWithZone:zone];
    
    actionType.shouldTakeSurvey = self.shouldTakeSurvey;
    actionType.priority = self.priority;
    
    return actionType;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.agentId": @"agentId",
                                        @"configuration.agentSkill": @"agentSkill",
                                        @"configuration.subject": @"subject",
                                        @"configuration.location": @"location",
                                        @"configuration.sourceType": @"sourceType",
                                        @"configuration.mediaType": @"mediaType"
                                        }];
    
    
    return mapping;
}

@end

