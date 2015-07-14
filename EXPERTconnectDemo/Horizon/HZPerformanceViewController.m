//
//  HZPerformanceViewController.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 24/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZPerformanceViewController.h"

#import "HZAppDelegate.h"

#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface HZPerformanceViewController ()

@end

@implementation HZPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)hamburgerButtonTapped:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)giveFeedbackButtonTapped:(id)sender {
    [[EXPERTconnect shared] setUserIntent:@"mutual funds"];
    
    HZAppDelegate *appDelegate = (HZAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate presentChatWindow];
}

@end
