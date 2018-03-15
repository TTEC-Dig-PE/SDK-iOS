//
//  ECSSkillDetail.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 @desc This object contains the details on a specific call or chat skill
 - active - Whether this skill queue is active or not.
 - chatCapacity - Maximum capacity of agents this skill can contain.
 - chatReady - Number of agents who are ready to accept chats.
 - description - Text description of this skill
 - estWait - The estimated wait time to get connected (seconds)
 - inQueue - Is this particular user in the queue already?
 - queueOpen - Is the queue open or closed?
 - skillName - Name of the skill
 - voiceCapacity - Maximum capacity of agents who can take voice calls.
 - voiceReady - Current number of agents ready to accept calls.
 */
@interface ECSSkillDetail : ECSJSONObject <ECSJSONSerializing>

// The last date the journey was modified.
//@property (strong, nonatomic) NSArray *skills;

// Self reference
//@property (strong, nonatomic) NSString *selfLink;

@property (nonatomic) int active;
@property (nonatomic) int chatCapacity;
@property (nonatomic) int chatReady;
@property (strong, nonatomic) NSString *skillDescription;
@property (nonatomic) int estWait;
@property (nonatomic) int inQueue;
@property (nonatomic) int queueOpen;
@property (strong, nonatomic) NSString *skillName;
@property (nonatomic) int voiceCapacity;
@property (nonatomic) int voiceReady;

@end
