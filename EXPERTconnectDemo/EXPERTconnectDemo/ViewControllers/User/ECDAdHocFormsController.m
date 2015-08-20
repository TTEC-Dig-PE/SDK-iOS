//
//  ECDAdHocFormsController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/14/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocFormsController.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

@interface ECDAdHocFormsController ()

@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UISlider *agentRatingSlider;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet ECSBinaryImageView *binaryView;


@end

@implementation ECDAdHocFormsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeFields];
}

-(void) initializeFields {
    self.commentsTextView.text = @"";
    
    // Set the tintColor so we can see the cursor clear;
    //
    self.emailAddressField.tintColor = UIColor.blueColor;
    self.commentsTextView.tintColor = UIColor.blueColor;
    
    // Round button corners
    CALayer *btnLayer = [self.submitButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    self.agentRatingSlider.minimumValue = 0.0;
    self.agentRatingSlider.maximumValue = 10.0;
    self.agentRatingSlider.value = (self.agentRatingSlider.maximumValue - self.agentRatingSlider.minimumValue) / 2.0f;
    
    [self.agentRatingSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.binaryView.delegate = self;
    self.binaryView.fillLeftColor = [UIColor greenColor];
    self.binaryView.fillRightColor = [UIColor redColor];
    self.binaryView.insetLeft = 60;
    self.binaryView.spacingBetweenImages = 30;
    self.binaryView.currentRating = BinaryRatingPositive;
    
    [self.binaryView refresh];
    
    [self.submitButton addTarget:self
                          action:@selector(submitRatingButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
}
     
- (void)submitRatingButtonTapped:(UIButton*)button
{
    NSMutableArray *formData = [NSMutableArray new];
    
    ECSForm *form = [ECSForm new];
    ECSFormItem *fI1 = [ECSFormItem new];
    ECSFormItem *fI2 = [ECSFormItem new];
    ECSFormItem *fI3 = [ECSFormItem new];
    
    [formData addObject:fI1];
    [formData addObject:fI2];
    [formData addObject:fI3];
    
    form.name = @"adhoc_sdk_demo";     // matches name in Forms Designer!!!
    form.formData = formData;
    
    fI1.label = @"Email Address";
    fI2.label = @"Agent Rating";
    fI2.label = @"Comments";
    
    fI1.formValue = self.emailAddressField.text;
    fI2.formValue = [NSString stringWithFormat:@"%d", (int)self.agentRatingSlider.value];
    fI3.formValue = self.commentsTextView.text;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager submitForm:form completion:^(ECSFormSubmitResponse *response, NSError *error) {
        NSLog(@"Form was Submited:");
        [weakSelf showAlert:@"Thank you!" withMessage:@"Form was Submitted!"];
    }];
}

- (void)sliderValueChanged:(id)sender
{
    if( self.agentRatingSlider.value > self.agentRatingSlider.minimumValue &&
        self.agentRatingSlider.value < self.agentRatingSlider.maximumValue &&
        self.binaryView.currentRating != BinaryRatingUnknown )  {
        
        self.binaryView.currentRating = BinaryRatingUnknown;
    }
}

- (void)ratingSelected:(BinaryRating)rating {
    if(rating == BinaryRatingNegative) {
        self.agentRatingSlider.value = self.agentRatingSlider.minimumValue;
    } else if (rating == BinaryRatingPositive)  {
        self.agentRatingSlider.value = self.agentRatingSlider.maximumValue;
    } else {
        self.agentRatingSlider.value = (self.agentRatingSlider.maximumValue - self.agentRatingSlider.minimumValue) / 2.0f;;
    }
    // [self showAlert:@"Rating" withMessage:@"Thank you!"];
}

- (void) showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"Ok Button")
                                          otherButtonTitles:nil];
    [alert show];
}
@end