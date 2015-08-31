//
//  HZLoginViewController.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 19/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZLoginViewController.h"
#import "HZAppDelegate.h"

#import <LocalAuthentication/LocalAuthentication.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface HZLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *touchIdButton;

@end

@implementation HZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NK 6/22
    // FOR DEMO PURPOSES ONLY. Remove this before Production! ZZZZ
    self.emailField.text = @"gwen@email.com";
    
    
    LAContext *context = [[LAContext alloc] init];
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:policy error:&error]) {
        [self loginWithTouchId];
    }
    else {
        if (error.code == LAErrorTouchIDNotAvailable) {
            self.touchIdButton.hidden = YES;
        }
    }
}

- (IBAction)touchIdButtonTapped:(id)sender {
    [self loginWithTouchId];
}

- (IBAction)loginButtonTapped:(id)sender {
    [self loginWithEmail:self.emailField.text];
}


#pragma mark - Helper methods

- (void)loginWithTouchId {
    LAContext *context = [[LAContext alloc] init];
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.loadingIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [context
     evaluatePolicy:policy
     localizedReason:@"Sign in to Horizon"
     reply:^(BOOL success, NSError *error) {

         dispatch_async(dispatch_get_main_queue(), ^{

             [weakSelf.loadingIndicator stopAnimating];
             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
             
             if (success) {
                 [weakSelf loginWithEmail:@"gwen@email.com"];
             }
             else {
                 /*
                  /// Authentication was not successful, because user failed to provide valid credentials.
                  LAErrorAuthenticationFailed = kLAErrorAuthenticationFailed,
                  
                  /// Authentication was canceled by user (e.g. tapped Cancel button).
                  LAErrorUserCancel           = kLAErrorUserCancel,
                  
                  /// Authentication was canceled, because the user tapped the fallback button (Enter Password).
                  LAErrorUserFallback         = kLAErrorUserFallback,
                  
                  /// Authentication was canceled by system (e.g. another application went to foreground).
                  LAErrorSystemCancel         = kLAErrorSystemCancel,
                  
                  /// Authentication could not start, because passcode is not set on the device.
                  LAErrorPasscodeNotSet       = kLAErrorPasscodeNotSet,
                  
                  /// Authentication could not start, because Touch ID is not available on the device.
                  LAErrorTouchIDNotAvailable  = kLAErrorTouchIDNotAvailable,
                  
                  /// Authentication could not start, because Touch ID has no enrolled fingers.
                  LAErrorTouchIDNotEnrolled   = kLAErrorTouchIDNotEnrolled,
                  */
                 
                 if (error.code == LAErrorAuthenticationFailed ||
                     error.code == LAErrorPasscodeNotSet ||
                     error.code == LAErrorTouchIDNotAvailable ||
                     error.code == LAErrorTouchIDNotEnrolled) {
                     
                     UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"TouchID failed"
                                           message:error.localizedDescription
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                     
                     [alert show];
                     
                 }
             }
         });

     }];
}

- (void)loginWithEmail:(NSString *)email {

    __weak typeof(self) weakSelf = self;
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    [[EXPERTconnect shared] setUserToken:email];
    
    [weakSelf.loadingIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//
//    [sessionManager
//     getFormByName:@"userprofile"
//     withCompletion:^(ECSForm *form, NSError *error) {
//         
//         [weakSelf.loadingIndicator stopAnimating];
//         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//         
//         NSString *mobile = nil;
//         NSString *phone = nil;
//         if (form && form.formData) {
//             for (ECSFormItem *item in form.formData) {
//                 if ([item.metadata isEqualToString:@"profile.fullname"]) {
//                     [EXPERTconnect shared].userDisplayName = item.formValue;
//                     continue;
//                 }
//                 if ([item.metadata isEqualToString:@"profile.phone"]) {
//                     phone = item.formValue;
//                     continue;
//                 }
//                 if ([item.metadata isEqualToString:@"profile.mobile"]) {
//                     mobile = item.formValue;
//                     continue;
//                 }
//             }
//             
//             if (mobile != nil) {
//                 [EXPERTconnect shared].userCallbackNumber = mobile;
//             } else if (phone != nil) {
//                 [EXPERTconnect shared].userCallbackNumber = phone;
//             }
//             
//             [weakSelf handleSuccessfulLogin];
//         }
//         else {
//             [weakSelf handleFailedLogin];
//         }
//     }];

    [sessionManager getUserProfileWithCompletion:^(ECSUserProfile *profile, NSError *error)   {
        [weakSelf.loadingIndicator stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (error != nil) {
            [weakSelf handleFailedLogin];
        }
        else {
            if (profile.mobilePhone != nil) {
                [EXPERTconnect shared].userCallbackNumber = profile.mobilePhone;
            }
            NSString *firstName = @"";
            NSString *lastName = @"";
            if (profile.firstName != nil) {
                firstName = profile.firstName;
            }
            if (profile.lastName != nil) {
                lastName = profile.lastName;
            }
            NSString *fullName = [firstName stringByAppendingString:lastName];
            [EXPERTconnect shared].userDisplayName = fullName;
            NSDictionary *customData = profile.customData;
            NSString *treatmentType = [customData valueForKey:@"treatment"];
            NSString *customerType = [customData valueForKey:@"customer_type"];
            [EXPERTconnect shared].customerType = customerType;
            [EXPERTconnect shared].treatmentType = treatmentType;
            [weakSelf handleSuccessfulLogin];
        }
    }];
    
}

- (void)handleSuccessfulLogin {
    HZAppDelegate *appDelegate = (HZAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showDrawerAndMainScreen];
}

- (void)handleFailedLogin {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Login failed"
                          message:@"Check your email address and try again"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
