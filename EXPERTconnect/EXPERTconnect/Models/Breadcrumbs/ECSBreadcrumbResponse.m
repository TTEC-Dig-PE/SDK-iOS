//
//  ECSBreadcrumbsAction.m
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ECSBreadcrumbResponse.h"
#import "ECSActionTypeClassTransformer.h"

@implementation ECSBreadcrumbResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"actionDescription": @"actionDescription",
             @"actionDestination": @"actionDestination",
             @"actionSource": @"actionSource",
             @"actionType": @"actionType",
             @"actions": @"actions",
             @"creationTime": @"creationTime",
             @"gmtDateTime": @"gmtDateTime",
             @"actionId": @"actionId",
             @"journeyId": @"journeyId",
             @"sessionId": @"sessionId",
             @"tenantId": @"tenantId",
             @"userId": @"userId"
             };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"actions": [ECSActionTypeClassTransformer class]};
}


@end


