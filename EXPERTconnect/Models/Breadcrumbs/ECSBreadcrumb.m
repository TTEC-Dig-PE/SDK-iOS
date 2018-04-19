//
//  ECSBreadcrumbsAction.m
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ECSBreadcrumb.h"

static NSString* PROPERTY_ID             = @"id";
static NSString* PROPERTY_USERID         = @"userId";
static NSString* PROPERTY_TENANTID       = @"tenantId";
static NSString* PROPERTY_JOURNEYID      = @"journeyId";
static NSString* PROPERTY_SESSIONID      = @"sessionId";
static NSString* PROPERTY_PUSHNOTIFICATIONID = @"pushNotificationId";
static NSString* PROPERTY_ACTIONTYPE     = @"actionType";
static NSString* PROPERTY_ACTIONDESC     = @"actionDescription";
static NSString* PROPERTY_ACTIONSOURCE   = @"actionSource";
static NSString* PROPERTY_ACTIONDEST     = @"actionDestination";
static NSString* PROPERTY_CREATIONTIME   = @"creationTime";

static NSString* PROPERTY_GEOLOCATION       = @"geoLocation";
static NSString* PROPERTY_LATITUDE          = @"latitude";
static NSString* PROPERTY_LONGITUDE         = @"longitude";
static NSString* PROPERTY_HORIZ_ACCURACY    = @"horizontalAccuracy";
static NSString* PROPERTY_VERT_ACCURACY     = @"verticalAccuracy";
static NSString* PROPERTY_SPEED             = @"speed";
static NSString* PROPERTY_COURSE            = @"course";
static NSString* PROPERTY_ALTITUDE          = @"altitude";
static NSString* PROPERTY_TIMESTAMP         = @"timestamp";
static NSString* PROPERTY_FLOOR             = @"floor";
static NSString* PROPERTY_DESCRIPTION       = @"description";

@implementation ECSBreadcrumb

@synthesize properties;

- (id)init {
    
    if (self = [super init]) {
        
        properties = [NSMutableDictionary dictionary];
        
    }
    
    return self;
}

- (id) initWithAction:(NSString *)theAction
          description:(NSString *)theDescription
               source:(NSString *)source
          destination:(NSString *)destination
{
    if (self = [super init]) {
        
        properties = [NSMutableDictionary dictionary];
        self.actionType = theAction;
        self.actionDescription = theDescription;
        self.actionSource = source;
        self.actionDestination = destination;
    }
    
    return self;
}

- (id) initWithDic : (NSDictionary *)dic {
    
    if (self = [super init]) {
        
        properties = [dic mutableCopy];
        
    }
    
    return self;
}

- (NSDictionary *)getProperties {
    
    return self.properties;
}

/* Action ID */
- (void)setActionId: (NSString *)actionId {
    [self.properties setObject:actionId forKey:PROPERTY_ID];
}
- (NSString *)actionId {
    return self.properties[PROPERTY_ID];
}

/* Tenant ID */
- (void)setTenantId: (NSString *)tenantId {
    [self.properties setObject:tenantId forKey:PROPERTY_TENANTID];
}
- (NSString *)tenantId {
    return self.properties[PROPERTY_TENANTID];
}

/* Journey ID */
- (void)setJourneyId: (NSString *)journeyId {
    [self.properties setObject:(journeyId ? journeyId : @"") forKey:PROPERTY_JOURNEYID];
}
- (NSString *)journeyId {
    return self.properties[PROPERTY_JOURNEYID];
}

/* User ID */
- (void)setUserId: (NSString *)userId {
    [self.properties setObject:(userId ? userId : @"") forKey:PROPERTY_USERID];
}
- (NSString *)userId {
    return self.properties[PROPERTY_USERID];
}

/* Session ID */
- (void)setSessionId: (NSString *)sessionId {
    [self.properties setObject:(sessionId ? sessionId : @"") forKey:PROPERTY_SESSIONID];
}

- (NSString *)sessionId {
    return self.properties[PROPERTY_SESSIONID];
}

/* Push Notification ID */
- (void)setPushNotificationId:(NSString *)pushNotificationId {
    [self.properties setObject:(pushNotificationId ? pushNotificationId : @"") forKey:PROPERTY_PUSHNOTIFICATIONID];
}

- (NSString *)pushNotificationId {
    return self.properties[PROPERTY_PUSHNOTIFICATIONID];
}

/* Action Type */
- (void)setActionType: (NSString *)actionType {
    [self.properties setObject:actionType forKey:PROPERTY_ACTIONTYPE];
}
- (NSString *)actionType {
    return self.properties[PROPERTY_ACTIONTYPE];
}

/* Action Description */
- (void)setActionDescription: (NSString *)actionDescription {
    [self.properties setObject:actionDescription forKey:PROPERTY_ACTIONDESC];
}
- (NSString *)actionDescription {
    return self.properties[PROPERTY_ACTIONDESC];
}

/* Action Source */
- (void)setActionSource: (NSString *)actionSource {
    [self.properties setObject:actionSource forKey:PROPERTY_ACTIONSOURCE];
}
- (NSString *)actionSource{
    return self.properties[PROPERTY_ACTIONSOURCE];
}

/* Action Destination */
- (void)setActionDestination: (NSString *)actionDestination {
    [self.properties setObject:actionDestination forKey:PROPERTY_ACTIONDEST];
}
- (NSString *)actionDestination{
    return self.properties[PROPERTY_ACTIONDEST];
}

/* Creation Time */
- (void)setCreationTime: (NSString *)creationTime {
    [self.properties setObject:creationTime forKey:PROPERTY_CREATIONTIME];
}
- (NSString *)creationTime{
    return self.properties[PROPERTY_CREATIONTIME];
}

/* Geo Location */
- (void)setGeoLocation: (CLLocation *)geolocation {
    
    //self.geoLocation = [geolocation copy];
    
    NSMutableDictionary *geoProps = [[NSMutableDictionary alloc] init];
    
    if (geolocation.coordinate.latitude) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.coordinate.latitude ]
                     forKey:PROPERTY_LATITUDE];
    }
    
    if (geolocation.coordinate.longitude) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.coordinate.longitude ]
                     forKey:PROPERTY_LONGITUDE];
    }
    
    if (geolocation.horizontalAccuracy) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.horizontalAccuracy ]
                     forKey:PROPERTY_HORIZ_ACCURACY];
    }
        
    if (geolocation.verticalAccuracy) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.verticalAccuracy ]
                     forKey:PROPERTY_VERT_ACCURACY];
    }
        
    if (geolocation.speed) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.speed ]
                     forKey:PROPERTY_SPEED];
    }
        
    if (geolocation.course) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.course ]
                     forKey:PROPERTY_COURSE];
    }
    
    if (geolocation.altitude) {
        [geoProps setObject:[[NSNumber alloc] initWithDouble:geolocation.altitude]
                     forKey:PROPERTY_ALTITUDE];
    }
    
    [self.properties setObject:geoProps forKey:PROPERTY_GEOLOCATION];
    
    //[self.properties setObject:geolocation.timestamp forKey:PROPERTY_TIMESTAMP];
    //[self.properties setObject:geolocation.floor forKey:PROPERTY_FLOOR];
    //[self.properties setObject:geolocation.description forKey:PROPERTY_DESCRIPTION];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@; type=%@, desc=%@, source=%@, dest=%@", [super description], self.actionType, self.actionDescription, self.actionSource, self.actionDestination];
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSBreadcrumb *newBC = [[[self class] allocWithZone:zone] init];
    
    newBC.properties = [[NSMutableDictionary alloc] initWithDictionary:self.properties copyItems:YES];
    
    if(self.actionId) newBC.actionId = [self.actionId copyWithZone:zone];
    if(self.tenantId) newBC.tenantId = [self.tenantId copyWithZone:zone];
    if(self.journeyId) newBC.journeyId = [self.journeyId copyWithZone:zone];
    if(self.userId) newBC.userId = [self.userId copyWithZone:zone];
    if(self.sessionId) newBC.sessionId = [self.sessionId copyWithZone:zone];
    if(self.actionType) newBC.actionType = [self.actionType copyWithZone:zone];
    if(self.actionDescription) newBC.actionDescription = [self.actionDescription copyWithZone:zone];
    if(self.actionSource) newBC.actionSource = [self.actionSource copyWithZone:zone];
    if(self.actionDestination) newBC.actionDestination = [self.actionDestination copyWithZone:zone];
    if(self.creationTime) newBC.creationTime = [self.creationTime copyWithZone:zone];
    if(self.geoLocation) newBC.geoLocation = [self.geoLocation copyWithZone:zone];
    
    return newBC;
}


@end


