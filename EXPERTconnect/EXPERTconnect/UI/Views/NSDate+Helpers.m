//
//  NSDate+Helpers.m
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/14/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate (Helpers)

- (NSDate *)dateWithoutTime
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitYear
                                                          | NSCalendarUnitMonth
                                                          | NSCalendarUnitDay )
                                                fromDate:self];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *) dateByAddingDays:(NSInteger) days months:(NSInteger) months years:(NSInteger) years
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.day = days;
	dateComponents.month = months;
	dateComponents.year = years;
	
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                         toDate:self
                                                        options:0];    
}

- (NSDate *) dateByAddingDays:(NSInteger) days
{
    return [self dateByAddingDays:days months:0 years:0];
}

- (NSDate *) dateByAddingMonths:(NSInteger) months
{
    return [self dateByAddingDays:0 months:months years:0];
}

- (NSDate *) dateByAddingYears:(NSInteger) years
{
    return [self dateByAddingDays:0 months:0 years:years];
}

- (NSDate *) monthStartDate 
{
    NSDate *monthStartDate = nil;
	[[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth
                                    startDate:&monthStartDate 
                                     interval:NULL
                                      forDate:self];

	return monthStartDate;
}

- (NSDate *) midnightDate
{
    NSDate *midnightDate = nil;
	[[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                    startDate:&midnightDate
                                     interval:NULL
                                      forDate:self];
    
	return midnightDate;
}

- (NSUInteger) numberOfDaysInMonth
{
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay 
                                              inUnit:NSCalendarUnitMonth
                                             forDate:self].length;
}

- (NSUInteger) weekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:self];
    
    return [weekdayComponents weekday];
}

- (NSString *) dateStringWithFormat:(NSString *) format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
		
	return [formatter stringFromDate:self];
}

- (NSInteger) daysSinceDate:(NSDate *) date
{
    return round([self timeIntervalSinceDate:date] / (60 * 60 * 24));
}

- (BOOL) isBefore:(NSDate *) date
{
	return [self timeIntervalSinceDate:date] < 0;
}

- (BOOL) isAfter:(NSDate *) date
{
	return [self timeIntervalSinceDate:date] > 0;
}

- (BOOL) isCurrentMonth:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* comp1 = [calendar components:NSCalendarUnitMonth fromDate:self];
    NSDateComponents* comp2 = [calendar components:NSCalendarUnitMonth fromDate:date];
    
    return ([comp1 month] == [comp2 month]);
}

@end
