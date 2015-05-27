//
//  ECSHistoryResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSHistoryResponse.h"

#import "ECSAnswerHistoryResponse.h"

@implementation ECSHistoryResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{@"responses": @"responses"};
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"responses": [ECSAnswerHistoryResponse class]};
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSHistoryResponse *response = [[[self class] allocWithZone:zone] init];
    response.responses = [[NSArray alloc] initWithArray:self.responses copyItems:YES];
    
    return response;
}

@end
