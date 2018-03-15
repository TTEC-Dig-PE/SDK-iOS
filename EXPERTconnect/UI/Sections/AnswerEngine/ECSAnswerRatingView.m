//
//  ECSAnswerRatingView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerRatingView.h"

#import "ECSDynamicLabel.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"

@interface ECSAnswerRatingView()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *label;
@property (weak, nonatomic) IBOutlet UIButton *thumbsUpButton;
@property (weak, nonatomic) IBOutlet UIButton *thumbsDownButton;
@end

@implementation ECSAnswerRatingView

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
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.backgroundColor = theme.secondaryBackgroundColor;
    self.label.textColor = theme.primaryTextColor;
    
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    [self.thumbsUpButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_up"] forState:UIControlStateNormal];
    [self.thumbsDownButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_down"] forState:UIControlStateNormal];
    UIImage *thumbsUpTint = [[imageCache imageForPath:@"ecs_ic_thumb_up_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *thumbsDownTint = [[imageCache imageForPath:@"ecs_ic_thumb_down_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.label.text = ECSLocalizedString(ECSLocalizeWasThisResponseHelpful, @"Was this response helpful");

    self.thumbsUpButton.tintColor = theme.primaryColor;
    self.thumbsDownButton.tintColor = theme.primaryColor;
    [self.thumbsUpButton setImage:thumbsUpTint forState:UIControlStateSelected];
    [self.thumbsDownButton setImage:thumbsDownTint forState:UIControlStateSelected];
}

- (void)setCurrentRating:(AnswerRating)currentRating
{
    _currentRating = currentRating;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    switch (currentRating) {
        case AnswerRatingUnknown:
            self.thumbsUpButton.selected = NO;
            self.thumbsDownButton.selected = NO;
            break;
        case AnswerRatingNegative:
            self.thumbsDownButton.tintColor = theme.buttonColor;
            self.thumbsUpButton.selected = NO;
            self.thumbsDownButton.selected = YES;
            break;
        case AnswerRatingPositive:
            self.thumbsUpButton.tintColor = theme.buttonColor;
            self.thumbsUpButton.selected = YES;
            self.thumbsDownButton.selected = NO;
            break;
            
        default:
            break;
    }
}

- (IBAction)thumbsUpTapped:(id)sender
{
    self.thumbsUpButton.selected = YES;
    self.thumbsDownButton.selected = NO;
    
    if (self.delegate)
    {
        [self.delegate ratingSelected:AnswerRatingPositive];
    }
}

- (IBAction)thumbsDownTapped:(id)sender
{
    self.thumbsDownButton.selected = YES;
    self.thumbsUpButton.selected = NO;
    
    if (self.delegate)
    {
        [self.delegate ratingSelected:AnswerRatingNegative];
    }
}
@end
