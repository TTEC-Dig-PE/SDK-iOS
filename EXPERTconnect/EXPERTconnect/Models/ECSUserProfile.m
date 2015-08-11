//
//  ECSUserProfile.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSUserProfile.h"

@implementation ECSUserProfile

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"userID": @"userID",
             @"username": @"username",
             @"firstName": @"firstName",
             @"lastName": @"lastName",
             @"address": @"address",
             @"city": @"city",
             @"state": @"state",
             @"postalCode": @"postalCode",
             @"country": @"country",
             @"homePhone": @"homePhone",
             @"mobilePhone": @"mobilePHone",
             @"alternativeEmail": @"alternativeEmail",
             @"customData": @"customData"
             };
}

/*
- (NSDictionary*)ECSJSONTransformMapping
{
    return @{
             @"action": [ECSActionTypeClassTransformer class],
             };
    return @{
            @"customData": [ECSHorizonExtendedAttributesClassTransformer class],
            };
}
*/

@end
