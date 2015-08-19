//
//  ECSBinaryImageView.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/19/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTConnect/ECSBinaryRating.h>

@protocol ECSBinaryRatingDelegate <NSObject>

- (void)ratingSelected:(BinaryRating)rating;

@end


@interface ECSBinaryImageView : UIControl

- (void)refresh;
- (void)deselectButtons;
- (void)selectPositiveButton;
- (void)selectNegativeButton;

@property (weak, nonatomic) id<ECSBinaryRatingDelegate> delegate;

@property (nonatomic, retain) UIColor* fillLeftColor;
@property (nonatomic, retain) UIColor* fillRightColor;
@property (nonatomic, retain) UIImage* leftImage;
@property (nonatomic, retain) UIImage* rightImage;
@property (nonatomic, retain) UIImage* leftImageSelected;
@property (nonatomic, retain) UIImage* rightImageSelected;
@property (assign, nonatomic) NSUInteger insetTop;
@property (assign, nonatomic) NSUInteger insetLeft;
@property (assign, nonatomic) NSUInteger spacingBetweenImages;
@property (assign, nonatomic) BinaryRating currentRating;

@end
