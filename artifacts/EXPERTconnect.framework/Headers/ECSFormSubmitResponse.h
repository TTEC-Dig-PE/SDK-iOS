//
//  ECSFormSubmitResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@class ECSActionType;

@interface ECSFormSubmitResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) ECSActionType *action;
@property (strong, nonatomic) NSString *identityToken;
@property (strong, nonatomic) NSNumber *profileUpdated;
@property (strong, nonatomic) NSNumber *submitted;

@end
