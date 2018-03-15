//
//  ECSUserProfile.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@class ECSActionType;

@interface ECSUserProfile : ECSJSONObject <ECSJSONSerializing>

//@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *homePhone;
@property (strong, nonatomic) NSString *mobilePhone;
@property (strong, nonatomic) NSString *alternativeEmail;
@property (strong, nonatomic) NSDictionary *customData;
// fullName

@end
