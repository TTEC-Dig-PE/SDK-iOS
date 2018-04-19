//
//  ECSAnswerEngineTopQuestionsResponse.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/13/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSAnswerEngineTopQuestionsResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSArray *questions;

@end
