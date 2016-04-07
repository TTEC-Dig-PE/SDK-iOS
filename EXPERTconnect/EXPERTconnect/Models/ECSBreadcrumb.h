//
//  ECSBreadcrumbsAction.h
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface ECSBreadcrumb: NSObject <NSCopying>

@property (nonatomic) NSMutableDictionary *properties;

@property (strong, nonatomic) NSString *actionId;
@property (strong, nonatomic) NSString *tenantId;
@property (strong, nonatomic) NSString *journeyId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *actionType;
@property (strong, nonatomic) NSString *actionDescription;
@property (strong, nonatomic) NSString *actionSource;
@property (strong, nonatomic) NSString *actionDestination;
@property (strong, nonatomic) NSString *creationTime;
@property (strong, nonatomic) CLLocation *geoLocation;

- (id)initWithDic : (NSDictionary *)dic;

- (id) initWithAction:(NSString *)theAction
          description:(NSString *)theDescription
               source:(NSString *)source
          destination:(NSString *)destination;

- (NSMutableDictionary *)getProperties;

- (void)setActionId: (NSString *)actionId;
- (NSString *)actionId;

- (void)setTenantId: (NSString *)tenantId;
- (NSString *)tenantId;

- (void)setJourneyId: (NSString *)journeyId;
- (NSString *)journeyId;

- (void)setUserId: (NSString *)userId;
- (NSString *)userId;

- (void)setSessionId: (NSString *)sessionId;
- (NSString *)sessionId;

- (void)setActionType: (NSString *)actionType;
- (NSString *)actionType;

- (void) setActionDescription: (NSString *)actionDescription;
- (NSString *)actionDescription;

- (void)setActionSource: (NSString *)actionSource;
- (NSString *)actionSource;

- (void)setActionDestination: (NSString *)actionDestination;
- (NSString *)actionDestination;

- (void)setCreationTime: (NSString *)creationTime;
- (NSString *)creationTime;

- (void)setGeoLocation: (CLLocation *)geolocation;

@end
