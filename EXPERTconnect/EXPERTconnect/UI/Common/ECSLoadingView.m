//
//  ECSLoadingView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSLoadingView.h"

#import "ECSCachingImageView.h"

@interface ECSLoadingView ()

@property (strong, nonatomic) ECSCachingImageView *activityIndicator;
@end

@implementation ECSLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.activityIndicator = [[ECSCachingImageView alloc] initWithImagePath:@"ecs_activity_indicator"];
    self.activityIndicator.image = [self.activityIndicator.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.activityIndicator];

    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0f
                                                                constant:0.0f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0f
                                                                constant:0.0f];
    
    [self addConstraints:@[centerX, centerY]];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;
    
    if (self.activityIndicator.layer.animationKeys.count == 0)
    {
        self.alpha = 0.0f;
    }
}

- (void)startAnimating
{
    self.alpha = 1.0f;
    
    [UIView animateKeyframesWithDuration:1.0f
                                   delay:0.0f
                                 options:(UIViewKeyframeAnimationOptionCalculationModeLinear |
                                          UIViewAnimationOptionCurveLinear |
                                          UIViewKeyframeAnimationOptionRepeat)
                              animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.25f
                                      animations:^{
                                          [self.activityIndicator.layer setTransform:CATransform3DMakeRotation(M_PI_2, 0, 0, 1)];
                                      }];
        [UIView addKeyframeWithRelativeStartTime:0.25f relativeDuration:0.25f
                                      animations:^{
                                          [self.activityIndicator.layer setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
                                      }];
        
        [UIView addKeyframeWithRelativeStartTime:0.25f relativeDuration:0.5f
                                      animations:^{
                                          [self.activityIndicator.layer setTransform:CATransform3DMakeRotation(M_PI_2 * 3, 0, 0, 1)];
                                      }];
        [UIView addKeyframeWithRelativeStartTime:0.25f relativeDuration:0.75f
                                      animations:^{
                                          [self.activityIndicator.layer setTransform:CATransform3DMakeRotation(0, 0, 0, 1)];
                                      }];
    } completion:^(BOOL finished) {
    
    }];
}

- (void)stopAnimating
{
    if (self.hidesWhenStopped)
    {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.activityIndicator.layer removeAllAnimations];
        }];
    }
    else
    {
        [self.activityIndicator.layer removeAllAnimations];
    }
}
@end
