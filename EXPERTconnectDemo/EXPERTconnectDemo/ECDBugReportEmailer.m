//
//  ECDBugReportEmailer.m
//  HorizonConnectDemo
//
//  Created by Nathan Keeney on 10/5/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDBugReportEmailer.h"

@implementation ECDBugReportEmailer

- (void)reportBug {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"ECD/SDK Bug Report"];
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:@"nathan.keeney@humanify.com"];
        [mailComposer setToRecipients:toRecipients];
        // Attach the Log..
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"humanify-ecd-console.log"];
        NSData *myData = [NSData dataWithContentsOfFile:logPath];
        [mailComposer addAttachmentData:myData mimeType:@"Text/XML" fileName:@"humanify-ecd-console.log"];
        // Fill out the email body text
        NSString *emailBody = [NSString stringWithFormat:@"Please describe what you were doing prior to the issue, and what exactly occurred that prompted this report:\n\n\n\nSession Details:"]; // TODO: Add session information
        [mailComposer setMessageBody:emailBody isHTML:NO];
        //[[ECDBugReportEmailer topMostController] presentModalViewController:mailComposer animated:YES];
        [[ECDBugReportEmailer topMostController] presentViewController:mailComposer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You must first set up Mail on your device in order to send a Bug Report." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

+ (void)setUpLogging {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"humanify-ecd-console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

+ (void)resetLogging {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"humanify-ecd-console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"w+",stderr); // w+ erases the file and opens it for writing
}

+ (UIViewController*) topMostController {
    UIViewController *topController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}


#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent: {
            NSLog(@"You sent the email.");
            // Erase the file:
            [ECDBugReportEmailer resetLogging];
            break;
        }
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed: {
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            NSString *msg = [NSString stringWithFormat:@"Failed to submit bug report. Check to make sure you have set up Mail on this device, then try again. Error: %@", error];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Error Registering" message:msg delegate:nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
            [av show];
            break; }
        default: {
            NSLog(@"An error occurred when trying to compose this email");
            NSString *msg = [NSString stringWithFormat:@"Failed to submit bug report. Check to make sure you have set up Mail on this device, then try again. Error: %@", error];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Error Registering" message:msg delegate:nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
            [av show];
            break;
        }
    }
    
    [[ECDBugReportEmailer topMostController] dismissViewControllerAnimated:YES completion:NULL];
}


@end