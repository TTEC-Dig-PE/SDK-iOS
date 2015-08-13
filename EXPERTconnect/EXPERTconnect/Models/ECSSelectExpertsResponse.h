//
//  ECSSelectExpertsResponse.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@class ECSActionType;

@interface ECSSelectExpertsResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) ECSActionType *action;

@end
