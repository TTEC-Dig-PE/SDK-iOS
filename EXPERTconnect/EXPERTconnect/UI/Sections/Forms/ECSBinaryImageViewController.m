//
//  ECSBinaryImageViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSBinaryImageViewController.h"

#import "UIView+ECSNibLoading.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSImageCache.h"
#import "ECSFormItemRadio.h"
#import "ECSFormQuestionView.h"
#import "ECSDynamicLabel.h"
#import "ECSRadioTableViewCell.h"

@interface ECSBinaryImageViewController ()

@end

@implementation ECSBinaryImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.view.backgroundColor = theme.secondaryBackgroundColor;
    
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    //Right-align the button image
    NSDictionary *attributes = @{NSFontAttributeName: self.rightButton.titleLabel.font};
    CGSize size = [[self.rightButton titleForState:UIControlStateNormal] sizeWithAttributes:attributes];
    [self.rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -size.width)];
    [self.rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, self.rightButton.imageView.image.size.width + 5)];
    
    
    [self.leftButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_up"] forState:UIControlStateNormal];
    [self.leftButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_up_active"] forState:UIControlStateDisabled];
    
    [self.rightButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_down"] forState:UIControlStateNormal];
    [self.rightButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_down_active"] forState:UIControlStateDisabled];
    
    [self.captionLabel setText:self.defaultCaptionText];
    self.captionLabel.font = theme.captionFont;
    self.captionLabel.textColor = theme.secondaryTextColor;
    
    [self.questionLabel setText:self.formItem.label];
    
    /*self.insetLeft = 40;
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
    */
    //[self refresh];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view layoutIfNeeded];
}

- (IBAction)leftButtonPressed:(id)sender {
    // The positive button (thumbs up)
    ECSFormItemRadio *myForm = (ECSFormItemRadio *)self.formItem;
    myForm.formValue = myForm.options[0]; // Index 0 = thumbs up ("good")
    
    [self.delegate formItemViewController:self answerDidChange:nil forFormItem:self.formItem];
    [self.leftButton setEnabled:NO];
    [self.rightButton setEnabled:YES];
}
- (IBAction)rightButtonPressed:(id)sender {
    // The negative button (thumbs down)
    ECSFormItemRadio *myForm = (ECSFormItemRadio *)self.formItem;
    myForm.formValue = myForm.options[1]; // Index 1 = thumbs down ("bad")
    
    [self.delegate formItemViewController:self answerDidChange:nil forFormItem:self.formItem];
    [self.leftButton setEnabled:YES];
    [self.rightButton setEnabled:NO]; 
}

@end
