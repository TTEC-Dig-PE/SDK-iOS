//
//  ECSBreadcrumbsAction.m
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ECSBreadcrumbsAction.h"

static NSString* PROPERTY_ID             = @"id";
static NSString* PROPERTY_USERID         = @"userId";
static NSString* PROPERTY_TENANTID       = @"tenantId";
static NSString* PROPERTY_JOURNEYID      = @"journeyId";
static NSString* PROPERTY_SESSIONID      = @"sessionId";
static NSString* PROPERTY_ACTIONTYPE     = @"actionType";
static NSString* PROPERTY_ACTIONDESC     = @"actionDescription";
static NSString* PROPERTY_ACTIONSOURCE   = @"actionSource";
static NSString* PROPERTY_ACTIONDEST     = @"actionDestination";
static NSString* PROPERTY_CREATIONTIME   = @"creationTime";

static NSString* PROPERTY_LATITUDE          = @"latitude";
static NSString* PROPERTY_LONGITUDE         = @"longitude";
static NSString* PROPERTY_HORIZ_ACCURACY    = @"horizontalAccuracy";
static NSString* PROPERTY_VERT_ACCURACY     = @"verticalAccuracy";
static NSString* PROPERTY_SPEED             = @"speed";
static NSString* PROPERTY_COURSE            = @"course";
static NSString* PROPERTY_TIMESTAMP         = @"timestamp";
static NSString* PROPERTY_FLOOR             = @"floor";
static NSString* PROPERTY_DESCRIPTION       = @"description";

@implementation ECSBreadcrumbsAction

@synthesize properties;

- (id)init {
    
    if (self = [super init]) {
        
        properties = [NSMutableDictionary dictionary];
        
    }
    
    return self;
}


- (id) initWithDic : (NSDictionary *)dic {
    
    if (self = [super init]) {
        
        properties = [dic mutableCopy];
        
    }
    
    return self;
}



- (NSMutableDictionary *)getProperties {
    
    return self.properties;
}


- (void)setId: (NSString *)actionId {
    
    [self.properties setObject:actionId forKey:PROPERTY_TENANTID];
    
}


- (NSString *)getId {
    
    return self.properties[PROPERTY_ID];
}

- (void)setTenantId: (NSString *)tenantId {
    
    [self.properties setObject:tenantId forKey:PROPERTY_TENANTID];
    
}


- (NSString *)getTenantId {
    
    return self.properties[PROPERTY_TENANTID];
}


- (void)setJourneyId: (NSString *)journeyId {
    
    [self.properties setObject:journeyId forKey:PROPERTY_JOURNEYID];
    
}

- (NSString *)getJourneyId {
    
    return self.properties[PROPERTY_JOURNEYID];
}

- (void)setUserId: (NSString *)userId {
    [self.properties setObject:userId forKey:PROPERTY_USERID];
}
- (NSString *)getUserId {
    return self.properties[PROPERTY_USERID];
}

- (void)setSessionId: (NSString *)sessionId {
    
    [self.properties setObject:sessionId forKey:PROPERTY_SESSIONID];
    
}

- (NSString *)getSessionId {
    
    return self.properties[PROPERTY_SESSIONID];
}

- (void)setActionType: (NSString *)actionType {
    
    [self.properties setObject:actionType forKey:PROPERTY_ACTIONTYPE];
    
}

- (NSString *)getActionType {
    
    return self.properties[PROPERTY_ACTIONTYPE];
}


- (void)setActionDescription: (NSString *)actionDescription {
    
    [self.properties setObject:actionDescription forKey:PROPERTY_ACTIONDESC];
    
}

- (NSString *)getActionDescription {
    
    return self.properties[PROPERTY_ACTIONDESC];
}


- (void)setActionSource: (NSString *)actionSource {
    
    [self.properties setObject:actionSource forKey:PROPERTY_ACTIONSOURCE];
    
}

- (NSString *)getActionSource{
    
    return self.properties[PROPERTY_ACTIONSOURCE];
}


- (void)setActionDestination: (NSString *)actionDestination {
    
    [self.properties setObject:actionDestination forKey:PROPERTY_ACTIONDEST];
    
}

- (NSString *)getActionDestination{
    
    return self.properties[PROPERTY_ACTIONDEST];
}


- (void)setCreationTime: (NSString *)creationTime {
    
    [self.properties setObject:creationTime forKey:PROPERTY_CREATIONTIME];
    
}

- (NSString *)getCreationTime{
    
    return self.properties[PROPERTY_CREATIONTIME];
}

- (void)setGeoLocation: (CLLocation *)geolocation {
    
    [self.properties setObject:[[NSNumber alloc] initWithDouble:geolocation.coordinate.latitude ]
                        forKey:PROPERTY_LATITUDE];
    
    [self.properties setObject:[[NSNumber alloc] initWithDouble:geolocation.coordinate.longitude ]
                        forKey:PROPERTY_LONGITUDE];
    
    [self.properties setObject:[[NSNumber alloc] initWithDouble:geolocation.horizontalAccuracy ]
                        forKey:PROPERTY_HORIZ_ACCURACY];
    
    [self.properties setObject:[[NSNumber alloc] initWithDouble:geolocation.verticalAccuracy ]
                        forKey:PROPERTY_VERT_ACCURACY];
    
    [self.properties setObject:[[NSNumber alloc] initWithDouble:geolocation.speed ]
                        forKey:PROPERTY_SPEED];
    
    [self.properties setObject:[[NSNumber alloc] initWithDouble:geolocation.course ]
                        forKey:PROPERTY_COURSE];
    
    [self.properties setObject:geolocation.timestamp forKey:PROPERTY_TIMESTAMP];
    
    [self.properties setObject:geolocation.floor forKey:PROPERTY_FLOOR];
    
    [self.properties setObject:geolocation.description forKey:PROPERTY_DESCRIPTION];
}

@end


