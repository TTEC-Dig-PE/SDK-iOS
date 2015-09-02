//
//  ECSCafeXVideoViewController.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSCafeXVideoViewController.h"

@interface ECSCafeXVideoViewController()

@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;
@property (weak, nonatomic) IBOutlet UIButton *endVideoChatButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;

@end

@implementation ECSCafeXVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.delegate CafeXViewDidAppear];
}

- (void)displayVoiceCallBackEndAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Session ended"
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

#pragma mark - Action Methods

- (IBAction)minimizeButtonPressed:(id)sender {
    if ([self.workflowDelegate respondsToSelector:@selector(minimizeButtonTapped:)]) {
        [self.workflowDelegate minimizeButtonTapped:sender];
    }
}

- (IBAction)videoButtonPressed:(id)sender {
    [self.videoButton setSelected:([self.videoButton isSelected] == NO)];
}

- (IBAction)audioButtonPressed:(id)sender {
    [self.audioButton setSelected:([self.audioButton isSelected] == NO)];
}

- (IBAction)endVideoChatButtonPressed:(id)sender {
    //TODO: Need to handle this Video Call end notification as well
    [self displayVoiceCallBackEndAlert];
}

@end