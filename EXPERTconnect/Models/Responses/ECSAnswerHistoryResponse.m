//
//  ECSAnswerHistoryResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerHistoryResponse.h"

@implementation ECSAnswerHistoryResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{@"date": @"date",
             @"answerId": @"id",
             @"request": @"request",
             @"response": @"response",
             @"title": @"title",
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSAnswerHistoryResponse *response = [[[self class] allocWithZone:zone] init];
    
    response.date = [self.date copyWithZone:zone];
    response.answerId = [self.answerId copyWithZone:zone];
    response.request = [self.request copyWithZone:zone];
    response.response = [self.response copyWithZone:zone];
    response.title = [self.title copyWithZone:zone];
    
    return response;
}

- (NSString *)shareText
{
    return [NSString stringWithFormat:@"<html><body><h1>%@</h1><br>%@</body></html>", self.request, self.response];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return self.shareText;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    return self.request;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return self.shareText;
}


@end
