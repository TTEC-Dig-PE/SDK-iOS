//  EXPERTconnect
//  ECSMessageViewController.m
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "ECSMessageViewController.h"

#import "ECSButton.h"
#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSMessageActionType.h"
#import "ECSTheme.h"

@interface ECSMessageViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *titleLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *hoursLabel;
@property (weak, nonatomic) IBOutlet ECSButton *emailButton;

@end

@implementation ECSMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.actionType.displayName;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.titleLabel.font = theme.headlineFont;
    self.titleLabel.textColor = theme.primaryTextColor;
    self.descriptionLabel.font = theme.bodyFont;
    self.descriptionLabel.textColor = theme.primaryTextColor;
    self.hoursLabel.font = theme.boldBodyFont;
    self.hoursLabel.textColor = theme.primaryTextColor;
    
    if ([self.actionType isKindOfClass:[ECSMessageActionType class]])
    {
        ECSMessageActionType *action = (ECSMessageActionType*)self.actionType;
        self.titleLabel.text = action.messageHeader;
        self.descriptionLabel.text = action.messageText;
        self.hoursLabel.text = action.hoursText;
        [self.emailButton setTitle:action.emailButtonText forState:UIControlStateNormal];
    }
    
    if (![MFMailComposeViewController canSendMail])
    {
        self.emailButton.enabled = NO;
    }
}

- (IBAction)emailButtonTapped:(id)sender
{
    if ([self.actionType isKindOfClass:[ECSMessageActionType class]] &&
        [MFMailComposeViewController canSendMail])
    {
        ECSMessageActionType *action = (ECSMessageActionType*)self.actionType;

    
        MFMailComposeViewController *mailViewController = [MFMailComposeViewController new];
        [mailViewController setSubject:action.emailSubject];
        [mailViewController setMessageBody:action.emailBody isHTML:YES];
        [mailViewController setToRecipients:@[action.email]];
        [mailViewController setMailComposeDelegate:self];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (MFMailComposeResultSent == result)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
