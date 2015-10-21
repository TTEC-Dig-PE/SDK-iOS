//
//  ECSBreadcrumbsDevice.h
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#ifndef ECSBreadcrumbsDevice_h
#define ECSBreadcrumbsDevice_h



@interface ECSBreadcrumbsDevice: NSObject

@property (nonatomic) NSMutableDictionary *properties;


- (id)initWithDic : (NSDictionary *)dic;


- (NSMutableDictionary *)getProperties;

- (void)setTenantId: (NSString *)tenantId;
- (NSString *)getTenantId;

- (void)setJourneyId: (NSString *)journeyId;
- (NSString *)getJourneyId;

- (void)setSessionId: (NSString *)sessionId;
- (NSString *)getSessionId;

- (void)setPlatform: (NSString *)platform;
- (NSString *)getPlatform;

- (void)setModel: (NSString *)model;
- (NSString *)getModel;

- (void)setDeviceId: (NSString *)deviceId;
- (NSString *)getDeviceId;

- (void)setPhonenumber: (NSString *)phonenumber;
- (NSString *)getPhonenumber;

- (void)setOSVersion: (NSString *)osVersion;
- (NSString *)getOSVersion;

- (void)setIPAddress: (NSString *)ipAddress;
- (NSString *)getIPAddress;

- (void)setGEOLocation: (NSString *)geoLocation;
- (NSString *)getGEOLocation;

- (void)setBrowserType: (NSString *)browserType;
- (NSString *)getBrowserType;

- (void)setBrowserVersion: (NSString *)browserVersion;
- (NSString *)getBrowserVersion ;

- (void)setResolution: (NSString *)resolution;
- (NSString *)getResolution;

@end



#endif /* ECSBreadcrumbsDevice_h */
