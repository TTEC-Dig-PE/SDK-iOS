//
//  ECDRegisterViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDRegisterViewController.h"

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDRegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *fieldContainerView;

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *createAccountLabel;
@property (weak, nonatomic) IBOutlet UIView *registerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerContainerBottomConstraint;

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *allFieldsRequiredLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *errorLabel;
@property (weak, nonatomic) IBOutlet ECSButton *registerButton;

@property (strong, nonatomic) ECSForm *form;
@property (strong, nonatomic) NSMutableArray *textFields;

@end

@implementation ECDRegisterViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
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
    
    self.errorLabel.text = @"";
    [self applyTheme];
    [self localizeElements];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setLoadingIndicatorVisible:YES];
    __weak typeof(self) weakSelf = self;
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager getFormByName:@"userprofile" withCompletion:^(ECSForm *form, NSError *error) {
        weakSelf.form = [form copy];
        [weakSelf buildFieldsForForm:form];
        [weakSelf setLoadingIndicatorVisible:NO];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)localizeElements
{
    self.createAccountLabel.text = ECDLocalizedString(ECDLocalizeCreateAccountPromptKey, @"Create a Humanify account");
    self.allFieldsRequiredLabel.text = ECSLocalizedString(ECSLocalizeAllFieldsRequired, @"All fields required");
    [self.registerButton setTitle:ECDLocalizedString(ECDLocalizeCreateAccountKey, @"Create Account"
                                                  ) forState:UIControlStateNormal];
}

- (void)applyTheme
{
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.fieldContainerView.backgroundColor = theme.secondaryBackgroundColor;
    self.createAccountLabel.textColor = theme.primaryTextColor;
    self.allFieldsRequiredLabel.textColor = theme.primaryTextColor;
}

- (void)buildFieldsForForm:(ECSForm*)form
{
    self.textFields = [NSMutableArray new];
    
    [self.fieldContainerView.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    
    ECSFormTextField *previousField = nil;
    for (ECSFormItem *item in form.formData)
    {
        BOOL showReturnKey = NO;
        if (item == form.formData.lastObject)
        {
            showReturnKey = YES;
        }
        if ([item.type isEqualToString:ECSFormTypeText])
        {
            ECSFormTextField *textField = [ECSFormTextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            [self.fieldContainerView addSubview:textField];
            textField.returnKeyType = showReturnKey ? UIReturnKeyDefault : UIReturnKeyNext;
            
            textField.placeholder = item.label;
            textField.delegate = self;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.itemId = item.itemId;
            
            if ([item.treatment isEqualToString:ECSFormTreatmentPassword])
            {
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textField.secureTextEntry = YES;
            }
            else if ([item.treatment isEqualToString:ECSFormTreatmentEmail])
            {
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textField.keyboardType = UIKeyboardTypeEmailAddress;
            }
            else if ([item.treatment isEqualToString:ECSFormTreatmentPhoneNumber])
            {
                textField.keyboardType = UIKeyboardTypePhonePad;
            }
            
            [self.fieldContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[field]-(0)-|"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:@{@"field": textField}]];
            [textField addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:44.0f]];
            if (previousField == nil)
            {
                [self.fieldContainerView addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.fieldContainerView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1.0f
                                                                                     constant:0.0f]];
            }
            else
            {
                
                [self.fieldContainerView addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:previousField
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0f
                                                                                     constant:0.0f]];

            }
            
            textField.itemId = [item.itemId copy];
            textField.metadata = [item.metadata copy];
            [self.textFields addObject:textField];
            previousField = textField;
            
        }
    }
    
    if (previousField)
    {
        [self.fieldContainerView addConstraint:[NSLayoutConstraint constraintWithItem:previousField
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.fieldContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0f
                                                                             constant:0.0f]];
    }

}

- (IBAction)registerTapped:(id)sender
{
    BOOL allFieldsEntered = YES;
    for (UITextField *textField in self.textFields)
    {
        [textField resignFirstResponder];
        if (textField.text.length == 0)
        {
            allFieldsEntered = NO;
        }
    }

    self.errorLabel.text = @"";
    if (!allFieldsEntered)
    {
        self.errorLabel.text = ECSLocalizedString(ECSLocalizeRegisterErrorMissingRequiredFields, @"All fields are required.");
    }
    else
    {
        
        NSString *userToken = nil;
        for (ECSFormItem *item in self.form.formData)
        {
            for (ECSFormTextField *textField in self.textFields)
            {
                if ([textField.itemId isEqualToString:item.itemId])
                {
                    item.formValue = textField.text;
                    
                    
                    if ([textField.metadata isEqualToString:@"profile.fullname"])
                    {
                        [EXPERTconnect shared].userDisplayName = textField.text;
                    }
                    else if ([textField.metadata isEqualToString:@"profile.firstname"] && ![EXPERTconnect shared].userDisplayName )
                    {
                        [EXPERTconnect shared].userDisplayName = textField.text;
                    }
                    else if ([textField.metadata isEqualToString:@"profile.lastname"] && ![EXPERTconnect shared].userDisplayName )
                    {
                        [EXPERTconnect shared].userDisplayName = textField.text;
                    }
                    else if ([textField.metadata isEqualToString:@"profile.email"])
                    {
                        userToken = textField.text;
                    }
                    
                    break;
                }
            }
        }
        [self setLoadingIndicatorVisible:YES];
        
        __weak typeof(self) weakSelf = self;
        ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
        [sessionManager submitForm:[self.form formResponseValue] completion:^(ECSFormSubmitResponse *response, NSError *error) {
            [weakSelf setLoadingIndicatorVisible:NO];
            if (!error && [response.profileUpdated boolValue] && response.identityToken.length > 0)
            {
                if (userToken)
                {
                    [EXPERTconnect shared].userName = userToken;

                }
                else
                {
                    [EXPERTconnect shared].userName = response.identityToken;
                }
                
                [weakSelf.delegate registerViewController:weakSelf didCompleteWithUser:response.identityToken];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ECSLocalizedString(ECSLocalizeError, @"Error")
                                                                    message:ECSLocalizedString(ECSLocalizeProfileError, @"Profile error") delegate:nil
                                                          cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

- (IBAction)viewTapped:(id)sender
{

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView scrollRectToVisible:textField.frame animated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSArray* returnOrder = self.textFields;
    NSInteger enterOn = [returnOrder indexOfObject:textField];
    if(enterOn >= 0)
    {
        if(enterOn + 1 < returnOrder.count)
        {
            UITextField* next = returnOrder[enterOn + 1];
            [next becomeFirstResponder];
        }
        else
        {
            [self registerTapped:nil];
        }
    }
    return YES;
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
        self.registerContainerBottomConstraint.constant = endFrame.size.height;
        insets.bottom = endFrame.size.height + self.registerContainer.frame.size.height;
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
        self.registerContainerBottomConstraint.constant = 0;
        insets.bottom = self.registerContainer.frame.size.height;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];
}

@end
