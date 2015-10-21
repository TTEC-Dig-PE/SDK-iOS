//
//  ECSBreadcrumbsAction.m
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSBreadcrumbsAction.h"

static NSString* PROPERTY_ID             = @"id";
static NSString* PROPERTY_TENANTID       = @"tenantId";
static NSString* PROPERTY_JOURNEYID      = @"journeyId";
static NSString* PROPERTY_SESSIONID      = @"sessionId";
static NSString* PROPERTY_ACTIONTYPE     = @"actionType";
static NSString* PROPERTY_ACTIONDESC     = @"actionDescription";
static NSString* PROPERTY_ACTIONSOURCE   = @"actionSource";
static NSString* PROPERTY_ACTIONDEST     = @"actionDestination";
static NSString* PROPERTY_CREATIONTIME   = @"creationTime";


@implementation ECSBreadcrumbsAction

@synthesize properties;




- (id)init {
    
    if (self = [super init]) {
        
        properties = [NSMutableDictionary dictionary];
        
    }
    
    return self;
}


- (id)initWithDic : (NSDictionary *)dic {
    
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









@end


