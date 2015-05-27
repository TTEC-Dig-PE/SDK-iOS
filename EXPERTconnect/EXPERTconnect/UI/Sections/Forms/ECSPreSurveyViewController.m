//
//  ECSPreSurveyViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSPreSurveyViewController.h"

#import "ECSAttributedDynamicLabel.h"
#import "ECSDynamicLabel.h"
#import "ECSFormSubmitResponse.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSPreSurvey.h"
#import "ECSPresurveyFormItem.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"
#import "ECSUserManager.h"
#import "ECSButton.h"

@interface ECSPreSurveyViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet ECSAttributedDynamicLabel *topLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainer;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIView *finalActionContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *finalActionContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet ECSButton *finalActionButton;

@property (strong, nonatomic) NSMutableArray *textFieldArray;
@end

@implementation ECSPreSurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLayoutConstraint *leftContent = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
    NSLayoutConstraint *rightContent = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0f
                                                                     constant:0.0f];
    
    [self.view addConstraints:@[leftContent, rightContent]];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.finalActionContainer.backgroundColor = theme.secondaryBackgroundColor;
    [self.finalActionButton setTitle:ECSLocalizedString(ECSLocalizeSubmitKey, nil)
                            forState:UIControlStateNormal];
    self.finalActionButton.enabled = NO;
    self.topLabel.font = theme.bodyFont;
    self.bottomLabel.font = theme.captionFont;
    
    NSMutableAttributedString *topLabelText = [NSMutableAttributedString new];
    
    if (self.actionType.presurvey.formTitle)
    {
        self.navigationItem.title = self.actionType.presurvey.formTitle;
    }
    
    if (self.actionType.presurvey.formHeader)
    {
        [topLabelText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", self.actionType.presurvey.formHeader]
                                                                             attributes:@{
                                                                                          NSFontAttributeName: theme.subheaderFont,
                                                                                          ECSAttributedDynamicLabelBaseFont: theme.subheaderFont
                                                                                          }]];
    }
    
    if (self.actionType.presurvey.formHeader)
    {
        [topLabelText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", self.actionType.presurvey.formSubHeader]

                                                                             attributes:@{
                                                                                          NSFontAttributeName: theme.captionFont,
                                                                                          ECSAttributedDynamicLabelBaseFont: theme.captionFont
                                                                                          }]];
    }
    
    self.topLabel.attributedText = topLabelText;
    self.bottomLabel.text = self.actionType.presurvey.formFooter;
   
    UIView *lastAddedView = nil;
    
    self.textFieldArray = [[NSMutableArray alloc] initWithCapacity:self.actionType.presurvey.questions.count];
    
    for (int i = 0; i < self.actionType.presurvey.questions.count; i++)
    {
        ECSPresurveyFormItem *formItem = self.actionType.presurvey.questions[i];
    
        UITextField *textField = [self addTextFieldToView:self.textFieldContainer
                                                belowView:lastAddedView
                                        withConfiguration:formItem];
        
        if ([formItem.metadata isEqualToString:@"profile.email"])
        {
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        [self.textFieldArray addObject:textField];
        
        lastAddedView = textField;
        
        if (i < self.actionType.presurvey.questions.count - 1)
        {
            UIView *separator = [self addSeparatorToView:self.textFieldContainer belowView:lastAddedView];
            lastAddedView = separator;
        }
        else
        {
            NSLayoutConstraint *pinToBottom = [NSLayoutConstraint constraintWithItem:lastAddedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textFieldContainer attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
            [self.textFieldContainer addConstraint:pinToBottom];
        }
        
    }
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIEdgeInsets insets = self.scrollView.contentInset;
    
    insets.bottom = CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.finalActionContainer.frame);
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}

- (UITextField*)addTextFieldToView:(UIView*)parent
                         belowView:(UIView*)topView
                 withConfiguration:(ECSPresurveyFormItem*)configuration
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.placeholder = configuration.value;
    
    [textField addTarget:self action:@selector(checkSubmitEnable) forControlEvents:UIControlEventEditingChanged];
    textField.delegate = self;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [parent addSubview:textField];
    
    NSArray *verticalConstraints = nil;
    if (topView)
    {
        verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView][textfield]"
                                                                                options:0
                                                                                metrics:nil
                                                                         views:@{
                                                                                 @"topView": topView,
                                                                                 @"textfield": textField
                                                                                 }];
    }
    else
    {
        verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[textfield]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"textfield": textField}];
    }
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:textField
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:44.0f];
    
    NSArray *horizontalContstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(15)-[textfield]-(15)-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"textfield": textField}];
    [textField addConstraint:height];
    [parent addConstraints:verticalConstraints];
    [parent addConstraints:horizontalContstraints];
    
    return textField;
}

- (void)checkSubmitEnable
{
    BOOL enable = YES;
    for (UITextField *textField in self.textFieldArray)
    {
        if (textField.text.length == 0)
        {
            enable = NO;
            break;
        }
    }
    
    self.finalActionButton.enabled = enable;
}

- (UIView*)addSeparatorToView:(UIView*)parent
                    belowView:(UIView*)topView
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    separator.backgroundColor = theme.separatorColor;
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [parent addSubview:separator];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:separator
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:(1.0f / [[UIScreen mainScreen] scale])];
    
    
    
    NSArray *verticalConstraints = nil;
    if (topView)
    {
        verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView][separator]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{
                                                                                @"topView": topView,
                                                                                @"separator": separator
                                                                                }];
    }
    else
    {
        verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[separator]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"separator": separator}];
    }
    
    NSArray *horizontalContstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[separator]-(0)-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"separator": separator}];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:separator
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:topView
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0f
                                                                          constant:0.0f];
    [parent addConstraint:leadingConstraint];
    [separator addConstraint:height];
    [parent addConstraints:verticalConstraints];
    [parent addConstraints:horizontalContstraints];
    
    return separator;
}

- (IBAction)finalActionButtonTapped:(id)sender
{
    NSString *userToken = nil;
    
    ECSPreSurvey *submitPresurvey = [self.actionType.presurvey copy];
    for (int i = 0; i < self.textFieldArray.count; i++)
    {
        UITextField *textField = self.textFieldArray[i];
        ECSPresurveyFormItem *formItem = submitPresurvey.questions[i];
        formItem.value = textField.text;
        if ([formItem.metadata isEqualToString:@"profile.email"])
        {
            userToken = formItem.value;
        }

    }

    [self setLoadingIndicatorVisible:YES];
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    __weak typeof(self) weakSelf = self;
    [sessionManager submitForm:[submitPresurvey formValue] completion:^(ECSFormSubmitResponse *response, NSError *error) {
        [weakSelf setLoadingIndicatorVisible:NO];
        
        if ([response.submitted boolValue])
        {
            ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
            if (userToken)
            {
                userManager.userToken = userToken;
            }
            if (response.identityToken.length > 0)
            {
                
                userManager.userToken = response.identityToken;
            }
        }
        if (weakSelf.delegate)
        {
            [weakSelf.delegate surveyComplete];
        }
    }];
}

- (void)registerForKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.scrollView.contentInset;
        self.finalActionContainerBottomConstraint.constant = endFrame.size.height;
        insets.bottom = endFrame.size.height + self.finalActionContainer.frame.size.height;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.scrollView.contentInset;
        self.finalActionContainerBottomConstraint.constant = 0;
        insets.bottom = 0;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];

}

@end
