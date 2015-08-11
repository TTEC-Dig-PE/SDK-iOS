//
//  ECDExtendedUserProfileViewController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDExtendedUserProfileViewController.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>
#import <EXPERTconnect/ECSUserProfile.h>

@interface ECDExtendedUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeField;
@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (weak, nonatomic) IBOutlet UITextField *homePhoneField;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneField;
@property (weak, nonatomic) IBOutlet UITextField *alternateEmailField;
@property (weak, nonatomic) IBOutlet UITextView *extendedAttibutesView;

@end


@implementation ECDExtendedUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLoadingIndicatorVisible:YES];
    
    __weak typeof(self) weakSelf = self;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];    
    [sessionManager getUserProfileWithCompletion:^(ECSUserProfile *profile, NSError *error)   {
        
        weakSelf.firstNameField.text = profile.firstName;
        weakSelf.lastNameField.text = profile.lastName;
        weakSelf.emailAddressField.text = profile.userID;
        weakSelf.cityField.text = profile.city;
        weakSelf.stateField.text = profile.state;
        weakSelf.zipCodeField.text = profile.postalCode;
        weakSelf.countryField.text = profile.country;
        weakSelf.homePhoneField.text = profile.homePhone;
        weakSelf.mobilePhoneField.text = profile.mobilePhone;
        weakSelf.alternateEmailField.text = profile.alternativeEmail;
        weakSelf.extendedAttibutesView.text = @"Deserialize: profile.customData";
        
        [weakSelf setLoadingIndicatorVisible:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}

@end