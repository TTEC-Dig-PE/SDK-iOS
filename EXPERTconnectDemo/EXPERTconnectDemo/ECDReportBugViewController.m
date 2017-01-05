//
//  ECDReportBugViewController.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 03/01/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import "ECDReportBugViewController.h"

@interface ECDReportBugViewController ()<UITextViewDelegate> {
    AppDelegate *app;
}

@end

@implementation ECDReportBugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Report Bug";
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    
     app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _textViewLogging.editable = NO;
    _textViewLogging.selectable = NO;
    _textViewLogging.text = [app logMessages];
}

-(IBAction)reportBug_Touch:(id)sender {
    [app reportBug:[app logMessages]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
