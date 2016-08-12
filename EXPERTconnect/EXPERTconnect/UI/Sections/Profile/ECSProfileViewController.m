//
//  ECSProfileViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//


#import "ECSProfileViewController.h"

#import "ECSAnswerEngineHistoryViewController.h"
#import "ECSChatLogsViewController.h"
#import "ECSCircleImageView.h"
#import "ECSDynamicLabel.h"
#import "ECSForm.h"
#import "ECSFormItem.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSURLSessionManager.h"
#import "ECSFormTextField.h"
#import "ECSFormSubmitResponse.h"
#import "ECSUserManager.h"
#import "ECSTheme.h"

#import "UIViewController+ECSNibLoading.h"

@interface ECSProfileViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSeparatorWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *verticalDivider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *horizontalSeparator;
@property (weak, nonatomic) IBOutlet ECSCircleImageView *leftItemImageView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *leftItemLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *rightItemLabel;
@property (weak, nonatomic) IBOutlet ECSCircleImageView *rightItemImageView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *editProfileSectionHeader;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainer;
@property (weak, nonatomic) IBOutlet UIView *topButtonView;
@property (weak, nonatomic) IBOutlet UIView *leftFeaturedView;
@property (weak, nonatomic) IBOutlet UIView *rightFeaturedView;
@property (weak, nonatomic) IBOutlet UIButton *updateProfileButton;


@property (strong, nonatomic) ECSForm *form;
@property (strong, nonatomic) NSMutableArray *textFields;
@end

@implementation ECSProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0f
                                                                        constant:0.0f];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    
    [self.view addConstraints:@[leftConstraint, rightConstraint, heightConstraint]];

    self.navigationItem.title = ECSLocalizedString(ECSLocalizeProfile, @"Profile");
    self.leftItemLabel.text = [ECSLocalizedString(ECSLocalizeChatLogs, @"Chat Logs") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.rightItemLabel.text = [ECSLocalizedString(ECSLocalizeHistory, @"History") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.editProfileSectionHeader.text = [ECSLocalizedString(ECSLocalizeEditProfile, @"Edit Profile") uppercaseStringWithLocale:[NSLocale currentLocale]];
    [self.updateProfileButton setTitle:ECSLocalizedString(ECSLocalizeEditProfile, @"Update Profile") forState:UIControlStateNormal];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    
    self.topButtonView.backgroundColor = theme.secondaryBackgroundColor;
    self.textFieldContainer.backgroundColor = theme.secondaryBackgroundColor;
    
    self.verticalSeparatorWidthConstraint.constant = (1.0f / [[UIScreen mainScreen] scale]);
    self.horizontalHeightConstraint.constant = (1.0f / [[UIScreen mainScreen] scale]);
    self.leftItemImageView.backgroundColor = theme.primaryColor;
    self.rightItemImageView.backgroundColor = theme.primaryColor;
    self.leftItemLabel.font = theme.buttonFont;
    self.leftItemLabel.textColor = theme.primaryTextColor;
    self.rightItemLabel.font = theme.buttonFont;
    self.rightItemLabel.textColor = theme.primaryTextColor; 
    self.leftFeaturedView.backgroundColor = theme.secondaryBackgroundColor;
    self.rightFeaturedView.backgroundColor = theme.secondaryBackgroundColor;
    
    self.verticalDivider.backgroundColor = theme.separatorColor;
    self.horizontalSeparator.backgroundColor = theme.separatorColor;
    
    self.editProfileSectionHeader.textColor = theme.sectionHeaderTextColor;
    self.editProfileSectionHeader.font = theme.buttonFont;
    
    [self registerForKeyboardNotifications];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setLoadingIndicatorVisible:YES];
    __weak typeof(self) weakSelf = self;
    ECSURLSessionManager* sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [sessionManager getFormByName:@"userprofile" withCompletion:^(ECSForm *form, NSError *error) {
        weakSelf.form = [form copy];
        [weakSelf buildFieldsForForm:form];
        [weakSelf setLoadingIndicatorVisible:NO];
    }];
}

- (void)buildFieldsForForm:(ECSForm*)form
{
    self.textFields = [NSMutableArray new];
    
    [self.textFieldContainer.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    
    ECSFormTextField *previousField = nil;
    for (ECSFormItem *item in form.formData)
    {
        if ([item.type isEqualToString:ECSFormTypeText])
        {
            ECSFormTextField *textField = [ECSFormTextField new];
            textField.translatesAutoresizingMaskIntoConstraints = NO;
            [self.textFieldContainer addSubview:textField];
            
            textField.text = item.formValue;
            textField.placeholder = item.label;
            
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            if ([item.treatment isEqualToString:ECSFormTreatmentPassword])
            {
                textField.secureTextEntry = YES;
            }
            else if ([item.treatment isEqualToString:ECSFormTreatmentEmail])
            {
                textField.keyboardType = UIKeyboardTypeEmailAddress;
            }
            else if ([item.treatment isEqualToString:ECSFormTreatmentPhoneNumber])
            {
                textField.keyboardType = UIKeyboardTypePhonePad;
            }
            
            [self.textFieldContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[field]-(0)-|"
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
                [self.textFieldContainer addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.textFieldContainer
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1.0f
                                                                                     constant:0.0f]];
            }
            else
            {
                
                [self.textFieldContainer addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:previousField
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0f
                                                                                     constant:0.0f]];
                
            }
            
            textField.itemId = [item.itemId copy];
            textField.required = item.required.boolValue;
            textField.metadata = [item.metadata copy];
            [self.textFields addObject:textField];
            previousField = textField;
            
        }
    }
    
    if (previousField)
    {
        [self.textFieldContainer addConstraint:[NSLayoutConstraint constraintWithItem:previousField
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.textFieldContainer
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0f
                                                                             constant:0.0f]];
    }
    
}

- (IBAction)updateProfileTapped:(id)sender
{
    BOOL allFieldsEntered = YES;
    for (ECSFormTextField *textField in self.textFields)
    {
        [textField resignFirstResponder];
        if (textField.text.length == 0 && textField.required)
        {
            allFieldsEntered = NO;
            break;
        }
    }
    
    if (allFieldsEntered)
    {
        NSString *userToken = nil;
        ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
        
        for (ECSFormItem *item in self.form.formData)
        {
            for (ECSFormTextField *textField in self.textFields)
            {
                if ([textField.metadata isEqualToString:@"profile.email"])
                {
                    userToken = textField.text;
                }
                else if ([textField.metadata isEqualToString:@"profile.fullname"])
                {
                    userManager.userDisplayName = textField.text;
                }
                else if( [textField.metadata isEqualToString:@"profile.firstname"] && !userManager.userDisplayName)
                {
                    userManager.userDisplayName = textField.text;
                }
                else if( [textField.metadata isEqualToString:@"profile.lastname"] && !userManager.userDisplayName)
                {
                    userManager.userDisplayName = textField.text;
                }
                
                if ([textField.itemId isEqualToString:item.itemId])
                {
                    item.formValue = textField.text;
                    break;
                }
            }
        }
        [self setLoadingIndicatorVisible:YES];
        
        __weak typeof(self) weakSelf = self;
        ECSURLSessionManager* sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        [sessionManager submitForm:[self.form formResponseValue] completion:^(ECSFormSubmitResponse *response, NSError *error) {
            [weakSelf setLoadingIndicatorVisible:NO];
            if (!error && [response.profileUpdated boolValue] && response.identityToken.length > 0)
            {
                ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
                if (userToken)
                {
                    userManager.userToken = userToken;
                }
                else
                {
                    userManager.userToken = response.identityToken;
                }
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
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ECSLocalizedString(ECSLocalizeError, @"Error")
                                                                                 message:ECSLocalizedString(ECSLocalizeProfileError, @"Profile error")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                           style:UIAlertActionStyleDefault
                                                                  handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)leftItemTapped:(id)sender {
    ECSChatLogsViewController *chatLogs = [ECSChatLogsViewController ecs_loadFromNib];
    [self.navigationController pushViewController:chatLogs animated:YES];
}

- (IBAction)rightItemTapped:(id)sender {
    ECSAnswerEngineHistoryViewController *history = [ECSAnswerEngineHistoryViewController ecs_loadFromNib];
    [self.navigationController pushViewController:history animated:YES];
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
        insets.bottom = endFrame.size.height;
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
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];
}

@end
