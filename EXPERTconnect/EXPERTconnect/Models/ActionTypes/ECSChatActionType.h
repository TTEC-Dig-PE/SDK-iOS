//
//  ECSChatActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

// #import <EXPERTconnect/EXPERTconnect.h> // creates a circular reference with subclasses
#import "ECSActionType.h"

@interface ECSChatActionType : ECSActionType <NSCopying>

// Agent ID for chat
@property (strong, nonatomic) NSString *agentId;

// Agent Skill for chat
@property (strong, nonatomic) NSString *agentSkill;

@end
