//
//  ECSCafeXVideoViewController.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSCafeXVideoViewController.h"

@implementation ECSCafeXVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //TODO: Need to display this alert, on Video Call end notification
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self displayVoiceCallBackEndAlert];
    });
    [self.delegate CafeXViewDidAppear];
}

- (void)displayVoiceCallBackEndAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video Chat Completed"
                                                                             message:@"Please answer a few questions so we can serve you better!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionStop = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self.workflowDelegate disconnectedFromVideoChat];
    }];
    
    [alertController addAction:alertActionStop];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.delegate CafeXViewDidUnload];
}

- (void)configureNavigationBar {    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Minimize"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(minimizeButtonPressed:)];
}

- (void)minimizeButtonPressed:(id)sender {
    if ([self.workflowDelegate respondsToSelector:@selector(minimizeButtonTapped:)]) {
        [self.workflowDelegate minimizeButtonTapped:sender];
    }
}

@end