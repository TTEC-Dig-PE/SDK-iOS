//
//  ECSAxRatingFormItemViewController.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/27/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAxRatingFormItemViewController.h"
#import "ECSFormItemRating.h"
#import "ECSRatingView.h"

#import "ECSDynamicLabel.h"
#import "ECSFormQuestionView.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSFormItemRating.h"

@interface ECSAxRatingFormItemViewController ()

@property int multiplier;
@property (weak, nonatomic) IBOutlet ECSFormQuestionView *questionView;
@property (weak, nonatomic) IBOutlet ECSRatingView *rateResponseStars;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *captionLabel;

@end

@implementation ECSAxRatingFormItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.questionView.questionText = self.formItem.label;
    
    self.captionLabel.font = theme.captionFont;
    self.captionLabel.textColor = theme.secondaryTextColor;
    self.captionLabel.text = [self defaultCaptionText];
    
    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;
    
    int number_of_stars = 5;  // Always use 5-stars
    int value = [ratingItem.maxValue intValue];  // 5, 10, 100
    self.multiplier = value / number_of_stars;
    
    self.rateResponseStars.value = 2.5;
    if(value < 10) {
        self.rateResponseStars.value = 2;
    }
    
    [self.rateResponseStars setBaseColor:theme.primaryBackgroundColor];
    [self.rateResponseStars setHighlightColor:theme.primaryColor];
    [self.rateResponseStars setStepInterval:(number_of_stars / value)];
    [self.rateResponseStars setMarkFont:[UIFont systemFontOfSize:84.0f]];
    [self.rateResponseStars addTarget:self action:@selector(ratingChanged:) forControlEvents:UIControlEventValueChanged];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = [self.rateResponseStars frame];
    frame.origin.x = (width - frame.size.width) / 2;
    [self.rateResponseStars setFrame:frame];
}

- (IBAction)ratingChanged:(id)sender {

    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;

    ratingItem.formValue = [@((int)self.rateResponseStars.value * self.multiplier) stringValue];
    
    [self.delegate formItemViewController:self answerDidChange:nil forFormItem:self.formItem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
