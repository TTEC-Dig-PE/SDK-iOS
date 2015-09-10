//
//  ECSFormSubmittedViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormSubmittedViewController.h"

#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"

@interface ECSFormSubmittedViewController ()

@end

@implementation ECSFormSubmittedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizeCloseKey, @"Close")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonTapped:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.headerLabel.font = theme.headlineFont;
    self.headerLabel.textColor = theme.primaryTextColor;
    self.descriptionLabel.font = theme.bodyFont;
    self.descriptionLabel.textColor = theme.primaryTextColor;

    
    self.headerLabel.text = ECSLocalizedString(ECSLocalizedSubmittedFormHeaderLabel, @"Thank You");
    self.descriptionLabel.text = ECSLocalizedString(ECSLocalizedSubmittedFormDescriptionLabel, @"Your response will help us better assist you and others in the future");
    [self.closeButton setTitle:ECSLocalizedString(ECSLocalizedSubmittedFormCloseLabel, @"Close") forState:UIControlStateNormal];
}

- (IBAction)closeButtonTapped:(id)sender {
    
    /*  if (self.navigationController)
     {
     [self dismissViewControllerAnimated:YES completion:nil];
     }
     */
    
    [self.workflowDelegate endWorkFlow];
}

@end
