//
//  ECDExtendedUserProfileViewController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDExtendedUserProfileViewController.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>
#import <EXPERTconnect/ECSUserProfile.h>


static NSString *configFileName = @"UserProfile";


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
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation ECDExtendedUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLoadingIndicatorVisible:YES];
    
    [self initializeFields];
    
    __weak typeof(self) weakSelf = self;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];    
    [sessionManager getUserProfileWithCompletion:^(ECSUserProfile *profile, NSError *error)   {
        
        if (error) {
            // If we get an error, display it and pop back home.
            UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:[error.userInfo objectForKey:@"NSLocalizedDescription"]
                                             preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok =
                [UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }];
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            NSError *jsonError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:profile.customData options:NSJSONWritingPrettyPrinted error:&jsonError];
            
            weakSelf.firstNameField.text = profile.firstName;
            weakSelf.lastNameField.text = profile.lastName;
            weakSelf.emailAddressField.text = profile.username;
            weakSelf.cityField.text = profile.city;
            weakSelf.stateField.text = profile.state;
            weakSelf.zipCodeField.text = profile.postalCode;
            weakSelf.countryField.text = profile.country;
            weakSelf.homePhoneField.text = profile.homePhone;
            weakSelf.mobilePhoneField.text = profile.mobilePhone;
            weakSelf.alternateEmailField.text = profile.alternativeEmail;
            weakSelf.extendedAttibutesView.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            [weakSelf setLoadingIndicatorVisible:NO];
        }
    }];
}

-(void) initializeFields {
    self.firstNameField.text = @"";
    self.lastNameField.text =  @"";
    self.emailAddressField.text =  @"";
    self.cityField.text =  @"";
    self.stateField.text =  @"";
    self.zipCodeField.text =  @"";
    self.countryField.text =  @"";
    self.homePhoneField.text =  @"";
    self.mobilePhoneField.text =  @"";
    self.alternateEmailField.text =  @"";
    self.extendedAttibutesView.text =  @"";
    
    // Set the tintColor so we can see the cursor
    //
    self.firstNameField.tintColor = UIColor.blueColor;
    self.lastNameField.tintColor = UIColor.blueColor;
    self.emailAddressField.tintColor = UIColor.blueColor;
    self.cityField.tintColor = UIColor.blueColor;
    self.stateField.tintColor = UIColor.blueColor;
    self.zipCodeField.tintColor = UIColor.blueColor;
    self.countryField.tintColor = UIColor.blueColor;
    self.homePhoneField.tintColor = UIColor.blueColor;
    self.mobilePhoneField.tintColor = UIColor.blueColor;
    self.alternateEmailField.tintColor = UIColor.blueColor;
    self.extendedAttibutesView.tintColor = UIColor.blueColor;
    
    // Round button corners
    CALayer *btnLayer = [self.submitButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    [self.submitButton addTarget:self
               action:@selector(submitButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.emailAddressField addTarget:self
                  action:@selector(emailAddressFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)populateExtendedAttributesWithDefaultJson {
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"json"];
    if (configPath)
    {
        NSData *configData = [NSData dataWithContentsOfFile:configPath];
        NSError *error;
        NSDictionary *configJSON = [NSJSONSerialization JSONObjectWithData:configData
                                                                   options:0
                                                                     error:&error];
        
        if (!error)
        {
            NSError *jsonError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:configJSON options:NSJSONWritingPrettyPrinted error:&jsonError];
            
            self.extendedAttibutesView.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else  {
            // default to hard-coded JSON
            //
            self.extendedAttibutesView.text = [@"{\n\t'nps':4,\n\t'klout':40,\n\t'clv':75000,\n\t'interests':[\n\t\t'running',\n\t\t'skiing'\n\t],\n\t'region':'midatlantic',\n\t'affinity':{\n\t\t'sat_score':9,\n\t\t'expertId':'chris_horizon',\n\t\t'skill':'financial advisor'\n\t}\n}" stringByReplacingOccurrencesOfString: @"'" withString:@"\""];
        }
    }

    self.extendedAttibutesView.textColor = UIColor.redColor;
}

- (void)submitButtonTapped:(UIButton*)button
{
    NSError *error = nil;
    NSData *jsonData = [self.extendedAttibutesView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    ECSUserProfile * profile = [ECSUserProfile new];
    
    profile.firstName = self.firstNameField.text;
    profile.lastName = self.lastNameField.text;
    profile.username = self.emailAddressField.text;
    profile.city = self.cityField.text;
    profile.state = self.stateField.text;
    profile.postalCode = self.zipCodeField.text;
    profile.country = self.countryField.text;
    profile.homePhone = self.homePhoneField.text;
    profile.mobilePhone = self.mobilePhoneField.text;
    profile.alternativeEmail = self.alternateEmailField.text;
    profile.customData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    __weak typeof(self) weakSelf = self;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager submitUserProfile:profile withCompletion:^(NSDictionary *response, NSError *error)   {
        NSString *title = ECSLocalizedString(ECSLocalizeInfoKey, @"Info");
        NSString *profileMessage = ECDLocalizedString(ECDLocalizeProfileWasUpdatedKey, @"Profile was updated:");
        NSString *message = [NSString stringWithFormat:[profileMessage stringByAppendingString:@": %@"], response];
        
        weakSelf.extendedAttibutesView.textColor = UIColor.blackColor;
        [weakSelf showAlert:title withMessage:message];
    }];
}

- (void)emailAddressFieldDidChange:(UIButton*)button
{
    if(self.extendedAttibutesView.text.length == 0)   {
        [self populateExtendedAttributesWithDefaultJson];
    }
}

- (void) showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
