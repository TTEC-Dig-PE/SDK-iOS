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
    
//    if(UIAccessibilityIsVoiceOverRunning()){
//        self.questionView.questionText = [NSString stringWithFormat:@"%@ (%@)", self.formItem.label, [self defaultCaptionText]];
//        self.captionLabel.isAccessibilityElement = NO;
//    } else {
        self.questionView.questionText = self.formItem.label;
//    }
    
    self.captionLabel.font = theme.captionFont;
    self.captionLabel.textColor = theme.secondaryTextColor;
    self.captionLabel.text = [self defaultCaptionText];
    
//    if(UIAccessibilityIsVoiceOverRunning()){
//        self.captionLabel.text = @"";
//    }
    
    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;
    
    int number_of_stars = 5;  // Always use 5-stars
    int value = [ratingItem.maxValue intValue];  // 5, 10, 100
    self.multiplier = value / number_of_stars;
    
    self.rateResponseStars.value = 2.5;
    if(value < 10) {
        self.rateResponseStars.value = 2;
    }

    float step = ((float)number_of_stars / (float)value);
    [self.rateResponseStars setBaseColor:theme.primaryBackgroundColor];
    [self.rateResponseStars setHighlightColor:theme.primaryColor];
    [self.rateResponseStars setStepInterval:step];
    [self.rateResponseStars setMarkFont:[UIFont systemFontOfSize:84.0f]];
    [self.rateResponseStars addTarget:self action:@selector(ratingChanged:) forControlEvents:UIControlEventValueChanged];
    
    CGRect frame =  self.view.bounds;
    [self.rateResponseStars setFrame:frame];
    
//MARK : Had to comment the code because of a conflict with AXRatingView and KWash's implementation of the AXRatingView; AXRatingView's star drawing does not scale very effectively, and causes a whole load of issues in this context. Recommend moving away from it, or using a native rating solution. As of now, the Ratings view has proper constraints, and will do for Demo 2.0
    
    
//    CGFloat width = [self.view bounds].size.width;
//    frame.origin.x = (width - frame.size.width) / 2;

}

- (IBAction)ratingChanged:(id)sender {

    ECSFormItemRating* ratingItem = (ECSFormItemRating*)self.formItem;

    ratingItem.formValue = [@((int)(self.rateResponseStars.value * self.multiplier)) stringValue];
    
    [self.delegate formItemViewController:self answerDidChange:nil forFormItem:self.formItem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
