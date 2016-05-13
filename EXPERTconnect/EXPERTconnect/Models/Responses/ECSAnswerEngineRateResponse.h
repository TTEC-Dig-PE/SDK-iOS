//
//  ECSAnswerEngineRateResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSAnswerEngineRateResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSArray *actions;
@property (nonatomic) int constrainedRating;
@property (nonatomic) int requestRating;
@end
