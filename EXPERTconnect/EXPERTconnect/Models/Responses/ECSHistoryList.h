//
//  ECSHistoryList.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSHistoryList : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSArray *journeys;

@end
