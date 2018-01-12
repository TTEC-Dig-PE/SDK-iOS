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
        NSArray *toRecipients = [NSArray arrayWithObjects:@"nathan.keeney@humanify.com",@"mike.schmoyer@humanify.com", nil];
                                 
        [mailComposer setToRecipients:toRecipients];
        // Attach the Log..
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"humanify-ecd-console.log"];
        NSData *myData = [NSData dataWithContentsOfFile:logPath];
        [mailComposer addAttachmentData:myData mimeType:@"Text/XML" fileName:@"humanify-ecd-console.log"];
        // Fill out the email body text
        NSString *emailBody = [NSString stringWithFormat:@"Please describe what you were doing prior to the issue, and what exactly occurred that prompted this report:\n\n\n\nSession Details:"]; // TODO: Add session information
        [mailComposer setMessageBody:emailBody isHTML:NO];
        //[[ECDBugReportEmailer topMostController] presentModalViewController:mailComposer animated:YES];
        [[ECDBugReportEmailer topMostController] presentViewController:mailComposer animated:YES completion:nil];
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"You must first setup Mail on your device to send a bug report."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        [alert addAction:okAction];
        [[ECDBugReportEmailer topMostController] presentViewController:alert animated:YES completion:nil];
    }
}

- (void)reportBug:(NSMutableString *)message {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"ECD/SDK Bug Report"];
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObjects:@"nathan.keeney@humanify.com",@"mike.schmoyer@humanify.com", nil];
        
        [mailComposer setToRecipients:toRecipients];
        // Attach the Log..
        NSData *myData = [message dataUsingEncoding:NSUTF8StringEncoding];
        [mailComposer addAttachmentData:myData mimeType:@"Text/XML" fileName:@"humanify-ecd-console.txt"];
        // Fill out the email body text
        NSString *emailBody = [NSString stringWithFormat:@"Please describe what you were doing prior to the issue, and what exactly occurred that prompted this report:\n\n\n\nSession Details:"]; // TODO: Add session information
        [mailComposer setMessageBody:emailBody isHTML:NO];
        //[[ECDBugReportEmailer topMostController] presentModalViewController:mailComposer animated:YES];
        [[ECDBugReportEmailer topMostController] presentViewController:mailComposer animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"You must first setup Mail on your device to send a bug report."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        [alert addAction:okAction];
        [[ECDBugReportEmailer topMostController] presentViewController:alert animated:YES completion:nil];
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
            [self showAlertWithTitle:@"Error" andMesssage:msg];
            
            break; }
        default: {
            NSLog(@"An error occurred when trying to compose this email");
            NSString *msg = [NSString stringWithFormat:@"Failed to submit bug report. Check to make sure you have set up Mail on this device, then try again. Error: %@", error];
            [self showAlertWithTitle:@"Error" andMesssage:msg];
            break;
        }
    }
    
    [[ECDBugReportEmailer topMostController] dismissViewControllerAnimated:YES completion:NULL];
}

- (void) showAlertWithTitle:(NSString *)title andMesssage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [[ECDBugReportEmailer topMostController] presentViewController:alert animated:YES completion:nil];
}


@end
