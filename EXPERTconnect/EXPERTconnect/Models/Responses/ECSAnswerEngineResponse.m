//
//  ECSAnswerEngineResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerEngineResponse.h"

#import "ECSActionTypeClassTransformer.h"

@implementation ECSAnswerEngineResponse

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.question = @"";
        self.answer = @"";
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
   return @{
            @"answerID": @"answerId",
            @"answer": @"answer",
            @"inquiryID": @"inquiryId",
            @"answersQuestion": @"answersQuestion",
            @"requestRating": @"requestRating",
            @"actions": @"actions",
            @"answerContent": @"answerContent",
            @"suggestedQuestions": @"suggestedQuestions"
            };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"actions": [ECSActionTypeClassTransformer class]};
}

- (NSString *)shareText
{
    return [NSString stringWithFormat:@"<html><body><h1>%@</h1><br>%@</body></html>", self.question, self.answer];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return self.shareText;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    return self.question;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return self.shareText;
}

@end
