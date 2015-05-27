//
//  ECSCancelCallbackViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCancelCallbackViewController.h"

#import "ECSButton.h"
#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"

@interface ECSCancelCallbackViewController ()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *titleLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *waitTimeLabel;
@property (weak, nonatomic) IBOutlet ECSButton *cancelCallRequestButton;
@end

@implementation ECSCancelCallbackViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    
    self.titleLabel.textColor = theme.primaryTextColor;
    self.descriptionLabel.textColor = theme.primaryTextColor;
    self.waitTimeLabel.textColor = theme.primaryTextColor;
    
    self.titleLabel.font = theme.titleFont;
    self.descriptionLabel.font = theme.bodyFont;
    self.waitTimeLabel.font = theme.bodyFont;

    if (self.displaySMSOption)
    {
        self.navigationItem.title = ECSLocalizedString(ECSLocalizeSMSNavigationTitle, @"SMS Message");
        self.titleLabel.text = ECSLocalizedString(ECSLocalizeSMSCancelTitle, @"We'll Text You.");
        self.descriptionLabel.text = [NSString stringWithFormat:ECSLocalizedString(ECSLocalizeSMSCancelDescription, @"We'll Text You."), self.phoneNumber];
        [self.cancelCallRequestButton setTitle:ECSLocalizedString(ECSLocalizeSMSCancelButton, @"Cancel SMS Request")
                                      forState:UIControlStateNormal];
    }
    else
    {
        self.navigationItem.title = ECSLocalizedString(ECSLocalizeCallNavigationTitle, @"Phone Call");
        self.titleLabel.text = ECSLocalizedString(ECSLocalizeCallCancelTitle, @"We'll Call You.");
        self.descriptionLabel.text = [NSString stringWithFormat:ECSLocalizedString(ECSLocalizeCallCancelDescription, @"We'll Call You."), self.phoneNumber];
        [self.cancelCallRequestButton setTitle:ECSLocalizedString(ECSLocalizeCallCancelButton, @"Cancel Call Request")
                                      forState:UIControlStateNormal];
    }
    [self.cancelCallRequestButton sizeToFit];
    
    NSMutableAttributedString *attrWaitTimeString = nil;
    
    NSInteger waitTimeMinutes = self.waitTime.integerValue / 60;
    if (waitTimeMinutes >= 1)
    {
        NSString *waitTimeString = ECSLocalizedString(ECSLocalizeCallbackWaitTime, @"Callback wait time");
    
        NSString *localizedMinutes = (waitTimeMinutes >= 2) ? ECSLocalizedString(ECSLocalizeMinutes, nil) :
                                            ECSLocalizedString(ECSLocalizeMinute, nil);
        attrWaitTimeString = [[NSMutableAttributedString alloc] initWithString:waitTimeString attributes:@{NSFontAttributeName: theme.bodyFont}];
        NSAttributedString *timeAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld %@", (long)waitTimeMinutes, localizedMinutes] attributes:@{NSFontAttributeName: theme.boldBodyFont}];

        [attrWaitTimeString appendAttributedString:timeAttributedString];
    }
    else
    {
        NSString *waitTimeString = ECSLocalizedString(ECSLocalizeGenericWaitTime, nil);
        attrWaitTimeString = [[NSMutableAttributedString alloc] initWithString:waitTimeString attributes:@{NSFontAttributeName: theme.bodyFont}];
    }
    
    self.waitTimeLabel.attributedText = attrWaitTimeString;
}

- (void)appBecameActive:(id)sender
{
     [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cancelCallbackTapped:(id)sender
{
    ECSURLSessionManager *session = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    if (self.closeChannelURL)
    {
        __weak typeof(self) weakSelf = self;
        [session closeChannelAtURL:self.closeChannelURL
                        withReason:@"Cancelled"
             agentInteractionCount:1
                          actionId:self.actionId
                        completion:^(id result, NSError *error) {
                            [weakSelf handleCancelResponse:YES withError:error];
                        }];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)handleCancelResponse:(BOOL)cancelled withError:(NSError*)error
{
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ECSLocalizedString(ECSLocalizeError, @"Error")
                                                            message:ECSLocalizedString(ECSLocalizeErrorText, @"Error Text")
                                                           delegate:nil
                                                  cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
