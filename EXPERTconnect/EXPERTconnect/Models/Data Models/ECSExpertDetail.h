//
//  ECSExpertDetail.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

//@class ECSActionType;

@interface ECSExpertDetail : ECSJSONObject <ECSJSONSerializing>

@property (nonatomic) bool chatEnabled;
@property (nonatomic) int chatLimit;
@property (nonatomic) int chatsToRejectVoice;
@property (strong, nonatomic) NSString *clientMode;
@property (strong, nonatomic) NSString *expertID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *fullName;
@property (nonatomic) int geoLocationTimestamp;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *pictureURL;
@property (nonatomic) bool readyForChat;
@property (nonatomic) bool readyForVoice;
@property (nonatomic) double readyTimestamp;
@property (strong, nonatomic) NSArray *skills;
@property (strong, nonatomic) NSString *status;
@property (nonatomic) double statusTimestamp;
/*
 Array of objects that look like: 
 
 {
 chatEnabled = 0;
 chatLimit = 4;
 chatsToRejectVoice = 0;
 clientMode = Clientless;
 expertID = "mktwebextc.agent1";
 firstName = Sam;
 fullName = "Sam Mouski";
 geoLocationTimestamp = 0;
 lastName = Mouski;
 pictureURL = "http://dce1.humanify.com/assets/img/mktwebextc/user_image/mktwebextc.agent1/mktwebextc.agent1.jpg";
 readyForChat = 0;
 readyForVoice = 1;
 readyTimestamp = 1458843884886;
 skills =     (
 {
 proficiency = 5;
 skillName = Accounting;
 weight = 5;
 },
 {
 proficiency = 5;
 skillName = Billing;
 weight = 5;
 },
 {
 proficiency = 5;
 skillName = "Bronze Service";
 weight = 5;
 },
 {
 proficiency = 5;
 skillName = "Calls for mktwebextc.agent1";
 weight = 5;
 },
 {
 proficiency = 5;
 skillName = Careers;
 weight = 5;
 },
 {
 proficiency = 5;
 skillName = "Customer Service";
 weight = 5;
 }
 );
 status = Available;
 statusTimestamp = 1458265051874;
 }

 */

@end
