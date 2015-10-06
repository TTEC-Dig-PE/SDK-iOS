//
//  PMPeriod.m
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "ECSPeriod.h"
#import "NSDate+Helpers.h"

@implementation ECSPeriod

@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

+ (id) periodWithStartDate:(NSDate *) startDate endDate:(NSDate *) endDate
{
    ECSPeriod *result = [[ECSPeriod alloc] init];
    
    result.startDate = startDate;
    result.endDate = endDate;
    
    return result;
}

+ (ECSPeriod*) oneDayPeriodWithDate:(NSDate *) date
{
    ECSPeriod *result = [[ECSPeriod alloc] init];
    
    result.startDate = [date dateWithoutTime];
    result.endDate = result.startDate;

    return result;
}

- (BOOL) isEqual:(id) object
{
    if (![object isKindOfClass:[ECSPeriod class]])
    {
        return NO;
    }
    
    ECSPeriod *period = object;
    return [self.startDate isEqualToDate:period.startDate] 
            && [self.endDate isEqualToDate:period.endDate];
}

- (NSInteger) lengthInDays
{
    return [self.endDate daysSinceDate:self.startDate];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"startDate = %@; endDate = %@", _startDate, _endDate];
}

- (ECSPeriod *) normalizedPeriod
{
    ECSPeriod *result = [[ECSPeriod alloc] init];
    
    if ([_startDate compare:_endDate] == NSOrderedAscending)
    {
        result.startDate = _startDate;
        result.endDate = _endDate;
    }
    else
    {
        result.startDate = _endDate;
        result.endDate = _startDate;
    }
    
    return result;
}

- (BOOL) containsDate:(NSDate *) date
{
    ECSPeriod *normalizedPeriod = [self normalizedPeriod];
    
    if (([normalizedPeriod.startDate compare:date] != NSOrderedDescending)
        && ([normalizedPeriod.endDate compare:date] != NSOrderedAscending))
    {
        return YES;
    }
    
    return NO;
}

- (id) copyWithZone:(NSZone *) zone
{
    ECSPeriod *copiedPeriod = [[ECSPeriod alloc] init];
    copiedPeriod.startDate = [_startDate copyWithZone: zone];
    copiedPeriod.endDate = [_endDate copyWithZone: zone];
    
    return copiedPeriod;
}

@end
