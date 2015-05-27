//
//  ECSHistoryList.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSHistoryList.h"

#import "ECSHistoryListItem.h"

@implementation ECSHistoryList

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"journeys": @"journeys"
             };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{
             @"journeys": [ECSHistoryListItem class]
             };
}

@end
