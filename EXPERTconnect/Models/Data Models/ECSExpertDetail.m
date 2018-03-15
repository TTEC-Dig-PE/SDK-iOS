//
//  ECSExpertDetail.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSExpertDetail.h"

//#import "ECSActionTypeClassTransformer.h"

@implementation ECSExpertDetail

/*
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
 */

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"chatEnabled": @"chatEnabled",
             @"chatLimit": @"chatLimit",
             @"chatsToRejectVoice": @"chatsToRejectVoice",
             @"clientMode": @"clientMode",
             @"expertID": @"expertID",
             @"firstName": @"firstName",
             @"fullName": @"fullName",
             @"geoLocationTimestamp": @"geoLocationTimestamp",
             @"lastName": @"lastName",
             @"pictureURL": @"pictureURL",
             @"readyForChat": @"readyForChat",
             @"readyForVoice": @"readyForVoice",
             @"readyTimestamp": @"readyTimestamp",
             @"skills": @"skills",
             @"status": @"status",
             @"statusTimestamp": @"statusTimestamp"
             };
}

/*- (NSDictionary*)ECSJSONTransformMapping
{
    return @{
             @"experts": [ECSActionTypeClassTransformer class],
             };
}*/

@end
