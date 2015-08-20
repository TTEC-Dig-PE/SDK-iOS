//
//  ECSBinaryImageView.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/19/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSBinaryImageView.h"

#import "ECSDynamicLabel.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"

@interface ECSBinaryImageView()

@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;

@end


@implementation ECSBinaryImageView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.backgroundColor = theme.secondaryBackgroundColor;
    
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    self.insetLeft = 40;
    self.insetTop = 20;
    self.spacingBetweenImages = 60;
 
    self.leftButton = [UIButton new];
    self.rightButton = [UIButton new];
    
    self.fillLeftColor = theme.primaryColor;
    self.fillRightColor = theme.primaryColor;
    
    self.leftImage = [imageCache imageForPath:@"ecs_ic_thumb_up"];
    self.rightImage = [imageCache imageForPath:@"ecs_ic_thumb_down"];
    self.leftImageSelected = [imageCache imageForPath:@"ecs_ic_thumb_up_active"];
    self.rightImageSelected = [imageCache imageForPath:@"ecs_ic_thumb_down_active"];

    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    
    [self.leftButton sizeToFit];
    [self.rightButton sizeToFit];
    
    [self.leftButton addTarget:self
                        action:@selector(leftButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self
                        action:@selector(rightButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    
    _currentRating = BinaryRatingUnknown;
    
    [self refresh];
}

- (void)refresh {

    UIImage *leftButtonTint = [self.leftImageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *rightButtonTint = [self.rightImageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.leftButton.tintColor = self.fillLeftColor;
    self.rightButton.tintColor = self.fillRightColor;
    
    [self.leftButton setImage:self.leftImage forState:UIControlStateNormal];
    [self.rightButton setImage:self.rightImage forState:UIControlStateNormal];
    [self.leftButton setImage:leftButtonTint forState:UIControlStateSelected];
    [self.rightButton setImage:rightButtonTint forState:UIControlStateSelected];
    
    self.leftButton.center = CGPointMake(self.insetLeft, self.insetTop);
    self.rightButton.center = CGPointMake(self.insetLeft + self.spacingBetweenImages, self.insetTop);
}

- (void)setCurrentRating:(BinaryRating)currentRating
{
    _currentRating = currentRating;
    
    switch (currentRating) {
        case BinaryRatingUnknown:
            [self deselectButtons];
            break;
        case BinaryRatingNegative:
            [self selectNegativeButton];
            break;
        case BinaryRatingPositive:
            [self selectPositiveButton];
            break;
            
        default:
            break;
    }
}

- (void)leftButtonTapped:(id)sender
{
    [self selectPositiveButton];
}

- (void)rightButtonTapped:(id)sender
{
    [self selectNegativeButton];
}


- (void)deselectButtons
{
    _currentRating = BinaryRatingUnknown;
    self.leftButton.selected = NO;
    self.rightButton.selected = NO;
    
    if (self.delegate)
    {
        [self.delegate ratingSelected:BinaryRatingUnknown];
    }
}

- (void)selectPositiveButton
{
    _currentRating = BinaryRatingPositive;
    self.leftButton.selected = YES;
    self.rightButton.selected = NO;
    
    if (self.delegate)
    {
        [self.delegate ratingSelected:BinaryRatingPositive];
    }
}

- (void)selectNegativeButton
{
    _currentRating = BinaryRatingNegative;
    self.rightButton.selected = YES;
    self.leftButton.selected = NO;
    
    if (self.delegate)
    {
        [self.delegate ratingSelected:BinaryRatingNegative];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
