//
//  ECSTextFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSTextFormItemViewController.h"

#import "ECSDynamicLabel.h"
#import "ECSFormQuestionView.h"
#import "ECSFormItemText.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSTextFormItemViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView           *scrollView;
@property (weak, nonatomic) IBOutlet UIView                 *contentView;
@property (weak, nonatomic) IBOutlet UITextField            *textField;
@property (weak, nonatomic) IBOutlet ECSFormQuestionView    *questionView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel        *captionLabel;

@end

@implementation ECSTextFormItemViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    if(UIAccessibilityIsVoiceOverRunning()){
//        self.questionView.questionText = [NSString stringWithFormat:@"%@ (%@)", self.formItem.label, [self defaultCaptionText]];
//    } else {
        self.questionView.questionText = self.formItem.label;
//    }
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    ECSFormItemText* textItem = (ECSFormItemText*)self.formItem;
    self.textField.tintColor = theme.primaryColor;
    self.textField.textColor = theme.primaryTextColor;
    
    if (textItem.hint && [textItem.hint isKindOfClass:[NSString class]]) {
        
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textItem.hint
                                                                               attributes:@{NSForegroundColorAttributeName: theme.secondaryTextColor}];
    }
    
    self.textField.secureTextEntry = [textItem.secure boolValue];
    self.textField.text = textItem.formValue;
    
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    self.captionLabel.font = theme.captionFont;
    self.captionLabel.textColor = theme.secondaryTextColor;
    self.captionLabel.text = [self defaultCaptionText];
    
//    if(UIAccessibilityIsVoiceOverRunning()){
//        self.captionLabel.text = @"";
//    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.view becomeFirstResponder];
    
}

- (void)textFieldDidChange:(id)sender {
    
    ((ECSFormItemText*)self.formItem).formValue = self.textField.text;
    
    [self.delegate formItemViewController:self
                          answerDidChange:self.textField.text
                              forFormItem:self.formItem];
}

- (IBAction)viewTapped:(id)sender {
    
    [self.textField resignFirstResponder];
    
}

@end

