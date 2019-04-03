//
//  ECSBreadcrumbsAction.h
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"


@interface ECSBreadcrumbResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSString *actionDescription;
@property (strong, nonatomic) NSString *actionDestination;
@property (strong, nonatomic) NSString *actionSource;
@property (strong, nonatomic) NSString *actionType;
@property (strong, nonatomic) NSArray *actions;
@property (strong, nonatomic) NSString *creationTime;
@property (strong, nonatomic) NSString *gmtDateTime;
@property (strong, nonatomic) NSString *actionId;
@property (strong, nonatomic) NSString *journeyId;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *tenantId;
@property (strong, nonatomic) NSString *userId;

@end
