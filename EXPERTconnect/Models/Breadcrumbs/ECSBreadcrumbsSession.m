
//
//  ECSBreadcrumbsSession.m
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSBreadcrumbsSession.h"


static NSString* PROPERTY_TENANTID       = @"tenantId";
static NSString* PROPERTY_JOURNEYID      = @"journeyId";
static NSString* PROPERTY_SESSIONID      = @"sessionId";
static NSString* PROPERTY_PLATFORM       = @"platform";
static NSString* PROPERTY_MODEL          = @"model";
static NSString* PROPERTY_DEVICEID       = @"deviceId";
static NSString* PROPERTY_PHONENUMBER    = @"phoneNumber";
static NSString* PROPERTY_OSVERSION      = @"osVersion";
static NSString* PROPERTY_IPADDRESS      = @"ipAddress";
static NSString* PROPERTY_GEOLOCATION    = @"geoLocation";
static NSString* PROPERTY_BROWSERTYPE    = @"browserType";
static NSString* PROPERTY_BROWSERVERSION = @"browserVersion";
static NSString* PROPERTY_RESOLUTION     = @"resolution";

@implementation ECSBreadcrumbsSession

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



- (NSDictionary *)getProperties {
    
    return self.properties;
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


- (void)setPlatform: (NSString *)platform {
    
    [self.properties setObject:platform forKey:PROPERTY_PLATFORM];
    
}

- (NSString *)getPlatform {
    
    return self.properties[PROPERTY_PLATFORM];
}


- (void)setModel: (NSString *)model{
    
    [self.properties setObject:model forKey:PROPERTY_MODEL];
    
}

- (NSString *)getModel {
    
    return self.properties[PROPERTY_MODEL];
}

- (void)setDeviceId: (NSString *)deviceId{
    if (!deviceId) {
        deviceId = @"";
    }
    [self.properties setObject:deviceId forKey:PROPERTY_DEVICEID];
    
}

- (NSString *)getDeviceId {
    
    return self.properties[PROPERTY_DEVICEID];
}


- (void)setPhonenumber: (NSString *)phonenumber{
    
    [self.properties setObject:phonenumber forKey:PROPERTY_PHONENUMBER];
    
}

- (NSString *)getPhonenumber {
    
    return self.properties[PROPERTY_PHONENUMBER];
}

- (void)setOSVersion: (NSString *)osVersion{
    
    [self.properties setObject:osVersion forKey:PROPERTY_OSVERSION];
    
}

- (NSString *)getOSVersion {
    
    return self.properties[PROPERTY_OSVERSION];
}


- (void)setIPAddress: (NSString *)ipAddress{
    
    [self.properties setObject:ipAddress forKey:PROPERTY_IPADDRESS];
    
}

- (NSString *)getIPAddress {
    
    return self.properties[PROPERTY_IPADDRESS];
}

- (void)setGEOLocation: (NSString *)geoLocation{
    
    [self.properties setObject:geoLocation forKey:PROPERTY_GEOLOCATION];
    
}

- (NSString *)getGEOLocation {
    
    return self.properties[PROPERTY_GEOLOCATION];
}

- (void)setBrowserType: (NSString *)browserType{
    
    [self.properties setObject:browserType forKey:PROPERTY_BROWSERTYPE];
    
}

- (NSString *)getBrowserType {
    
    return self.properties[PROPERTY_BROWSERTYPE];
}

- (void)setBrowserVersion: (NSString *)browserVersion{
    
    [self.properties setObject:browserVersion forKey:PROPERTY_BROWSERVERSION];
    
}

- (NSString *)getBrowserVersion {
    
    return self.properties[PROPERTY_BROWSERVERSION];
}

- (void)setResolution: (NSString *)resolution{
    
    [self.properties setObject:resolution forKey:PROPERTY_RESOLUTION];
    
}

- (NSString *)getResolution {
    
    return self.properties[PROPERTY_RESOLUTION];
}



@end

