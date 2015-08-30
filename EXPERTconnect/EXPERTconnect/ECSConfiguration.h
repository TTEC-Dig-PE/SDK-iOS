//
//  ECSConfiguration.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ECSConfiguration specifies the configuration that is to be used by the SDK.  Many of these
 parameters are provided by Humanify.
 */
@interface ECSConfiguration : NSObject

// The host your EXPERTconnect SDK connects to.
@property (strong, nonatomic) NSString *host;

// The name of your application
@property (strong, nonatomic) NSString *appName;

// The current version number of your application
@property (strong, nonatomic) NSString *appVersion;

// The Humanify provided application ID
@property (strong, nonatomic) NSString *appId;

// Client ID for the Humanify API
@property (strong, nonatomic) NSString *clientID;

// Client Secret for the Humanify API
@property (strong, nonatomic) NSString *clientSecret;

// Default navigation context for the default landing
@property (strong, nonatomic) NSString *defaultNavigationContext;

// The default display name for the navigation context.
@property (strong, nonatomic) NSString *defaultNavigationDisplayName;

// Default answer engine context for the Answer Engine.
@property (strong, nonatomic) NSString *defaultAnswerEngineContext;

// The default form name for survey.
@property (strong, nonatomic) NSString *defaultSurveyFormName;

@end
