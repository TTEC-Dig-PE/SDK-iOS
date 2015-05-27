/*
 Copyright 2009-2014 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "InboxSampleViewController.h"
#import "InboxSampleAppDelegate.h"
#import "UAirship.h"
#import "UAInbox.h"
#import "UAInboxMessageListController.h"
#import "UAInboxMessageViewController.h"
#import "UALandingPageOverlayController.h"
#import "InboxSampleUserInterface.h"
#import "InboxSampleModalUserInterface.h"
#import "InboxSamplePopoverUserInterface.h"
#import "InboxSampleNavigationUserInterface.h"
#import "UAInboxAlertHandler.h"
#import "UAUtils.h"

typedef NS_ENUM(NSInteger, InboxStyle) {
    InboxStyleModal,
    InboxStyleNavigation
};

@interface InboxSampleViewController()
@property(nonatomic, assign) InboxStyle style;
@property(nonatomic, strong) UIPopoverController *popover;
@property(nonatomic, strong) id<InboxSampleUserInterface> userInterface;
@property(nonatomic, strong) UAInboxAlertHandler *alertHandler;
@end

@implementation InboxSampleViewController

- (void)awakeFromNib {
    self.alertHandler = [[UAInboxAlertHandler alloc] init];
}

- (IBAction)mail:(id)sender {
    [self.userInterface showInbox];
}

- (BOOL)shouldUsePopover {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !self.runiPhoneTargetOniPad;
}

/*
 Builds a new instance of the message list controller, configuring buttons and closeBlock implemenations.
 */
- (UAInboxMessageListController *)buildMessageListController {
    UAInboxMessageListController *mlc = [[UAInboxMessageListController alloc] initWithNibName:@"UAInboxMessageListController" bundle:nil];
    mlc.title = @"Inbox";

    mlc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                         target:self
                                                                                         action:@selector(inboxDone:)];

    //the closeBLock allows for rich push messages to close the inbox after running actions
    mlc.closeBlock = ^(BOOL animated) {
        [self.userInterface hideInbox];
    };

    return mlc;
}

- (void)inboxDone:(id)sender {
    [self.userInterface hideInbox];
}

/*
 Displays an incoming message, either by showing it in an overlay,
 or loading it in an already visible inbox interface.
 */
- (void)displayMessage:(UAInboxMessage *)message {
    if (![self.userInterface isVisible]) {
        if (self.useOverlay) {
            [UALandingPageOverlayController showMessage:message];
            return;
        } else {
            [self.userInterface showInbox];
        }
    }

    [self.userInterface.messageListController displayMessage:message];
}

- (void)setStyle:(enum InboxStyle)style {
    UAInboxMessageListController *mlc = [self buildMessageListController];
    switch (style) {
        case InboxStyleModal:
            self.userInterface = [[InboxSampleModalUserInterface alloc] initWithMessageListController:mlc];
            break;
        case InboxStyleNavigation:
            if ([self shouldUsePopover]) {
                self.userInterface = [[InboxSamplePopoverUserInterface alloc] initWithMessageListController:mlc
                                                                                        popoverSize:self.popoverSize];
            } else {
                self.userInterface = [[InboxSampleNavigationUserInterface alloc] initWithMessageListController:mlc];
            }
            break;
        default:
            break;
    }

    self.userInterface.parentController = self;
    _style = style;
}

- (IBAction)selectInboxStyle:(id)sender {
    
    NSString *popoverOrNav;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverOrNav = @"Popover";
    }
    
    else {
        popoverOrNav = @"Navigation Controller";
    }
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Inbox Style" delegate:self 
                        cancelButtonTitle:@"Cancel" 
                   destructiveButtonTitle:nil 
                        otherButtonTitles:@"Modal", popoverOrNav, nil];
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            self.style = InboxStyleModal;
            break;
        case 1:
            self.style = InboxStyleNavigation;
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.runiPhoneTargetOniPad = NO;
    self.style = InboxStyleModal;

    self.version.text = [NSString stringWithFormat:@"UAInbox Version: %@", [UAirshipVersion get]];

    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Inbox"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self action:@selector(mail:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UAInboxPushHandlerDelegate methods

/*
 Called when a new rich push message is available for viewing.
 */
- (void)richPushMessageAvailable:(UAInboxMessage *)message {

     // Display an alert, and if the user taps "View", display the message
     NSString *alertText = message.title;
     [self.alertHandler showNewMessageAlert:alertText withViewBlock:^{
         [self displayMessage:message];
     }];
}

/*
 Called when a new rich push message is available after launching from a
 push notification.
 */
- (void)launchRichPushMessageAvailable:(UAInboxMessage *)message {
    [self displayMessage:message];
}

- (void)richPushNotificationArrived:(NSDictionary *)notification {
    // Add custom notification handling here
}

- (void)applicationLaunchedWithRichPushNotification:(NSDictionary *)notification {
    // Add custom launch notification handling here
}

@end
