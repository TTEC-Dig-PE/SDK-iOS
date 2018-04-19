//
//  ECSCallbackActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSCallbackActionType : ECSActionType <NSCopying>

// Agent ID for chat
@property (strong, nonatomic) NSString *agentId;

// Agent Skill for chat
@property (strong, nonatomic) NSString *agentSkill;

// Subject content that will be visible to an associate (and reports)
@property (strong, nonatomic) NSString *subject;

// The chat priority
@property (assign, nonatomic) int priority;

@end
