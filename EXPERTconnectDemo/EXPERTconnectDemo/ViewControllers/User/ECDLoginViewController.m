//
//  ECDLoginViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDLoginViewController.h"
#import "ECDLocalization.h"
#import "AppConfig.h"

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDLoginViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *logInLabel;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainerView;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *fieldsRequiredLabel;
@property (weak, nonatomic) IBOutlet UIView *fieldSeparator;
@property (weak, nonatomic) IBOutlet UIView *logInContainer;
@property (weak, nonatomic) IBOutlet ECSButton *logInButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logInContainerBottomConstraint;

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *errorLabel;

@end

@implementation ECDLoginViewController

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

    self.errorLabel.text = @"";
    [self applyTheme];
    [self localizeElements];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)localizeElements
{
    self.logInLabel.text = ECSLocalizedString(ECSLogInPromptText, @"Log in prompt text");
    self.emailAddressField.placeholder = ECSLocalizedString(ECSLocalizeEmailFieldPlaceholder, @"Email Address");
    self.fieldsRequiredLabel.text = ECSLocalizedString(ECSLocalizeAllFieldsRequired, @"All fields required");
    [self.logInButton setTitle:ECSLocalizedString(ECSLocalizeLogInButton, @"Log In"
                                                  ) forState:UIControlStateNormal];
}

- (void)applyTheme
{
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.textFieldContainerView.backgroundColor = theme.secondaryBackgroundColor;
    self.logInLabel.textColor = theme.primaryTextColor;
    self.fieldsRequiredLabel.textColor = theme.primaryTextColor;
    self.fieldSeparator.backgroundColor = theme.primaryBackgroundColor;
    self.logInButton.ecsBackgroundColor = theme.primaryColor;
}

- (IBAction)logInTapped:(id)sender
{
    self.errorLabel.text = @"";
    if (self.emailAddressField.text.length == 0)
    {
        self.errorLabel.text = ECSLocalizedString(ECSLocalizeLoginErrorMissingRequiredFields, @"Email Address field is required.");
    }
    else
    {
        self.emailAddressField.enabled = NO;
        self.logInButton.enabled = NO;

        __weak typeof(self) weakSelf = self;
        [weakSelf setLoadingIndicatorVisible:YES];

/*
        ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
        [[EXPERTconnect shared] setUserName:self.emailAddressField.text];
        
        [sessionManager getFormByName:@"userprofile" withCompletion:^(ECSForm *form, NSError *error) {
            if (form && form.formData)
            {
                for (ECSFormItem *item in form.formData)
                {
                    if ([item.metadata isEqualToString:@"profile.fullname"])
                    {
                        [EXPERTconnect shared].userDisplayName = item.formValue;
                        break;
                    }
                }
                if (weakSelf.delegate)
                {
                    [weakSelf setLoadingIndicatorVisible:NO];
                    [weakSelf.delegate loginViewController:weakSelf
                                      didLoginWithUserInfo:weakSelf.emailAddressField.text];
                }
            }
            else
            {
                
                [weakSelf showLoginAlert];
            }
        }];
 */
        AppConfig *myAppConfig = [AppConfig sharedAppConfig];
        
        myAppConfig.userName = weakSelf.emailAddressField.text;
        //[[EXPERTconnect shared] setUserName:myAppConfig.userName];
        
        [myAppConfig fetchAuthenticationToken:^(NSString *authToken, NSError *error)
         {
             if (!error) {
                 [[EXPERTconnect shared] setUserIdentityToken:authToken];
             }

             [[EXPERTconnect shared] login:self.emailAddressField.text withCompletion:^(ECSForm *form, NSError *error) {
                 if (form && form.formData)
                 {
                     if (weakSelf.delegate)
                     {
                         [weakSelf setLoadingIndicatorVisible:NO];
                         [weakSelf.delegate loginViewController:weakSelf
                                           didLoginWithUserInfo:weakSelf.emailAddressField.text];
                     }
                     
                     NSLog(@"Test Harness::Login - Login succeeded. Blowing away authToken...");
                     
                     [[EXPERTconnect shared] setClientID:[myAppConfig getClientID]];
                     [[EXPERTconnect shared] startJourneyWithCompletion:nil]; // Start a new journey.
                 }
                 else
                 {
                     [weakSelf showLoginAlert];
                 }
             }];
         }];
        
        
    }
}

- (void)showLoginAlert
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        NSString *ok_label = ECSLocalizedString(ECSLocalizedOkButton, @"OK");
        NSString *error_label = ECSLocalizedString(ECSLocalizeErrorKey, @"Error");
        NSString *error_message = ECDLocalizedString(ECDLocalizedUnknownUser, @"Unknown user, please register to create an account.");
        
        UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:error_label
                                                                            message:error_message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [loginAlert addAction:[UIAlertAction actionWithTitle:ok_label
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                           [[EXPERTconnect shared] setUserName:nil];
                                                       }]];
        [self presentViewController:loginAlert animated:YES completion:nil];
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
        self.logInContainerBottomConstraint.constant = endFrame.size.height;
        insets.bottom = endFrame.size.height + self.logInContainer.frame.size.height;
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
        self.logInContainerBottomConstraint.constant = 0;
        insets.bottom = self.logInContainer.frame.size.height;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];
}


@end
