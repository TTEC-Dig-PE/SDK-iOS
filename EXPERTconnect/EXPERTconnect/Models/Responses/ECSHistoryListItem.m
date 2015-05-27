//
//  ECSHistoryListItem.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSHistoryListItem.h"

@implementation ECSHistoryListItem

static NSDateFormatter *dateFormatter = nil;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    return @{
                @"active": @"active",
                @"date": @"dateString",
                @"details": @"details",
                @"journeyId": @"journeyId",
                @"title": @"title"
             };
}

- (NSDate*)date
{
    if (!_date)
    {
        _date = [dateFormatter dateFromString:self.dateString];
    }
    
    return _date;
}

@end
