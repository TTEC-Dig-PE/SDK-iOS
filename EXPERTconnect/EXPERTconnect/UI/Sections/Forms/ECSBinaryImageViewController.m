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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.view.backgroundColor = theme.secondaryBackgroundColor;
    
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    ECSFormItemRadio *binaryFormItem = (ECSFormItemRadio *)self.formItem;
    
    //Right-align the button image
    NSDictionary *attributes = @{NSFontAttributeName: self.rightButton.titleLabel.font};
    
    CGSize size = [[self.rightButton titleForState:UIControlStateNormal] sizeWithAttributes:attributes];
    
    [self.rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -size.width)];
    [self.rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, self.rightButton.imageView.image.size.width + 5)];
    
    // Option 0
    [self.leftButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_up"] forState:UIControlStateNormal];
    [self.leftButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_up_active"] forState:UIControlStateSelected];
    
    // Option 1
    [self.rightButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_down"] forState:UIControlStateNormal];
    [self.rightButton setImage:[imageCache imageForPath:@"ecs_ic_thumb_down_active"] forState:UIControlStateSelected];
    
    [self.captionLabel setText:self.defaultCaptionText];
    
    self.captionLabel.font = theme.captionFont;
    self.captionLabel.textColor = theme.secondaryTextColor;
    
    [self.questionLabel setText:self.formItem.label];
    [self.questionLabel setAccessibilityLabel:self.formItem.label];
    self.questionLabel.isAccessibilityElement = YES;
    
    if( binaryFormItem && binaryFormItem.options.count > 1 ) {
        
        self.leftButton.isAccessibilityElement = YES;
        [self.leftButton setAccessibilityLabel:binaryFormItem.options[0]];
        
        self.rightButton.isAccessibilityElement = YES;
        [self.rightButton setAccessibilityLabel:binaryFormItem.options[1]];
        
        // mas - 24-May-2017 - This should re-select the user's answer if they move past this question, and click "previous" to come back to it. PAAS-1988
        if( [self.formItem.formValue isEqualToString:binaryFormItem.options[0]] ) {
            
            [self leftButtonPressed:self];
            
        } else if ( [self.formItem.formValue isEqualToString:binaryFormItem.options[1]]) {
            
            [self rightButtonPressed:self];
            
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.view becomeFirstResponder];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self.view layoutIfNeeded];
}

- (IBAction)leftButtonPressed:(id)sender {
    
    // The positive button (thumbs up)
    ECSFormItemRadio *myForm = (ECSFormItemRadio *)self.formItem;
    
    if( myForm.options && myForm.options.count > 0) {
        
        myForm.formValue = myForm.options[0]; // Index 0 = thumbs up ("good")
        
    } else {
        
        myForm.formValue = @"1";
        
    }
    
    [self.delegate formItemViewController:self
                          answerDidChange:nil
                              forFormItem:self.formItem];
    
    [self.leftButton setSelected:YES];
    //    [self.leftButton setEnabled:NO];
    
    [self.rightButton setSelected:NO];
    //    [self.rightButton setEnabled:YES];
}

- (IBAction)rightButtonPressed:(id)sender {
    
    // The negative button (thumbs down)
    ECSFormItemRadio *myForm = (ECSFormItemRadio *)self.formItem;
    
    if( myForm.options && myForm.options.count > 1) {
        
        myForm.formValue = myForm.options[1]; // Index 1 = thumbs down ("bad")
        
    } else {
        
        myForm.formValue = @"0";
        
    }
    
    [self.delegate formItemViewController:self
                          answerDidChange:nil
                              forFormItem:self.formItem];
    
    [self.leftButton setSelected:NO];
    //    [self.leftButton setEnabled:YES];
    
    [self.rightButton setSelected:YES];
    //    [self.rightButton setEnabled:NO];
}

@end

