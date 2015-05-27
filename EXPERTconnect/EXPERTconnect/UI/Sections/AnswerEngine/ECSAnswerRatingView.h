//
//  ECSAnswerRatingView.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSAnswerEngineResponse.h"

@protocol ECSAnswerRatingDelegate <NSObject>

- (void)ratingSelected:(AnswerRating)rating;

@end

@interface ECSAnswerRatingView : UIView

@property (weak, nonatomic) id<ECSAnswerRatingDelegate> delegate;

@property (assign, nonatomic) AnswerRating currentRating;

@end
