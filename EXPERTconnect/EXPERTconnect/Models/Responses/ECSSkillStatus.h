//
//  ECSSkillStatus.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"
//#import "ECSConversationLink.h"

/**
 Response returnec when a journey is created.
 */
@interface ECSSkillStatus : ECSJSONObject <ECSJSONSerializing>

// The last date the journey was modified.
@property (nonatomic) NSInteger *agentsLoggedOn;

// The date the journey expires
@property (nonatomic) NSInteger *open;

// ???
@property (strong, nonatomic) NSString *skillName;

// Self reference
@property (strong, nonatomic) NSString *selfLink;

@end
