//
//  ECSCallbackViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCallbackViewController.h"

#import "ECSButton.h"
#import "ECSCallbackActionType.h"
#import "ECSChannelCreateResponse.h"
#import "ECSSMSActionType.h"
#import "ECSCancelCallbackViewController.h"
#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSUserManager.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"
#import "ECSLog.h"

//#import "ECSChannelConfiguration.h"
//#import "ECSCallbackSetupResponse.h"
//#import "ECSConversationCreateResponse.h"
//#import "ECSConversationLink.h"

#import "UIViewController+ECSNibLoading.h"

@interface ECSCallbackViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView               *scrollView;
@property (weak, nonatomic) IBOutlet UIView                     *contentView;
@property (weak, nonatomic) IBOutlet ECSButton                  *requestCallButton;
@property (weak, nonatomic) IBOutlet UIView                     *toolbarContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *toolbarContainerBottomContstraint;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel            *headerLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel            *disclaimerLabel;
@property (weak, nonatomic) IBOutlet UITextField                *callbackTextField;

//@property (strong, nonatomic) NSString                          *currentConversationId;
@property (strong, nonatomic) ECSCancelCallbackViewController   *cancelCallback;
@property (strong, nonatomic) ECSStompChatClient                *chatClient;
//@property (strong, nonatomic) ECSStompCallbackClient          *callbackClient;

@property (strong, nonatomic) NSString *phoneNumberString;

@end

@implementation ECSCallbackViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];

    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.headerLabel.font = theme.bodyFont;
    self.headerLabel.textColor = theme.primaryTextColor;
    self.disclaimerLabel.font = theme.captionFont;
    self.disclaimerLabel.textColor = theme.secondaryTextColor;
    self.callbackTextField.tintColor = theme.primaryColor;
    
    self.requestCallButton.enabled = NO;

    if (self.displaySMSOption) {
        
        self.navigationItem.title = ECSLocalizedString(ECSLocalizeSMSNavigationTitle, @"SMS Message");
        
        self.headerLabel.text = ECSLocalizedString(ECSLocalizeRequestSMSText,
                                                   @"Enter your phone number to receive a SMS:");
        
        self.disclaimerLabel.text = ECSLocalizedString(ECSLocalizeRequestSMSDisclaimerText,
                                                       @"Carrier voice and data rates may apply");
        
        [self.requestCallButton setTitle:ECSLocalizedString(ECSLocalizeRequestSMSButton, @"Request a SMS")
                                forState:UIControlStateNormal];
        
    } else {
        
        self.navigationItem.title = ECSLocalizedString(ECSLocalizeCallNavigationTitle, @"Phone Call");
        
        self.headerLabel.text = ECSLocalizedString(ECSLocalizeRequestCallText,
                                                   @"Enter your phone number to receive a call:");
        
        self.disclaimerLabel.text = ECSLocalizedString(ECSLocalizeRequestCallDisclaimerText,
                                                       @"Carrier voice and data rates may apply");
        
        [self.requestCallButton setTitle:ECSLocalizedString(ECSLocalizeRequestCallButton, @"Request a Phone Call")
                                forState:UIControlStateNormal];
    }
    
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
    
    self.logger = [[EXPERTconnect shared] logger];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.requestCallButton.enabled = YES;
    self.callbackTextField.enabled = YES;
    
    [self.callbackTextField becomeFirstResponder];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    // NK 6/24/2015 - Get the user's callback number from the profile and use that as
    // both the default AND the placeholder text:
    NSString *num = [EXPERTconnect shared].userCallbackNumber;
    
    if (num != nil) {
        
        NSMutableCharacterSet *phoneNumberSet = [NSMutableCharacterSet decimalDigitCharacterSet];
        
        NSMutableString *phone = [NSMutableString stringWithString:@""];
        
        for(int i = 0; i < num.length; i++) {
            
            if ([phoneNumberSet characterIsMember:[num characterAtIndex:i]]) {
                
                [phone appendFormat:@"%c",[num characterAtIndex:i]];
                
            }
        }
        
        self.callbackTextField.text = [self formatPhoneString:phone];
        self.callbackTextField.placeholder = [self formatPhoneString:phone];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Buttons

- (IBAction)requestCallTapped:(id)sender {

    [self.requestCallButton setTitle:ECSLocalizedString(ECSLocalizeProcessingButton, @"Processing...")
                            forState:UIControlStateDisabled];
    
    self.requestCallButton.enabled = NO;
    self.callbackTextField.enabled = NO;
    
    ECSCallbackActionType *cbAction = (ECSCallbackActionType *)self.actionType;
    
    NSString *phoneNumber = [[self.callbackTextField.text
                              componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                     componentsJoinedByString:@""];
    
    if (phoneNumber.length > 10) {
        phoneNumber = [NSString stringWithFormat:@"+%@", phoneNumber];
    }
    
    // Update saved version
    [EXPERTconnect shared].userCallbackNumber = phoneNumber;
    
    if (!self.chatClient) {
        
        // Initiate a new Chat Stomp client.
        self.chatClient = [ECSStompChatClient new];
        self.chatClient.delegate = self;
    }
    
    [self.chatClient startVoiceCallbackWithSkill:cbAction.agentSkill
                                         subject:cbAction.subject
                                     phoneNumber:phoneNumber
                                        priority:cbAction.priority
                                      dataFields:nil];

}

#pragma mark - Stomp Callbacks

- (void) chatChannelCreated:(ECSChannelCreateResponse *)response {
    
    if (self.skipConfirmationView) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (self.displaySMSOption) {
        
        [self.requestCallButton setTitle:ECSLocalizedString(ECSLocalizeRequestSMSButton, @"Request a SMS")
                                forState:UIControlStateDisabled];
        
    } else {
        
        [self.requestCallButton setTitle:ECSLocalizedString(ECSLocalizeRequestCallButton, @"Request a Phone Call")
                                forState:UIControlStateDisabled];
    }
    
    if (_cancelCallback != nil) {
        _cancelCallback = nil; // release
    }
    _cancelCallback = [ECSCancelCallbackViewController ecs_loadFromNib];
    
    _cancelCallback.workflowDelegate    = self.workflowDelegate;
    _cancelCallback.closeChannelURL     = ((ECSConversationCreateResponse*)response).closeLink;
    _cancelCallback.phoneNumber         = self.callbackTextField.text;
    _cancelCallback.displaySMSOption    = self.displaySMSOption;
    _cancelCallback.waitTime            = response.estimatedWait;
    _cancelCallback.actionId            = self.actionType.actionId;
    
    [self.navigationController pushViewController:_cancelCallback animated:YES];
    
}

- (void) chatDidFailWithError:(NSError *)error {
    
    ECSLogDebug(self.logger, @"Error: %@", error);
    
//    if( [error.domain isEqualToString:@"ECSWebSocketErrorDomain"] ||
//       [error.domain isEqualToString:@"kCFErrorDomainCFNetwork"] ||
//       ( [error.domain isEqualToString:NSPOSIXErrorDomain] && (error.code >= ENETDOWN && error.code <= ENOTCONN) ) ) {
//
//        [self showNetworkErrorBar];
//
//        if( [error.userInfo[ECSHTTPResponseErrorKey] intValue] == 401 ) {
//
//            // Let's immediately try to refresh the auth token.
//            [self refreshAuthenticationToken];
//        }
//
//    } else {
        /* Example Errors:
         NSURLErrorDomain, -1004, "Could not connect to the server"
         */
        
        // Any unknown errors
        NSString *errorMessage = ECSLocalizedString(ECSLocalizeErrorText, nil);
        
        BOOL validError = (![error.userInfo[NSLocalizedDescriptionKey] isEqual:[NSNull null]] &&
                           error.userInfo[NSLocalizedDescriptionKey]);
        
        // We have an actual error message to display. We'll replace the generic one with this.
        if (error && validError) {
            
            // MAS - show generic error message
            //errorMessage = error.userInfo[NSLocalizedDescriptionKey];
            errorMessage = ECSLocalizedString(ECSLocalizeErrorText, nil);
            
            // NOTE: This is a specific case to handle "No agents available" until the server does it correctly.
            if([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"No agents available"])
            {
                // Let's localize this.
                errorMessage = ECSLocalizedString(ECSLocalizeNoAgents, @"No Agents Available.");
            }
            
        }
        [self showAlertForErrorTitle:ECSLocalizedString(ECSLocalizeError,@"Error") message:errorMessage];
    
//    }
    
}

- (void)chatAgentDidAnswer {
    
    // The agent answered the phone. Display "in progress" screen.
    [_cancelCallback displayInProgressCallBack];
    
}

- (void) chatDisconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    ECSLogVerbose(self.logger, @"Stomp disconnect notification. DisconnectReason=%@, TerminatedBy=%@",
                  message.disconnectReasonString,
                  message.terminatedByString);
    
    if (self.chatClient != nil) {
        [self.chatClient disconnect];
    }
    
    [_cancelCallback dismissviewAndNotify:YES reason:@"CallCompleted"];
}

//- (void)chatClient:(ECSStompCallbackClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage *)message
- (void)chatAddChannelWithMessage:(ECSChatAddChannelMessage *)message {
    /* no op */
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.phoneNumberString = @"";
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    self.phoneNumberString = @"";
    self.requestCallButton.enabled = NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableCharacterSet *phoneNumberSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    
    NSString *trimedReplacementString = [string stringByTrimmingCharactersInSet:[phoneNumberSet invertedSet]];
    
    if (trimedReplacementString.length == string.length) {
        
        NSString *replacementString = [textField.text stringByReplacingCharactersInRange:range withString:trimedReplacementString];
        
        NSCharacterSet *nonPhoneNumberSet = [phoneNumberSet invertedSet];
        
        NSString *numberOnlyString = [[replacementString componentsSeparatedByCharactersInSet:nonPhoneNumberSet] componentsJoinedByString:@""];

        textField.text = [self formatPhoneString:numberOnlyString];
    }
    
    return NO;
}

#pragma mark - Keyboard

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.scrollView.contentInset;
        self.toolbarContainerBottomContstraint.constant = endFrame.size.height;
        insets.bottom = endFrame.size.height + self.toolbarContainer.frame.size.height;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.scrollView.contentInset;
        self.toolbarContainerBottomContstraint.constant = 0;
        insets.bottom = 0;
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Internal Utility Functions

// Show an alert popup to the user with the generic "an error has occurred" style message.
//- (void)showAlertForError:(NSError *)theError fromFunction:(NSString *)theFunction {
- (void)showAlertForErrorTitle:(NSString *)theTitle message:(NSString *)theMessage {
    
    ECSLogError(self.logger,@"%@ - %@", theTitle, theMessage);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:theTitle
                                                                             message:theMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
                                                          
          // Make alert go away.
          if (weakSelf.isBeingPresented) {
              
              [weakSelf dismissViewControllerAnimated:YES completion:nil];
              
          } else if (weakSelf.navigationController.viewControllers.count > 1) {
              
              [weakSelf.navigationController popViewControllerAnimated:YES];
              
          }
      }]];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (NSString*)formatPhoneString:(NSString*)string {
    
    NSString *newString = nil;
    if (string.length <= 4) {
        
        newString = string;
        
    } else if (string.length <= 7) {
        
        NSInteger remainingLength = string.length - 4;
        newString = [NSString stringWithFormat:@"%@-%@",
                     [string substringWithRange:NSMakeRange(0, remainingLength)],
                     [string substringWithRange:NSMakeRange(remainingLength, 4)]];
        
    } else if (string.length <= 10) {
        
        NSInteger remainingLength = string.length - 7;
        newString = [NSString stringWithFormat:@"(%@) %@-%@",
                     [string substringWithRange:NSMakeRange(0, remainingLength)],
                     [string substringWithRange:NSMakeRange(remainingLength, 3)],
                     [string substringWithRange:NSMakeRange(remainingLength + 3, 4)]];
        
    } else {
        
        NSInteger remainingLength = string.length - 10;
        newString = [NSString stringWithFormat:@"+%@ (%@) %@-%@",
                     [string substringWithRange:NSMakeRange(0, remainingLength)],
                     [string substringWithRange:NSMakeRange(remainingLength, 3)],
                     [string substringWithRange:NSMakeRange(remainingLength + 3, 3)],
                     [string substringWithRange:NSMakeRange(remainingLength + 6, 4)]];
    }
    
    if (string.length >= 10) {
        
        self.requestCallButton.enabled = YES;
        
    } else {
        
        self.requestCallButton.enabled = NO;
    }
    
    return newString;
}

@end
