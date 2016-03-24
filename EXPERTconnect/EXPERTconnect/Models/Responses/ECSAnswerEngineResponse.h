//
//  ECSAnswerEngineResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

// Changed as per conversation on Mar 17, 2016 with Ken, Nainesh, and Mike
typedef NS_ENUM(NSInteger, AnswerRating)
{
    AnswerRatingUnknown = 0,
    AnswerRatingPositive = 2,
    AnswerRatingNegative = 1
};

@interface ECSAnswerEngineResponse : ECSJSONObject <ECSJSONSerializing, UIActivityItemSource>

@property (strong, nonatomic) NSString *question;

@property (strong, nonatomic) NSString *answerId;

@property (strong, nonatomic) NSString *answer;

@property (strong, nonatomic) NSString *inquiryId;

@property (strong, nonatomic) NSNumber *answersQuestion;

@property (strong, nonatomic) NSNumber *requestRating;

@property (strong, nonatomic) NSArray *actions;

@property (strong, nonatomic) NSString *answerContent;

@property (strong, nonatomic) NSArray *suggestedQuestions;

@property (assign, nonatomic) AnswerRating answerRating;

@property (readonly, nonatomic) NSString *shareText;

@end
