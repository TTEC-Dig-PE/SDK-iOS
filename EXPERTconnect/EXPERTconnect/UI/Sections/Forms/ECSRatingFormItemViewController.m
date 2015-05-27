//
//  ECSRatingFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSRatingFormItemViewController.h"

#import "ECSDynamicLabel.h"
#import "ECSFormQuestionView.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSFormItemRating.h"

@interface ECSRatingFormItemViewController ()

@property (weak, nonatomic) IBOutlet ECSFormQuestionView *questionView;
@property (weak, nonatomic) IBOutlet UIView *starContainerView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *captionLabel;

@property (nonatomic, strong) NSMutableArray* answerButtons;

@end

@implementation ECSRatingFormItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.questionView.questionText = self.formItem.label;
    
    self.captionLabel.font = theme.captionFont;
    self.captionLabel.textColor = theme.secondaryTextColor;
    self.captionLabel.text = [self defaultCaptionText];
    
    [self createRatingButtons];
    
    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;
    if(ratingItem.formValue)
    {
        [self setRating:[ratingItem.formValue integerValue]];
    }
}

- (void)createRatingButtons
{
    UIView* internalContainer = [UIView new];
    internalContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.starContainerView addSubview:internalContainer];
    [self.starContainerView addConstraint:[NSLayoutConstraint constraintWithItem:internalContainer
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.starContainerView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0.0]];
    [self.starContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[container]-(15)-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{ @"container": internalContainer} ]];
    
    ECSImageCache* imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    UIImage* emptyStarImage = [[imageCache imageForPath:@"ecs_input_star_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* fullStarImage = [[imageCache imageForPath:@"ecs_input_star_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;
    self.answerButtons = [NSMutableArray new];
    int numRatingButtons = [ratingItem.maxValue intValue];
    
    
    for(int i = 0; i < numRatingButtons; ++i)
    {
        UIButton* button = [[UIButton alloc] init];
        [button setTintColor:theme.primaryColor];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:emptyStarImage forState:UIControlStateNormal];
        [button setImage:fullStarImage forState:UIControlStateHighlighted|UIControlStateSelected];
        [button setImage:fullStarImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(ratingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(ratingButtonDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(ratingButtonCancel:) forControlEvents:UIControlEventTouchUpOutside];
        button.tag = i + 1;
        
        [self.answerButtons addObject:button];
        [internalContainer addSubview:button];
        if(i == 0)
        {
            [internalContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:internalContainer
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1.0 constant:0]];
        }
        else
        {
            [internalContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.answerButtons[i - 1]
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0 constant:5]];
        }
        if(i == numRatingButtons - 1)
        {
            [internalContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:internalContainer
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0 constant:0.0]];
        }
        
        [internalContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"button": button}]];
    }
}

- (void)ratingButtonPressed:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    [self setRating:tag];
}

- (void)ratingButtonDown:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    for(NSInteger i = 0; i < self.answerButtons.count; ++i)
    {
        UIButton* button = self.answerButtons[i];
        [button setSelected:i < tag];
    }
}

- (void)ratingButtonCancel:(UIButton*)sender
{
    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;
    [self setRating:[ratingItem.formValue integerValue]];
}

- (void)setRating:(NSInteger)rating
{
    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;
    for(NSInteger i = 0; i < self.answerButtons.count; ++i)
    {
        UIButton* button = self.answerButtons[i];
        [button setSelected:i < rating];
    }
           
    ratingItem.formValue = [@(rating) stringValue];
    
    [self.delegate formItemViewController:self answerDidChange:nil forFormItem:self.formItem];
}

@end
