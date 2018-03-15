//
//  ECSCallbackSetupResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSCallbackSetupResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSString *callID;
@property (strong, nonatomic) NSNumber *estimatedWaitTime;

@end
