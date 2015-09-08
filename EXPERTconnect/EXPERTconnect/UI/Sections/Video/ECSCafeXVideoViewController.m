//
//  ECSCafeXVideoViewController.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSCafeXVideoViewController.h"

#import "ECSVideoChatActionType.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.delegate CafeXViewDidAppear];

    
    ECSVideoChatActionType *action = (ECSVideoChatActionType *)self.actionType;
    if([action.cafexmode isEqualToString:@"voiceauto"]) {
        [self.videoButton setSelected:YES];
        [self.videoButton setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.delegate CafeXViewDidUnload];
}

#pragma mark - Action Methods

- (IBAction)minimizeButtonPressed:(id)sender {
    if ([self.workflowDelegate respondsToSelector:@selector(minimizeButtonTapped:)]) {
        [self.workflowDelegate minimizeVideoButtonTapped:sender];
    }
    
    [self.delegate CafeXViewDidMinimize];
}

- (IBAction)videoButtonPressed:(id)sender {
    [self.videoButton setSelected:([self.videoButton isSelected] == NO)];
    
    [self.delegate CafeXViewDidHideVideo:[self.videoButton isSelected]];
}

- (IBAction)audioButtonPressed:(id)sender {
    [self.audioButton setSelected:([self.audioButton isSelected] == NO)];
    
    [self.delegate CafeXViewDidMuteAudio:[self.audioButton isSelected]];
}

- (IBAction)endVideoChatButtonPressed:(id)sender {
    // No need to display an alert here, since the Chat is still going on, even if Video ends.
    
    [self.delegate CafexViewDidEndVideo];
    [self.workflowDelegate endVideoChat];
}

@end