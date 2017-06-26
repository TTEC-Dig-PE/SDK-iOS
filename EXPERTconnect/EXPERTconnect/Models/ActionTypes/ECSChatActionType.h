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

// Subject content that will be visible to an associate (and reports)
@property (strong, nonatomic) NSString *subject;

// The source of the chat. Valid values: Web, Mobile, XMPP, SMS, Twitter, Facebook, Callback
@property (strong, nonatomic) NSString *sourceType;

// ‘chat’ or ‘voice’
@property (strong, nonatomic) NSString *mediaType;

// Location
@property (strong, nonatomic) NSString *location;


// Agent Survey after chat
@property (assign, nonatomic) BOOL shouldTakeSurvey;

@end
