//
//  ECSSliderFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSliderFormItemViewController.h"

#import "ECSFormItemSlider.h"
#import "ECSDynamicLabel.h"
#import "ECSFormQuestionView.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSSliderFormItemViewController ()

@property (weak, nonatomic) IBOutlet ECSFormQuestionView    *questionView;
@property (weak, nonatomic) IBOutlet UISlider               *slider;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel        *minValueLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel        *maxValueLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel        *captionLabel;

@end

@implementation ECSSliderFormItemViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self themeViews];

    self.questionView.questionText = self.formItem.label;
    
    ECSFormItemSlider* sliderItem = (ECSFormItemSlider*)self.formItem;
    self.slider.minimumValue = [sliderItem.minValue floatValue];
    self.slider.maximumValue = [sliderItem.maxValue floatValue];
    
    [self.slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    
    self.minValueLabel.text = sliderItem.minLabel;
    self.maxValueLabel.text = sliderItem.maxLabel;
    
    if(sliderItem.formValue) {
        
        self.slider.value = [sliderItem.formValue floatValue];
        
    } else {
        
        // Default to the middle
        self.slider.value = ([sliderItem.minValue floatValue] + [sliderItem.maxValue floatValue]) / 2.0f;
    }
    
    self.captionLabel.text = [self defaultCaptionText];
}

- (void)themeViews {
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    [self.slider setTintColor:theme.primaryColor];
    
    self.minValueLabel.font         = theme.captionFont;
    self.minValueLabel.textColor    = theme.secondaryTextColor;
    self.maxValueLabel.font         = theme.captionFont;
    self.maxValueLabel.textColor    = theme.secondaryTextColor;
    
    self.captionLabel.font          = theme.captionFont;
    self.captionLabel.textColor     = theme.secondaryTextColor;
}

- (void)sliderValueChanged:(id)sender {
    
    ECSFormItemSlider* sliderItem = (ECSFormItemSlider*)self.formItem;
    
    sliderItem.formValue = [@(self.slider.value) stringValue];
    
    [self.delegate formItemViewController:self
                          answerDidChange:nil
                              forFormItem:self.formItem];
}

@end
