//
//  ECDAPIConfigViewController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDAPIConfigViewController.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>
#import <EXPERTconnect/ECSUserProfile.h>

@interface ECDAPIConfigViewController ()

@property (weak, nonatomic) IBOutlet UITextField *configNameField;
@property (weak, nonatomic) IBOutlet UITextField *configEndpointField;
@property (weak, nonatomic) IBOutlet UITextField *configValueField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation ECDAPIConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeFields];
}

-(void) initializeFields {

    // Set the tintColor so we can see the cursor
    //
    // self.firstNameField.tintColor = UIColor.blueColor;
    
    // Round button corners
    CALayer *btnLayer = [self.submitButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    [self.submitButton addTarget:self
                          action:@selector(submitButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)submitButtonTapped:(UIButton*)button
{
    NSString *endpoint = [[self.configEndpointField.text
                           stringByReplacingOccurrencesOfString:@"{name}" withString:self.configNameField.text]
                           stringByReplacingOccurrencesOfString:@"{value}" withString:self.configValueField.text];
    
    __weak typeof(self) weakSelf = self;
    
    ECSCodeBlock whenCompleted = ^(NSString *response, NSError *error)   {
        NSString *title = ECSLocalizedString(ECSLocalizeInfoKey, @"Info");
        NSString *profileMessage = ECDLocalizedString(ECDLocalizeProfileWasUpdatedKey, @"Config Value was updated:");
        NSString *message = [NSString stringWithFormat:[profileMessage stringByAppendingString:@": %@"], response];
        
        [weakSelf showAlert:title withMessage:message];
    };
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager getResponseFromEndpoint:endpoint withCompletion:whenCompleted];
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