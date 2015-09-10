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
@property (weak, nonatomic) IBOutlet UIImageView *smallSilhouette;
@property (weak, nonatomic) IBOutlet UIImageView *largeSilhouette;

@end

@implementation ECSCafeXVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.delegate CafeXViewDidAppear];

    [self.largeSilhouette setHidden:YES];
    [self.smallSilhouette setHidden:YES];
    
    ECSVideoChatActionType *action = (ECSVideoChatActionType *)self.actionType;
    if([action.cafexmode isEqualToString:@"voiceauto"]) {
        [self.videoButton setSelected:YES];
        [self.videoButton setHidden:YES];
        
        [self.largeSilhouette setHidden:NO];
        [self.smallSilhouette setHidden:NO];
    }
}

- (void) configWithVideo:(BOOL)showVideo andAudio:(BOOL)showAudio {
    if (!showVideo) { // audio call
        [self.videoButton setSelected:YES];
        [self.videoButton setHidden:YES];
        
        [self.largeSilhouette setHidden:NO];
        [self.smallSilhouette setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.delegate CafeXViewDidUnload];
}

- (void) hideVideoPanels:(BOOL)hidden {
    [self.smallSilhouette setHidden:!hidden]; // video is hidden, so SHOW the silhouette to cover it.
}
- (void) didHideRemoteVideo:(BOOL)hidden; {
    [self.largeSilhouette setHidden:!hidden]; // video is hidden, so SHOW the silhouette to cover it.
    
    if (!hidden && [self.videoButton isHidden]) { // agent-initiated escalate to video
        [self.videoButton setHidden:NO];
    }
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
    
    [self.delegate CafeXViewDidHideVideo:[self.videoButton isSelected]];  // Selected means Off. Why? Dunno.
}

- (IBAction)audioButtonPressed:(id)sender {
    [self.audioButton setSelected:([self.audioButton isSelected] == NO)];
    
    [self.delegate CafeXViewDidMuteAudio:[self.audioButton isSelected]];  // Selected means Off. Why? Dunno.
}

- (IBAction)endVideoChatButtonPressed:(id)sender {
    // No need to display an alert here, since the Chat is still going on, even if Video ends.
    
    [self.delegate CafexViewDidEndVideo];
    [self.workflowDelegate endVideoChat];
}

@end