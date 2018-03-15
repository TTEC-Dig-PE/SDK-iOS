//
//  ECSJourneyAttachResponse.h
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 6/16/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSJourneyAttachResponse : ECSJSONObject <ECSJSONSerializing>

/*
 "id": "journey_189bdcb6-4d20-49b1-a232-1439817351e8_mktwebextc",
 "tenantId": "mktwebextc",
 "name": "Postman Initiated Journey",
 "userId": "gwen@email.com",
 "creationTime": 1466086504303,
 "context": null,
 "pushNotificationId": "d20b8f2dd892f1eddac98600740445dbadcdde568cda47ad624701924e14b5a4",
 "deviceType": "ios",
 "contextId": "3cee0ec6-5d47-4680-8036-f1a55a4c2881",
 "data": {},
 "lastActivityTime": 1466086520665
 }
 */
@property (strong, nonatomic) NSString *journeyId;
@property (strong, nonatomic) NSString *tenantId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *creationTime;
@property (strong, nonatomic) NSString *context;
@property (strong, nonatomic) NSString *pushNotificationId;
@property (strong, nonatomic) NSString *deviceType;
@property (strong, nonatomic) NSString *contextId;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSString *lastActivityTime;

@end
