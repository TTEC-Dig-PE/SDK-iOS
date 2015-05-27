//
//  ECSHistoryListItem.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSHistoryListItem : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSNumber *active;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDictionary *details;
@property (strong, nonatomic) NSString *journeyId;
@property (strong, nonatomic) NSString *title;

@end

