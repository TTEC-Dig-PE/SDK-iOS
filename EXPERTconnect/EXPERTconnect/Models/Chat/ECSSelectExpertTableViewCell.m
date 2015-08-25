//
//  ECSSelectExpertTableViewCell.m
//  EXPERTconnect
//
//  Created by Mohammad Abdurraafay on 21/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSelectExpertTableViewCell.h"
#import "ECSCircleImageView.h"
#import "ECSDynamicLabel.h"
#import "ECSTheme.h"
#import "ECSInjector.h"
#import "ECSActionType.h"

@interface ECSSelectExpertTableViewCell ()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *regionTitle;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *interestsTitle;

@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *videoChatButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceChatButton;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsTopLayoutConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceButtonCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callBackCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoButtonCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatButtonCenterY;

@end

@implementation ECSSelectExpertTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.contentView.backgroundColor = [theme secondaryBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.profileImage.backgroundColor = theme.primaryColor;
    self.name.font = theme.buttonFont;
    self.name.textColor = theme.primaryTextColor;
    
    self.regionTitle.textColor = theme.primaryTextColor;
    self.regionTitle.font = theme.buttonFont;
    
    self.interestsTitle.textColor = theme.primaryTextColor;
    
    self.expertiese.textColor = theme.secondaryTextColor;
    self.region.textColor = theme.secondaryTextColor;
    self.interests.textColor = theme.secondaryTextColor;
    
    [self configureButtons];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.name.preferredMaxLayoutWidth = self.name.frame.size.width;
    self.region.preferredMaxLayoutWidth = self.region.frame.size.width;
    [super layoutSubviews];
    
}

- (void)configureButtons {
    [self.chatButton.layer setCornerRadius:3.0];
    [self.videoChatButton.layer setCornerRadius:3.0];
    [self.voiceChatButton.layer setCornerRadius:3.0];
    [self.callBackButton.layer setCornerRadius:3.0];
}

- (void)configureCellForActionType:(NSString *)actionType {
    if ([actionType isEqualToString:ECSActionTypeSelectExpertChat]) {
        [self displayOnlyChatActionButton];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertVideo]) {
        [self displayOnlyVideoChatActionButton];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertVoiceCallback]){
        [self displayOnlyCallbackActionButton];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertVoiceChat]) {
        [self displayOnlyVoiceChatActionButton];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertAndChannel]) {
        [self displayAllActionButtons];
    }
    
    [self.buttonsContainerView updateConstraintsIfNeeded];
    [self.buttonsContainerView layoutIfNeeded];
}

#pragma mark - Configure Methods

- (void)displayOnlyChatActionButton {
    [self.chatButtonCenterY setPriority:UILayoutPriorityRequired];
    [self.chatButton setHidden:NO];
    [self.videoChatButton setHidden:YES];
    [self.voiceChatButton setHidden:YES];
    [self.callBackButton setHidden:YES];
}

- (void)displayOnlyVideoChatActionButton {
    [self.videoButtonCenterY setPriority:UILayoutPriorityRequired];
    [self.chatButton setHidden:YES];
    [self.videoChatButton setHidden:NO];
    [self.voiceChatButton setHidden:YES];
    [self.callBackButton setHidden:YES];
}

- (void)displayOnlyVoiceChatActionButton {
    [self.voiceButtonCenterY setPriority:UILayoutPriorityRequired];
    [self.chatButton setHidden:YES];
    [self.videoChatButton setHidden:YES];
    [self.voiceChatButton setHidden:NO];
    [self.callBackButton setHidden:YES];
}

- (void)displayOnlyCallbackActionButton {
    [self.callBackCenterY setPriority:UILayoutPriorityRequired];
    [self.chatButton setHidden:YES];
    [self.videoChatButton setHidden:YES];
    [self.voiceChatButton setHidden:YES];
    [self.callBackButton setHidden:NO];
}

- (void)displayAllActionButtons {
    [self.chatButton setHidden:NO];
    [self.videoChatButton setHidden:NO];
    [self.voiceChatButton setHidden:NO];
    [self.callBackButton setHidden:NO];
    [self.buttonsTopLayoutConstraints setPriority:UILayoutPriorityRequired];
    [self.buttonsBottomConstraints setPriority:UILayoutPriorityRequired];
}

#pragma mark - Action Methods

- (IBAction)chatPressed:(id)sender {
    [self.selectExpertCellDelegate chatPressed];
}

- (IBAction)callBackPressed:(id)sender {
    [self.selectExpertCellDelegate callBackPressed];
}

- (IBAction)voiceChatPressed:(id)sender {
    [self.selectExpertCellDelegate voiceChatPressed];
}

- (IBAction)videoPressed:(id)sender {
    [self.selectExpertCellDelegate videoPressed];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
