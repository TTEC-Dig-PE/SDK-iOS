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
 Response returnec when a journey is created.
 
 active = 0;
 chatCapacity = 4;
 chatReady = 4;
 description = "Mobile Chat Skill for Testing";
 estWait = 0;
 inQueue = 0;
 queueOpen = 1;
 skillName = "CE_Mobile_Chat";
 voiceCapacity = 1;
 voiceReady = 1;
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
