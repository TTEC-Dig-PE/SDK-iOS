//
//  ECSSelectExpertsResponse.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

//@class ECSActionType;

@interface ECSSelectExpertsResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSArray *experts;
/*
 Array of objects that look like: 
 
 agentId = "mktwebextc.agent1";
 agentSkill = "Calls for mktwebextc.agent1";
 firstName = "Sam Mouski";
 fullName = "Sam Mouski";
 interests = ();
 lastName = Mouski;
 pictureURL = "http://dce1.humanify.com/assets/img/mktwebextc/user_image/mktwebextc.agent1/mktwebextc.agent1.jpg";
 readyForChat = 0;
 readyForVoice = 1;
 */

@end
