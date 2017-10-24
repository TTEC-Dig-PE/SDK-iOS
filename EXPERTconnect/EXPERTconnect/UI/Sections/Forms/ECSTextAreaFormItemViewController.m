//
//  ECSTextAreaFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSTextAreaFormItemViewController.h"

#import "ECSDynamicLabel.h"
#import "ECSFormQuestionView.h"
#import "ECSPlaceholderTextView.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSFormItemTextArea.h"

@interface ECSTextAreaFormItemViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView                     *contentView;
@property (weak, nonatomic) IBOutlet ECSFormQuestionView        *questionView;
@property (weak, nonatomic) IBOutlet ECSPlaceholderTextView     *answerTextArea;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel            *captionLabel;

@end

@implementation ECSTextAreaFormItemViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    ECSFormItemTextArea* textItem = (ECSFormItemTextArea*)self.formItem;
    
    self.questionView.questionText          = textItem.label;
    
    self.answerTextArea.placeholder         = textItem.hint;
    self.answerTextArea.text                = textItem.formValue;
    self.answerTextArea.textColor           = theme.primaryTextColor;
    self.answerTextArea.backgroundColor     = theme.secondaryBackgroundColor;
    
    self.captionLabel.font                  = theme.captionFont;
    self.captionLabel.textColor             = theme.secondaryTextColor;
    self.captionLabel.text                  = [self defaultCaptionText];
    
    self.answerTextArea.delegate            = self;
    self.answerTextArea.tintColor           = theme.primaryColor;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                           constant:0]];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.answerTextArea becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    ECSFormItemTextArea* textItem = (ECSFormItemTextArea*)self.formItem;
    
    textItem.formValue = textView.text;
    
    [self.delegate formItemViewController:self
                          answerDidChange:textView.text
                              forFormItem:textItem];
}

- (IBAction)viewTapped:(id)sender {
    
    [self.answerTextArea resignFirstResponder];
    
}

@end
