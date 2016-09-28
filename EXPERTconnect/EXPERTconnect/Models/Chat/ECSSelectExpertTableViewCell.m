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
#import "ECSExpertDetail.h"

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraints;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *firstLineLeadingConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *regionLeadingConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonsLeadingConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonsTrailingConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *regionTrailingConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *regionTopConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *regionBottomConstraints;

@property (weak, nonatomic) IBOutlet UIView *secondLineView;

@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) ECSExpertDetail *expert;
@end

@implementation ECSSelectExpertTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib]; 
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
//    self.contentView.backgroundColor = [theme secondaryBackgroundColor];
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
	 
	 [self.chatButton setBackgroundColor:theme.buttonColor];
	 [self.videoChatButton setBackgroundColor:theme.buttonColor];
	 [self.voiceChatButton setBackgroundColor:theme.buttonColor];
	 [self.callBackButton setBackgroundColor:theme.buttonColor];
	 
	 [self.chatButton setTitleColor:theme.buttonTextColor forState:UIControlStateNormal];
	 [self.videoChatButton setTitleColor:theme.buttonTextColor forState:UIControlStateNormal];
	 [self.voiceChatButton setTitleColor:theme.buttonTextColor forState:UIControlStateNormal];
	 [self.callBackButton setTitleColor:theme.buttonTextColor forState:UIControlStateNormal];
	 
	 self.chatButton.titleLabel.font = theme.buttonFont;
	 self.videoChatButton.titleLabel.font = theme.buttonFont;
	 self.voiceChatButton.titleLabel.font = theme.buttonFont;
	 self.callBackButton .titleLabel.font = theme.buttonFont;
	 
	 self.imageViewHeightConstraints.constant = 0.0f;
}

- (void)configureConstraints
{
	 [self.containerView removeConstraint:self.firstLineLeadingConstraints];
	 [self.containerView removeConstraint:self.regionTrailingConstraints];
	 [self.containerView removeConstraint:self.regionTopConstraints];
	 [self.containerView removeConstraint:self.regionBottomConstraints];
	 [self.containerView removeConstraint:self.regionLeadingConstraints];
	 [self.containerView removeConstraint:self.buttonsLeadingConstraints];
	 [self.containerView removeConstraint:self.buttonsTrailingConstraints];
	 
	 self.firstLineLeadingConstraints = [NSLayoutConstraint constraintWithItem:self.firstLineView
																	 attribute:NSLayoutAttributeLeading
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.profileView
																	 attribute:NSLayoutAttributeTrailing
																	multiplier:1.0f
																	  constant:5.0f];
	 
	 self.regionLeadingConstraints = [NSLayoutConstraint constraintWithItem:self.regionView
																  attribute:NSLayoutAttributeLeading
																  relatedBy:NSLayoutRelationEqual
																	 toItem:self.firstLineView
																  attribute:NSLayoutAttributeTrailing
																 multiplier:1.0f
																   constant:12.0f];
	 
	 self.buttonsLeadingConstraints = [NSLayoutConstraint constraintWithItem:self.buttonsContainerView
																   attribute:NSLayoutAttributeLeading
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.secondLineView
																   attribute:NSLayoutAttributeTrailing
																  multiplier:1.0f
																	constant:12.0f];
	 
	 self.buttonsTrailingConstraints = [NSLayoutConstraint constraintWithItem:self.buttonsContainerView
																	attribute:NSLayoutAttributeTrailing
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.containerView
																	attribute:NSLayoutAttributeTrailing
																   multiplier:1.0f
																	 constant:-12.0f];
	 
	 self.regionTopConstraints = [NSLayoutConstraint constraintWithItem:self.regionView
															  attribute:NSLayoutAttributeTop
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.containerView
															  attribute:NSLayoutAttributeTop
															 multiplier:1.0f
															   constant:16.0f];
	 
	 [self.containerView addConstraint:self.firstLineLeadingConstraints];
	 [self.containerView addConstraint:self.regionLeadingConstraints];
	 [self.containerView addConstraint:self.buttonsLeadingConstraints];
	 [self.containerView addConstraint:self.buttonsTrailingConstraints];
	 [self.containerView addConstraint:self.regionTopConstraints];
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

- (void)configureCellForActionType:(NSString *)actionType withExpert:(ECSExpertDetail *)expert {
    
    self.expert = expert;
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
    [self.videoButtonCenterY setPriority:UILayoutPriorityRequired];
    [self.chatButton setHidden:NO];
    [self.videoChatButton setHidden:YES];
    [self.voiceChatButton setHidden:YES];
    [self.callBackButton setHidden:YES];
}

- (void)displayOnlyVideoChatActionButton {
    [self.videoButtonCenterY setPriority:UILayoutPriorityDefaultHigh];
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
    if (self.expert) {
        [self.selectExpertCellDelegate didSelectChatButton:sender
                                                 forExpert:self.expert];
    }
}

- (IBAction)callBackPressed:(id)sender {
    if (self.expert) {
        [self.selectExpertCellDelegate didSelectCallBackButton:sender
                                                     forExpert:self.expert];
    }
}

- (IBAction)voiceChatPressed:(id)sender {
    if (self.expert) {
        [self.selectExpertCellDelegate didSelectVoiceChatButton:sender
                                                      forExpert:self.expert];
    }
}

- (IBAction)videoPressed:(id)sender {
    if (self.expert) {
        [self.selectExpertCellDelegate didSelectVideoChatButton:sender
                                                      forExpert:self.expert];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
