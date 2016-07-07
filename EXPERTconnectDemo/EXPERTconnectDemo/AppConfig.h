//
//  AppConfig.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 2/9/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EXPERTconnect/EXPERTConnect.h>
#import <CoreLocation/CoreLocation.h>
#import "ECDUserDefaultKeys.h"

@interface AppConfig : NSObject <ECSAuthenticationTokenDelegate>

@property (nonatomic, strong) NSString *organization;

+ (id)sharedAppConfig;
- (void) fetchEnvironmentJSON;
-(void) setupAuthenticationDelegate;
- (NSString *)getHostURL;
//- (NSString *)getClientID;
- (void)fetchAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion;
//- (void)fetchOldAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion;
-(void) startBreadcrumbSession;
-(void) getCustomizedThemeSettings; 
- (NSString *)getClientID;

@end
