//
//  ECDChatConfigVC.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 6/10/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ECDChatConfigVC : UIViewController

@property (strong, nonatomic) UIViewController *chatController;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerChatSkill;
@property (weak, nonatomic) IBOutlet UIButton *btnEndChat;
@property (weak, nonatomic) IBOutlet UIButton *btnStartChat;

@property (weak, nonatomic) IBOutlet UISwitch *optTimestamp;
@property (weak, nonatomic) IBOutlet UISwitch *optChatBubble;
@property (weak, nonatomic) IBOutlet UISwitch *optAvatarImages;
@property (weak, nonatomic) IBOutlet UISwitch *optNavButtons;
@property (weak, nonatomic) IBOutlet UISwitch *optSendButtonImage;
@property (weak, nonatomic) IBOutlet UISwitch *optImageUploadButton;


@property (weak, nonatomic) IBOutlet UILabel *lblAgentAvailability;
@property (weak, nonatomic) IBOutlet UILabel *chatSkillLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatBubblesLabel;
@property (weak, nonatomic) IBOutlet UILabel *avatarImagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *customNavBarButtonsLabel;
@property (weak, nonatomic) IBOutlet UILabel *useImageForSendButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *showImageUploadButtonLabel;

- (IBAction)btnStartChat_Touch:(id)sender;
- (IBAction)btnEndChat_Touch:(id)sender;
- (IBAction)optTimestamp_Change:(id)sender;
- (IBAction)optChatBubble_Change:(id)sender;
- (IBAction)optAvatarImages_Change:(id)sender;
- (IBAction)optNavButtons_Change:(id)sender;

@end
