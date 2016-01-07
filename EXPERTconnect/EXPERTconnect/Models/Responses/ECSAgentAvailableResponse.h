//
//  ECSAgentAvailableResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 Response returnec when a journey is created.
 */
@interface ECSAgentAvailableResponse : ECSJSONObject <ECSJSONSerializing>

// The last date the journey was modified.
@property (strong, nonatomic) NSArray *skills;

// Self reference
@property (strong, nonatomic) NSString *selfLink;

@end
